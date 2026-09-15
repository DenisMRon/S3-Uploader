unit ILoadValue;

interface

uses interfaces, System.SysUtils;

function GetLoadFab: ILoadFab;
procedure RegicterLoadFab(aNewLoad: TFunc<ISettings, Integer, ILoad>);

implementation

var FLoadFab: ILoadFab;

type

  TLoadFab = class(TInterfacedObject, ILoadFab)
    private
      FNewLoad: TFunc<ISettings, Integer, ILoad>;
    protected
      function NewLoad(aSettings: ISettings; aIdx: Integer): ILoad;
    public
      constructor Create(aNewLoad: TFunc<ISettings, Integer, ILoad>);
  end;

{ TLoadFab }

constructor TLoadFab.Create(aNewLoad: TFunc<ISettings, Integer, ILoad>);
begin
  inherited Create;
  FNewLoad:=aNewLoad;
end;

function TLoadFab.NewLoad(aSettings: ISettings; aIdx: Integer): ILoad;
begin
  if Assigned(FNewLoad) then
    Result:=FNewLoad(aSettings, aIdx)
  else
    raise Exception.Create('FNewLoadSetup не задан!');
end;

function GetLoadFab: ILoadFab;
begin
  if Assigned(FLoadFab) then
    Result:=FLoadFab
  else
    raise Exception.Create('FLoadFab не задан!');
end;

procedure RegicterLoadFab(aNewLoad: TFunc<ISettings, Integer, ILoad>);
begin
  FLoadFab:=TLoadFab.Create(aNewLoad);
end;
end.
