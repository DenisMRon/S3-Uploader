unit IListObj;

interface

uses IList,
     IEvent, IEventObject,
     System.Generics.Collections, System.SysUtils;

type

  TBaseList<T> = class(TEvents<IList<T>, TListEventType<T>>, IList<T>)
    private
      const
        EventMap: array[TCollectionNotification] of TListEvent =
        (tleAdding, tleAdded, tleExtracting,
         tleExtracted, tleDeleting, tleRemoved);
//      var
    private
      List: TList<T>;
    protected
      function Add(const aItem: T): Integer;
      procedure Delete(Index: Integer);
      procedure Clear;
      function GetCount: Integer;
      function GetItem(aIndex: Integer): T;
      procedure SetItem(aIndex: Integer; aValue: T);
      function IndexOf(const Value: T): Integer;
      procedure OnNotify(Sender: TObject; const Item: T;
                         Action: TCollectionNotification);
    public
      constructor Create;
      destructor Destroy; override;
  end;

//  TProxyList<T> = class(TInterfacedObject)
  TProxyList<T; TParent> = class(TEvents<TParent, TListEventType<T>>)
    private
      var List: IList<T>;
    protected
      function Add(const aItem: T): Integer;
      procedure Delete(Index: Integer);
      procedure Clear;
      function GetCount: Integer;
      function GetItem(aIndex: Integer): T;
      procedure SetItem(aIndex: Integer; aValue: T);
      function IndexOf(const Value: T): Integer;
    public
      constructor Create(aParent: IList<T>); reintroduce;
  end;

  TReadList<T> = class(TProxyList<T, IReadList<T>>, IReadList<T>)
  end;

  TRWList<T> = class(TProxyList<T, IList<T>>, IList<T>)
  end;

implementation

{ TBaseList<T> }

function TBaseList<T>.Add(const aItem: T): Integer;
begin
  Result:=List.Add(aItem);
end;

procedure TBaseList<T>.Clear;
begin
  List.Clear;
end;

constructor TBaseList<T>.Create;
begin
  inherited Create;
  List:=TList<T>.Create;
  List.OnNotify:=OnNotify;
end;

procedure TBaseList<T>.Delete(Index: Integer);
begin
  List.Delete(Index);
end;

destructor TBaseList<T>.Destroy;
begin
  FreeAndNil(List);
  inherited;
end;

function TBaseList<T>.GetCount: Integer;
begin
  Result:=List.Count;
end;

function TBaseList<T>.GetItem(aIndex: Integer): T;
begin
  Result:=List.Items[aIndex];
end;

function TBaseList<T>.IndexOf(const Value: T): Integer;
begin
  Result:=List.IndexOf(Value);
end;

procedure TBaseList<T>.OnNotify(Sender: TObject; const Item: T;
  Action: TCollectionNotification);
begin
  if Assigned(Event) then
    if not Event(Self, TListEventType<T>.Create(EventMap[Action], Item)) then
      Abort;  //
end;

procedure TBaseList<T>.SetItem(aIndex: Integer; aValue: T);
begin
  List.Items[aIndex]:=aValue;
end;

{ TProxyList }

function TProxyList<T, TParent>.Add(const aItem: T): Integer;
begin
  Result:=List.Add(aItem);
end;

procedure TProxyList<T, TParent>.Clear;
begin
  List.Clear;
end;

constructor TProxyList<T, TParent>.Create(aParent: IList<T>);
begin
  inherited Create;
  if Assigned(aParent) then
    List:=aParent
  else
    List:=TBaseList<T>.Create;
end;

procedure TProxyList<T, TParent>.Delete(Index: Integer);
begin
  List.Delete(Index);
end;

function TProxyList<T, TParent>.GetCount: Integer;
begin
  Result:=List.Count;
end;

function TProxyList<T, TParent>.GetItem(aIndex: Integer): T;
begin
  Result:=List.Items[aIndex];
end;

function TProxyList<T, TParent>.IndexOf(const Value: T): Integer;
begin
  Result:=List.IndexOf(Value);
end;

procedure TProxyList<T, TParent>.SetItem(aIndex: Integer; aValue: T);
begin
  List.Items[aIndex]:=aValue;
end;

end.
