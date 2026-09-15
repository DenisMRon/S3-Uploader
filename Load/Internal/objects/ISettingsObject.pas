unit ISettingsObject;

interface

implementation

uses interfaces, model,
    IList, ISetingsValue, IEventObject;

type
  TCommonSetup = class(TInterfacedObject, ICommonSetup)
    private
      FTry, FThread: Integer;
    protected
      function GetTryCount: Integer;
      procedure SetTryCount(aValue: Integer);

    constructor Create;
  end;

type

//  TBaseSettings = class(TInterfacedObject, IBaseSettings)
  TBaseSettings = class(TEvents<ISettings, TSettingsEventType>, IBaseSettings)
    private
      FCommonSetup: ICommonSetup;
    protected
      function GetCommonSetup: ICommonSetup;
      property CommonSetup: ICommonSetup read GetCommonSetup;
    public
      constructor Create;
  end;

type
  TSettings = class(TBaseSettings, ISettings)
    private
      FLoadList: IList<ILoadSetup>;
      FThread: Integer;
    protected
      function GetLoadList: IList<ILoadSetup>;
      function GetThreadCount: Integer;
      procedure SetThreadCount(aValue: Integer);
      function OnListEvent(Parent: IList<ILoadSetup>; aType: TListEventType<ILoadSetup>): Boolean;
    public
      constructor Create;
      destructor Destroy; override;
  end;

type

//  TLoadSetup = class(TBaseSettings, ILoadSetup)
  TLoadSetup = class(TCommonSetup, ILoadSetup)
    private
      FData: array[TLoadData] of string;
    protected
      function GetLoadData(aLoadData: TLoadData): string;
      procedure SetLoadData(aLoadData: TLoadData; aValue: string);
    constructor Create;
    destructor Destroy; override;
  end;


{ TSettings }

constructor TSettings.Create;
begin
  inherited Create;
  FLoadList:=TListFab.List<ILoadSetup>;
  FLoadList.Event:=OnListEvent;
end;

destructor TSettings.Destroy;
begin

  inherited;
end;

function TSettings.GetLoadList: IList<ILoadSetup>;
begin
  Result:=FLoadList;
end;

function TSettings.GetThreadCount: Integer;
begin
  Result:=FThread;
end;

function TSettings.OnListEvent(Parent: IList<ILoadSetup>;
  aType: TListEventType<ILoadSetup>): Boolean;
begin
  if Assigned(Event) then
    Result:=Event(Self, tsetSettingChange)
  else
    Result:=True;
end;

procedure TSettings.SetThreadCount(aValue: Integer);
begin
  FThread:=aValue;
end;

{ TCommonSetup }

constructor TCommonSetup.Create;
begin
  inherited Create;
  FTry:=3;
  FThread:=5;
end;

function TCommonSetup.GetTryCount: Integer;
begin
  Result:=FTry;
end;

procedure TCommonSetup.SetTryCount(aValue: Integer);
begin
  FTry:=aValue;
end;

{ TLoadSetup }

constructor TLoadSetup.Create;
begin
  inherited Create;
end;

destructor TLoadSetup.Destroy;
begin

  inherited;
end;

function TLoadSetup.GetLoadData(aLoadData: TLoadData): string;
begin
  Result:=FData[aLoadData];
end;

procedure TLoadSetup.SetLoadData(aLoadData: TLoadData; aValue: string);
begin
  FData[aLoadData]:=aValue;
end;

{ TBaseSettings }

constructor TBaseSettings.Create;
begin
  inherited Create;
  FCommonSetup:=TCommonSetup.Create;
end;

function TBaseSettings.GetCommonSetup: ICommonSetup;
begin
  Result:=FCommonSetup;
end;

initialization

  RegicterSettingsFab(TSettings.Create,
                      function: ILoadSetup
                      begin
                        Result:=TLoadSetup.Create;
                      end);


end.
