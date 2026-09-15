program S3_MultiUploader;

uses
  System.StartUpCopy,
  FMX.Forms,
  model in 'Load\Internal\model.pas',
  interfaces in 'Load\Internal\interfaces.pas',
  IList in 'common\IList.pas',
  IListObj in 'common\IListObj.pas',
  ISettingsObject in 'Load\Internal\objects\ISettingsObject.pas',
  ISetingsValue in 'Load\Internal\ISetingsValue.pas',
  ILoadValue in 'Load\Internal\ILoadValue.pas',
  ILoadObject in 'Load\Internal\objects\ILoadObject.pas',
  frmMain in 'forms\frmMain.pas' {fMain},
  frmLoadSettings in 'forms\frmLoadSettings.pas' {fLoadSettings},
  LoadManagerObject in 'Load\Internal\objects\LoadManagerObject.pas',
  IEventObject in 'common\IEventObject.pas',
  IEvent in 'common\IEvent.pas',
  ILoadMAnagerValue in 'Load\Internal\ILoadMAnagerValue.pas',
  HystoryObjects in 'Load\Internal\objects\HystoryObjects.pas',
  IHistoryValue in 'Load\Internal\IHistoryValue.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TfLoadSettings, fLoadSettings);
  Application.Run;
end.
