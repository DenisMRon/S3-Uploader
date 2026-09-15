unit ISetingsValue;

interface

uses interfaces, System.SysUtils;

function GetSettingsFab: ISettingsFab;
procedure RegicterSettingsFab(aSettings: ISettings; aNewLoad: TFunc<ILoadSetup>);

implementation

var FSettingsFab: ISettingsFab;


type

  TSettingsFab = class(TInterfacedObject, ISettingsFab)
    private
      FSettings: ISettings;
      FNewLoad: TFunc<ILoadSetup>;
    protected
      function GetSettings: ISettings;
      function NewLoadSetup: ILoadSetup;
    public
      constructor Create(aSettings: ISettings; aNewLoad: TFunc<ILoadSetup>);
  end;

{ TSettingsFab }

constructor TSettingsFab.Create(aSettings: ISettings;
  aNewLoad: TFunc<ILoadSetup>);
begin
  inherited Create;
  FSettings:=aSettings;
  FNewLoad:=aNewLoad;
end;

function TSettingsFab.GetSettings: ISettings;
begin
  Result:=FSettings;
end;

function TSettingsFab.NewLoadSetup: ILoadSetup;
begin
  if Assigned(FNewLoad) then
    Result:=FNewLoad()
  else
    raise Exception.Create('FNewLoadSetup не задан!');
end;

procedure RegicterSettingsFab(aSettings: ISettings; aNewLoad: TFunc<ILoadSetup>);
begin
  FSettingsFab:=TSettingsFab.Create(aSettings, aNewLoad);
end;

function GetSettingsFab: ISettingsFab;
begin
  if Assigned(FSettingsFab) then
    Result:=FSettingsFab
  else
    raise Exception.Create('FSettingsFab не задан!');
end;

end.
