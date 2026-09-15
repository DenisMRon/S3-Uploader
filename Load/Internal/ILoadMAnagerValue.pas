unit ILoadMAnagerValue;

interface

uses interfaces, System.SysUtils;

function GetLoadManagerFab: ILoadManagerFab;
procedure RegicterLoadManagerFab(aNewLoadManager: TFunc<ISettings, ILoadManager>);

implementation
var
  FLoadManagerFab: ILoadManagerFab;

type
  TLoadManagerFab = class(TInterfacedObject, ILoadManagerFab)
    private
      FNew: TFunc<ISettings, ILoadManager>;
    protected
      function NewLoadManager(aSettings: ISettings): ILoadManager;
    public
      constructor Create(aNewLoadManager: TFunc<ISettings, ILoadManager>);
  end;

function GetLoadManagerFab: ILoadManagerFab;
begin
  Result:=FLoadManagerFab;
end;

procedure RegicterLoadManagerFab(aNewLoadManager: TFunc<ISettings, ILoadManager>);
begin
  FLoadManagerFab:=TLoadManagerFab.Create(aNewLoadManager);
end;


{ TLoadManagerFab }

constructor TLoadManagerFab.Create(
  aNewLoadManager: TFunc<ISettings, ILoadManager>);
begin
  inherited Create;
  FNew:=aNewLoadManager;
end;

function TLoadManagerFab.NewLoadManager(aSettings: ISettings): ILoadManager;
begin
  Result:=FNew(aSettings);
end;

end.
