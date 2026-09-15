unit IHistoryValue;

interface

uses interfaces, System.SysUtils;

function GetHistoryFab: IHistoryFab;
procedure RegicterHistoryFab(aNewHistory: TFunc<IHistory>);

implementation

var FHistoryFab: IHistoryFab;

function GetHistoryFab: IHistoryFab;
begin
  Result:=FHistoryFab;
end;

type

  THistoryFab = class(TInterfacedObject, IHistoryFab)
    private
      FNewHistory: TFunc<IHistory>;
    protected
      function NewHistory: IHistory;
    public
      constructor Create(aNewHistory: TFunc<IHistory>);
  end;

{ THistoryFab }

constructor THistoryFab.Create(aNewHistory: TFunc<IHistory>);
begin
  inherited Create;
  if Assigned(aNewHistory) then
    FNewHistory:=aNewHistory
  else
    raise Exception.Create('aNewHistory не задан!');
end;

function THistoryFab.NewHistory: IHistory;
begin
  if Assigned(FNewHistory) then
    REsult:=FNewHistory
  else
    raise Exception.Create('FNewHistory не задан!');
end;

procedure RegicterHistoryFab(aNewHistory: TFunc<IHistory>);
begin
  FHistoryFab:=THistoryFab.Create(aNewHistory);
end;

end.
