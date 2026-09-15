program S3_MultiUploaderTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  TestILoadObject in 'TestILoadObject.pas',
  ILoadObject in '..\Load\Internal\objects\ILoadObject.pas',
  ILoadValue in '..\Load\Internal\ILoadValue.pas',
  interfaces in '..\Load\Internal\interfaces.pas',
  model in '..\Load\Internal\model.pas',
  IList in '..\common\IList.pas',
  IListObj in '..\common\IListObj.pas',
  ISetingsValue in '..\Load\Internal\ISetingsValue.pas',
  ISettingsObject in '..\Load\Internal\objects\ISettingsObject.pas',
  AWS.SDKUtils in 'C:\distr\aws_sdk_delphi\aws-sdk-delphi-master\Source\Core\AWS.SDKUtils.pas',
  IEvent in '..\common\IEvent.pas',
  IEventObject in '..\common\IEventObject.pas',
  IHistoryValue in '..\Load\Internal\IHistoryValue.pas',
  ILoadMAnagerValue in '..\Load\Internal\ILoadMAnagerValue.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

