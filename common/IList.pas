unit IList;

interface

uses IEvent;

type

  TListEvent = (tleAdding, tleAdded, tleExtracting, tleExtracted, tleDeleting, tleRemoved);
  TListEventType<T> = record
    EventType: TListEvent;
    Item: T;
    constructor Create(aType: TListEvent; aItem: T);
  end;
//  IRetList<T; TParent> = interface(IEvents<TParent, TListEvent>)
  IRetList<T; TParent> = interface(IEvents<TParent, TListEventType<T>>)
    function GetCount: Integer;
    property Count: Integer read GetCount;
    function GetItem(aIndex: Integer): T;
    property Items[Index: Integer]: T read GetItem;
    function IndexOf(const Value: T): Integer;
  end;

  IReadList<T> = interface;
  IBaseReadList<T> = interface(IRetList<T, IReadList<T>>)
  end;
  IReadList<T> = interface(IBaseReadList<T>)
  end;

//  IList<T> = interface(IReadList<T>)

  IList<T> = interface;
  IBaseList<T> = interface(IRetList<T, IList<T>>)
  end;
  IList<T> = interface(IBaseList<T>)
    function Add(const aItem: T): Integer;
    procedure SetItem(aIndex: Integer; aValue: T);
    property Items[Index: Integer]: T read GetItem write SetItem;
    procedure Delete(Index: Integer);
    procedure Clear;
  end;

  TListFab = class
    class function ReadList<T>(aParent: IList<T> = nil): IReadList<T>;
    class function List<T>(aParent: IList<T> = nil): IList<T>;
  end;

implementation

uses IListObj;

{ TListFab }

class function TListFab.List<T>(aParent: IList<T>): IList<T>;
begin
  Result:=TRWList<T>.Create(aParent);
end;

class function TListFab.ReadList<T>(aParent: IList<T>): IReadList<T>;
begin
  Result:=TReadList<T>.Create(aParent);
end;

{ TListEventType<T> }

constructor TListEventType<T>.Create(aType: TListEvent; aItem: T);
begin
  EventType:=aType;
  Item:=aItem;
end;

end.
