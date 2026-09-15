unit interfaces;

interface

uses model,
     IEvent, IList,
     System.SysUtils;

type

  ILoad =  interface;

  TOnEvent = TOnGenEvent<ILoad, TEventType>;

  IBaseLoad = interface(IEvents<ILoad, TEventType>)
  end;
  ILoad =  interface(IBaseLoad)
    function GetName: string;
    property Name: string read GetName;
    function GetSize: Int64;
    property Size: Int64 read GetSize;
    function GetProgress: Byte;
    property Progress: Byte read GetProgress;
    function GetStatus: TLoadStatus;
    property Status: TLoadStatus read GetStatus;
    function GetError: string;
    property Error: string read GetError;
    function Speed: Int64;
//    procedure SetOnEvent(aEvent: TOnEvent);
    procedure Start;
    procedure Stop;
  end;

  ILoadManager = interface
    function GetItems: IReadList<ILoad>;
    property Items: IReadList<ILoad> read GetItems;
    function Add(aLoad: ILoad): Integer;
  end;

  ICommonSetup = interface
    function GetTryCount: Integer;
    procedure SetTryCount(aValue: Integer);
    property TryCount: Integer read GetTryCount write SetTryCount;
  end;

  TLoadData = (tldName = 0, tldEndpoint, tldAccessKey, tldSecretkey, tldBucket, tldRegion);
  const
  LoadDataNames: array[TLoadData] of string = ('Имя',
                                               'endpoint',
                                               'access key',
                                               'secret key',
                                               'bucket',
                                               'Регион');
  type

//  ILoadSetup = interface(IBaseSettings)
  ILoadSetup = interface(ICommonSetup)
    function GetLoadData(aLoadData: TLoadData): string;
    procedure SetLoadData(aLoadData: TLoadData; aValue: string);
    property LoadData[Index: TLoadData]: string read GetLoadData write SetLoadData;
  end;

  ISettings = interface;
  IBaseSettings = interface(IEvents<ISettings, TSettingsEventType>)
    function GetCommonSetup: ICommonSetup;
    property CommonSetup: ICommonSetup read GetCommonSetup;
  end;

  ISettings = interface(IBaseSettings)
    function GetThreadCount: Integer;
    procedure SetThreadCount(aValue: Integer);
    property ThreadCount: Integer read GetThreadCount write SetThreadCount;

    function GetLoadList: IList<ILoadSetup>;
    property LoadList: IList<ILoadSetup> read GetLoadList;
  end;

  IHistoryEvents = interface
    function GetSize: Int64;
    property Size: Int64 read GetSize;
    function GetStatus: TLoadStatus;
    property Status: TLoadStatus read GetStatus;
    function GetTime: TDateTime;
    property LoadTime: TDateTime read GetTime;
  end;

  IHistoryItem = interface
    function GetData: TDateTime;
    property Data: TDateTime read GetData;
    function GetFile: string;
    property FileName: string read GetFile;
    function GetSize: Int64;
    property Size: Int64 read GetSize;
    function GetEvents: IReadList<IHistoryEvents>;
    property Events: IReadList<IHistoryEvents> read GetEvents;
    function Add(const aSize: Int64; const aStatus: TLoadStatus): Integer;
  end;

  IHistory = interface(IReadList<IHistoryItem>)
    function Add(aFile: string; aSize: Int64): Integer;
    function AddEvent(aIndex: Integer; const aSize: Int64; const aStatus: TLoadStatus): Integer;
    procedure Delete(Index: Integer);
    procedure Clear;
    procedure SaveToFile(aFile: string);
    procedure LoadFromFile(aFile: string);
  end;

  ISettingsFab = interface
    function GetSettings: ISettings;
    property Settings: ISettings read GetSettings;
    function NewLoadSetup: ILoadSetup;
  end;

  ILoadFab = interface
    function NewLoad(aSettings: ISettings; aIdx: Integer): ILoad;
  end;

  ILoadManagerFab = interface
    function NewLoadManager(aSettings: ISettings): ILoadManager;
  end;

  IHistoryFab = interface
    function NewHistory: IHistory;
  end;

  function SettingsFab: ISettingsFab;
  function LoadFab: ILoadFab;
  function LoadManagerFab: ILoadManagerFab;
  function HistoryFab: IHistoryFab;

implementation

uses ISetingsValue, ILoadValue, ILoadMAnagerValue, IHistoryValue;

function SettingsFab: ISettingsFab;
begin
  Result:=GetSettingsFab;
end;

function LoadFab: ILoadFab;
begin
  Result:=GetLoadFab;
end;

function LoadManagerFab: ILoadManagerFab;
begin
  Result:=GetLoadManagerFab;
end;

function HistoryFab: IHistoryFab;
begin
  Result:=GetHistoryFab;
end;

end.
