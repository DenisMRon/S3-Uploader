unit IEventObject;

interface

uses IEvent;

type

  TEvents<TParent; TType> = class(TInterfacedObject, IEvents<TParent, TType>)
    private
      FEvent: TOnGenEvent<TParent, TType>;
    protected
      procedure SetOnEvent(aEvent: TOnGenEvent<TParent, TType>);
      function GetOnEvent: TOnGenEvent<TParent, TType>;
      property Event: TOnGenEvent<TParent, TType> read GetOnEvent write SetOnEvent;
    public
  end;

implementation

{ TEvents<TParent, TType> }

function TEvents<TParent, TType>.GetOnEvent: TOnGenEvent<TParent, TType>;
begin
  Result:=FEvent;
end;

procedure TEvents<TParent, TType>.SetOnEvent(
  aEvent: TOnGenEvent<TParent, TType>);
begin
  FEvent:=aEvent;
end;

end.
