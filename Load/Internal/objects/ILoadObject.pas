unit ILoadObject;

interface


uses interfaces, model,
     AWS.S3, AWS.S3.Client, AWS.S3.ClientIntf,
     System.SysUtils, System.Classes,
     System.Diagnostics, System.IOUtils, System.Generics.Collections,
     Data.Cloud.CloudAPI, Data.Cloud.AmazonAPI,
     IEventObject,
     ILoadValue;

type

  TLoad = class;
  TSpeedStream = class(TFileStream)
    private
      FSpeed: Longint;
      FChunk: Longint;
      Watch: TStopwatch;
    public
      Parent: TLoad;
      function Read(var Buffer; Count: Longint): Longint; override;
      function Read(Buffer: TBytes; Offset, Count: Longint): Longint; override;
      procedure CheckSpeed(aCount: Longint);
      property Speed: Integer read FSpeed;
      procedure AfterConstruction; override;
  end;

//  TLoad = class(TInterfacedObject,   ILoad)
  TLoad = class(TEvents<ILoad, TEventType>,   ILoad)
    private
      FSettings: ISettings;
      FIdx: Integer;
      FLoadSetup: ILoadSetup;
      FS3Client: IAmazonS3;
      Stream: TSpeedStream;
//      FEvent: TOnEvent;
      FStatus: TLoadStatus;
      FCount, FCurentIdx: Integer;
      FThread: TThread;
      FEventType: TEventType;
      FEventStart: Boolean;
      FThreadResult: Boolean;
      FError: string;
    protected
      procedure SyncEvent;
      function DoEvent(aEventType: TEventType): Boolean;
      function GetName: string;
      function GetSize: Int64;
      function GetProgress: Byte;
      function GetStatus: TLoadStatus;
      function Speed: Int64;
      function GetError: string;

//      procedure SetOnEvent(aEvent: TOnEvent);
      procedure LoadFile(LocalFolder, aFile: string; aClient: IAmazonS3);
      procedure DoStart;
      procedure Start;
      procedure Stop;
      procedure OnThreadTerminate(Sender: TObject);
    public
      constructor Create(aSettings: ISettings; aIdx: Integer);
  end;

implementation

{ TLoad }

constructor TLoad.Create(aSettings: ISettings; aIdx: Integer);

begin
  inherited Create;
  FSettings:=aSettings;
  FLoadSetup:=FSettings.LoadList.Items[aIdx];
  FIdx:=aIdx;
  FStatus:=tlsReady;
  FEventStart:=False;
end;

function TLoad.DoEvent(aEventType: TEventType): Boolean;
begin
  if Assigned(Event) then
  begin
    if Assigned(FThread) then
    begin
      FEventType:=aEventType;
      FEventStart:=True;
      try
        TThread.Synchronize(FThread, SyncEvent);
      finally
        FEventStart:=False;
      end;
      Result:=FThreadResult;
    end
    else
      Result:=Event(Self, aEventType);
  end
  else
    Result:=True;
end;

function TLoad.GetError: string;
begin
  Result:=FError;
end;

function TLoad.GetName: string;
begin
  Result:=FLoadSetup.LoadData[tldName];
end;

function TLoad.GetProgress: Byte;
begin
  if Assigned(Stream) then
    Result:= Round((Stream.FChunk / Stream.Size + FCurentIdx) / FCount * 100)
  else
    Result:=0;
end;

function TLoad.GetSize: Int64;
begin
  if ASsigned(Stream) then
    Result:=Stream.Size
  else
    Result:=0;
end;

function TLoad.GetStatus: TLoadStatus;
begin
  if FEventStart then
    Result:=tlsInProgress
  else
    Result:=FStatus;
end;

procedure TLoad.LoadFile(LocalFolder, aFile: string; aClient: IAmazonS3);
var RelativePath: string;
    Request: IPutObjectRequest;
begin
  RelativePath:=Copy(aFile, Length(IncludeTrailingPathDelimiter(LocalFolder)) + 1, Length(aFile));

  Request:=TPutObjectRequest.Create;
  Request.BucketName:=FLoadSetup.LoadData[tldBucket];
  Request.Key:=FLoadSetup.LoadData[tldName];

  Stream:=TSpeedStream.Create(aFile, fmOpenRead or fmShareDenyWrite);
  Stream.Parent:=Self;
  Request.Body:=Stream;
  try
    FS3Client.PutObject(Request);

{   //проверка
    var vStream:=TStringStream.Create;

    var vResp:=FS3Client.GetObject(FLoadSetup.LoadData[tldBucket], FLoadSetup.LoadData[tldName]).Body;
    vResp.Position:=0;
    vStream.CopyFrom(vResp, vResp.Size);
    vStream.SaveToFile('c:\test\2.txt');
}
  except
    on E: EAbort do
      FStatus:=tlsStop;
    on E: Exception do
    begin
      FStatus:=tlsStop;
      raise E;
    end;
  end;
end;
procedure TLoad.OnThreadTerminate(Sender: TObject);
begin
  case FStatus of
    tlsDone,
    tlsStop: DoEvent(tetOnFinish);
    else DoEvent(tetOnError);
  end;

  FThread:=nil;
end;

{
procedure TLoad.SetOnEvent(aEvent: TOnEvent);
begin
  FEvent:=aEvent;
end;
//}

function TLoad.Speed: Int64;
begin
  if Assigned(Stream) then
    Result:=Stream.FSpeed
  else
    Result:=0;
end;

procedure TLoad.DoStart;
  procedure ScanFolder(aPath: string; aList: TList<string>);
  begin
    aList.AddRange(TDirectory.GetFiles(aPath));
    for var D in TDirectory.GetDirectories(aPath) do
      ScanFolder(D, aList);
  end;
var
  RegionConfig: TAmazonS3Config;
  FName, CurDirectory: string;
  vList: TList<string>;
begin
  try
    RegionConfig:=TAmazonS3Config.Create;
    RegionConfig.ServiceURL:=FLoadSetup.LoadData[tldEndpoint];
    RegionConfig.AuthenticationRegion:=FLoadSetup.LoadData[tldRegion];
    RegionConfig.ForcePathStyle:=True;
    RegionConfig.MaxErrorRetry:=FLoadSetup.TryCount;
    FS3Client:=TAmazonS3Client.Create(FLoadSetup.LoadData[tldAccessKey],
                                      FLoadSetup.LoadData[tldSecretkey],
                                      RegionConfig);

    FName:=FLoadSetup.LoadData[tldName];
    CurDirectory:=ExtractFilePath(FName);
    vList:=TList<string>.Create;
    try
      if FileExists(FName) then
        vList.Add(FName)
      else
      if TDirectory.Exists(FName) then
      begin
        ScanFolder(FName, vList);
      end;

      FStatus:=tlsInProgress;
      DoEvent(tetOnStart);

      FCount:=vList.Count;
      for var I:=0 to FCount - 1 do
      begin
        FCurentIdx:=I;
        if FStatus <> tlsInProgress then
          Break;
        LoadFile(CurDirectory, vList.Items[I], FS3Client);
      end;
      if FStatus = tlsInProgress then
        FStatus:=tlsDone;
    finally
      FreeAndNil(vList);
//      FThread:=nil;
    end;
  except
    on E: Exception do
    begin
        FStatus:=tlsError;
        FError:=E.Message;
        DoEvent(tetOnError);
    end;
  end;
end;

procedure TLoad.Start;
begin
  FStatus:=tlsSetup;
  FThread:=TThread.CreateAnonymousThread(DoStart);
  FThread.OnTerminate:=OnThreadTerminate;
  FThread.Start;
end;

procedure TLoad.Stop;
begin
  FStatus:=tlsStop;
end;

procedure TLoad.SyncEvent;
begin
  FThreadResult:=Event(Self, FEventType);
end;

{ TSpeedStream }

procedure TSpeedStream.AfterConstruction;
begin
  inherited;
  FChunk:=0;
  FSpeed:=0;
  Watch:=TStopwatch.Create;
  Watch.Start;
end;

procedure TSpeedStream.CheckSpeed;
begin
  Watch.Stop;
  Inc(FChunk, aCount);
  if Watch.ElapsedMilliseconds <> 0 then
    FSpeed:=(FChunk) div Watch.ElapsedMilliseconds;
  Watch.Start;
  if Assigned(Parent) then
  begin
    if Parent.FStatus <> tlsInProgress then
      Abort;
    Parent.DoEvent(tetOnprogress);
  end;

end;

function TSpeedStream.Read(Buffer: TBytes; Offset, Count: Longint): Longint;
begin
  Result:=inherited Read(Buffer, Offset, Count);
  CheckSpeed(Result);
end;

function TSpeedStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result:=inherited Read(Buffer, Count);
  CheckSpeed(Result);
end;

initialization
  RegicterLoadFab(function(aSettings: ISettings; aIdx: Integer): ILoad
                  begin
                    Result:=TLoad.Create(aSettings, aIdx);
                  end);

end.
