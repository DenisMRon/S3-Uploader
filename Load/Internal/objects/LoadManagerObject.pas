unit LoadManagerObject;

interface

uses interfaces, model,
     IList, IEvent,
     ILoadMAnagerValue,
     System.Threading, System.SysUtils,
     System.Generics.Collections, System.Classes;

type
  TLoadManager = class(TInterfacedObject, ILoadManager)
    private
      FStartedCnt: Cardinal;
      FloadList: IList<ILoad>;
      FItems: IReadList<ILoad>;
      FSettings: ISettings;
      FOldSettingsEvent: TOnGenEvent<ISettings, TSettingsEventType>;
      FOldLoadEvent: TDictionary<ILoad, TOnGenEvent<ILoad, TEventType>>;
      FThread: TThread;
    protected
      function GetItems: IReadList<ILoad>;
      function Add(aLoad: ILoad): Integer;
      procedure UpdateSettings;
      procedure NextStart;

      function OnSettingsEvent(Parent: ISettings; aType: TSettingsEventType): Boolean;
      function OnLoadEvent(aParent: ILoad; aType: TEventType): Boolean;
    public
      constructor Create(aSettings: ISettings);
      destructor Destroy; override;
  end;

implementation

{ TLoadManager }

function TLoadManager.Add(aLoad: ILoad): Integer;
begin
//  TMonitor.Enter(Self);
  try
    Result:=FloadList.Add(aLoad);
    FOldLoadEvent.Add(aLoad, aLoad.Event);
    aLoad.Event:=OnLoadEvent;
    NextStart;
  finally
//    TMonitor.Exit(Self);
  end;
end;

constructor TLoadManager.Create(aSettings: ISettings);
begin
  inherited Create;
  FSettings:=aSettings;
  FOldSettingsEvent:=FSettings.Event;
  FOldLoadEvent:=TDictionary<ILoad, TOnGenEvent<ILoad, TEventType>>.Create;
  FSettings.Event:=OnSettingsEvent;
  FloadList:=TListFab.List<ILoad>;
  FItems:=TListFab.ReadList<ILoad>(FloadList);
  FStartedCnt:=0;
  UpdateSettings;
  FThread:=TThread.CreateAnonymousThread(
    procedure
    begin
      while not FThread.CheckTerminated do
      begin
        FThread.Sleep(0);
      end;
      FThread:=nil;
    end);
  FThread.Start;
end;

destructor TLoadManager.Destroy;
begin
  if FThread.Started then
  begin
    FThread.Terminate;
    while Assigned(FThread) do
      Sleep(10);
  end;

  FSettings.Event:=FOldSettingsEvent;

  FreeAndNil(FOldLoadEvent);
  inherited;
end;

function TLoadManager.GetItems: IReadList<ILoad>;
begin
  Result:=FItems;
end;

procedure TLoadManager.NextStart;
  function GetReady: Integer;
  begin
    Result:=-1;
    for var I:=0 to FloadList.Count - 1 do
      if FloadList.Items[I].Status = tlsReady then
      begin
        Result:=I;
        Break;
      end;
  end;
  function StartedCount: Integer;
  begin
    Result:=0;
    for var I:=0 to FloadList.Count - 1 do
      if FloadList.Items[I].Status in [tlsInProgress, tlsSetup] then
        Inc(Result);
  end;
var vNext: Integer;
begin
  vNext:=GetReady;
  while (StartedCount < FSettings.ThreadCount) and (vNext > -1) do
  begin
    FloadList.Items[vNext].Start;
    vNext:=GetReady;
  end;
end;

function TLoadManager.OnLoadEvent(aParent: ILoad; aType: TEventType): Boolean;
var vEvent: TOnGenEvent<ILoad, TEventType>;
begin
//  TMonitor.Enter(Self);
  try
    try
      vEvent:=FOldLoadEvent[aParent];
      if Assigned(vEvent) then
        Result:=vEvent(aParent, aType)
      else
        Result:=True;
    finally
      case aType of
        tetOnStart: ;
        tetOnprogress: ;
        tetOnFinish:
          begin
            FloadList.Delete(FloadList.IndexOf(aParent));
            FOldLoadEvent.ExtractPair(aParent);
            NextStart;
          end;
        tetOnError: NextStart;
      end;
    end;
  finally
//    TMonitor.Exit(Self);
  end;
end;

function TLoadManager.OnSettingsEvent(Parent: ISettings;
  aType: TSettingsEventType): Boolean;
begin
  UpdateSettings;
  if Assigned(FOldSettingsEvent) then
    Result:=FOldSettingsEvent(Parent, aType)
  else
    Result:=True;
end;


procedure TLoadManager.UpdateSettings;
begin
end;

initialization

  RegicterLoadManagerFab(function(aSettings: ISettings): ILoadManager
  begin
    Result:=TLoadManager.Create(aSettings);
  end);

end.
