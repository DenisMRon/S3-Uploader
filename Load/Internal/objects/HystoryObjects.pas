unit HystoryObjects;

interface

uses interfaces, model,
    IList, IListObj,
    System.Generics.Collections;

type

  THistoryEvents = class(TInterfacedObject, IHistoryEvents)
    private
      FSize: Int64;
      FStatus: TLoadStatus;
      FTime: TDateTime;
      FError: string;
    protected
      function GetSize: Int64;
      function GetStatus: TLoadStatus;
      function GetTime: TDateTime;
      function GetError: string;
    public
      constructor Create(const aSize: Int64; const aStatus: TLoadStatus; const aError: string = ''; const aTime: TDateTime = 0);
  end;

  TAddItemFunc = reference to function (const aSize: Int64; const aStatus: TLoadStatus): Integer;
  TNewItemResult = record
    Item: IHistoryItem;
    AddFunc: TAddItemFunc;
  end;

  THistoryItem = class(TInterfacedObject, IHistoryItem)
    private
      FData: TDateTime;
      FFile: string;
      FSize: Int64;
      FCntr: IList<IHistoryEvents>;
      FEvents: IReadList<IHistoryEvents>;
    protected
      function GetData: TDateTime;
      function GetFile: string;
      function GetSize: Int64;
      function GetEvents: IReadList<IHistoryEvents>;
      function Add(const aSize: Int64; const aStatus: TLoadStatus): Integer; overload;
      function Add(const aSize: Int64; const aError: string): Integer; overload;
    public
      constructor Create(aFile: string; aSize: Int64; aData: TDateTime = 0);
      class function NewItem(aFile: string; aSize: Int64; aData: TDateTime = 0): TNewItemResult;
  end;

  THistory = class(TReadList<IHistoryItem>, IHistory)
    private
      FAddItems: TDictionary<Integer, TAddItemFunc>;
    protected
      function Add(aFile: string; aSize: Int64): Integer;
      function AddEvent(aIndex: Integer; const aSize: Int64; const aStatus: TLoadStatus): Integer;
      procedure Delete(Index: Integer);
      procedure Clear;
      procedure SaveToFile(aFile: string);
      procedure LoadFromFile(aFile: string);
    public
      constructor Create; reintroduce;
      destructor Destroy; override;
  end;


implementation

uses System.SysUtils, IHistoryValue;

{ THistoryEvents }

constructor THistoryEvents.Create(const aSize: Int64;
  const aStatus: TLoadStatus; const aError: string; const aTime: TDateTime);
begin
  inherited Create;
  FSize:=aSize;
  FStatus:=aStatus;
  FError:=aError;
  if aTime = 0 then
    FTime:=Now
  else
    FTime:=aTime;
end;

function THistoryEvents.GetError: string;
begin
  Result:=FError;
end;

function THistoryEvents.GetSize: Int64;
begin
  Result:=FSize;
end;

function THistoryEvents.GetStatus: TLoadStatus;
begin
  Result:=FStatus;
end;

function THistoryEvents.GetTime: TDateTime;
begin
  Result:=FTime;
end;



{ THistoryItem }

function THistoryItem.Add(const aSize: Int64;
  const aStatus: TLoadStatus): Integer;
begin
  Result:=FCntr.Add(THistoryEvents.Create(aSize, aStatus));
end;

function THistoryItem.Add(const aSize: Int64; const aError: string): Integer;
begin
  Result:=FCntr.Add(THistoryEvents.Create(aSize, tlsError, aError));
end;

constructor THistoryItem.Create(aFile: string; aSize: Int64; aData: TDateTime);
begin
  inherited Create;
  FFile:=aFile;
  FSize:=aSize;
  if aData = 0 then
    FData:=Now
  else
    FData:=aData;

  FCntr:=TListFab.List<IHistoryEvents>;
  FEvents:=TListFab.ReadList<IHistoryEvents>(FCntr);
end;

function THistoryItem.GetData: TDateTime;
begin
  Result:=FData;
end;

function THistoryItem.GetEvents: IReadList<IHistoryEvents>;
begin
  Result:=FEvents;
end;

function THistoryItem.GetFile: string;
begin
  Result:=FFile;
end;

function THistoryItem.GetSize: Int64;
begin
  Result:=FSize;
end;

class function THistoryItem.NewItem(aFile: string; aSize: Int64;
  aData: TDateTime): TNewItemResult;
var vItem: THistoryItem;
begin
  vItem:=THistoryItem.Create(aFile, aSize, aData);
  with Result do
  begin
    AddFunc:=vItem.Add;
    Item:=vItem;
  end;
end;

{ THistory }

function THistory.Add(aFile: string; aSize: Int64): Integer;
begin
  with THistoryItem.NewItem(aFile, aSize) do
  begin
    Result:=inherited Add(Item);
    FAddItems.Add(Result, AddFunc);
  end;
end;

function THistory.AddEvent(aIndex: Integer; const aSize: Int64;
  const aStatus: TLoadStatus): Integer;
begin
  Result:=FAddItems.Items[aIndex](aSize, aStatus);
end;

procedure THistory.Clear;
begin
  inherited Clear;
end;

constructor THistory.Create;
begin
  inherited Create(nil);
  FAddItems:=TDictionary<Integer, TAddItemFunc>.Create;
end;

procedure THistory.Delete(Index: Integer);
begin
  inherited Delete(Index);
end;

destructor THistory.Destroy;
begin
  FreeAndNil(FAddItems);
  inherited;
end;

procedure THistory.LoadFromFile(aFile: string);
begin

end;

procedure THistory.SaveToFile(aFile: string);
begin

end;

initialization
  RegicterHistoryFab(function:IHistory
                     begin
                       Result:=THistory.Create;
                     end);

end.
