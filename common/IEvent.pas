unit IEvent;

interface

type
  TOnGenEvent<TParent; TType> = reference to function (Parent: TParent; aType: TType): Boolean;

  IEvents<TParent; TType> = interface
    procedure SetOnEvent(aEvent: TOnGenEvent<TParent, TType>);
    function GetOnEvent: TOnGenEvent<TParent, TType>;
    property Event: TOnGenEvent<TParent, TType> read GetOnEvent write SetOnEvent;
  end;



implementation

end.
