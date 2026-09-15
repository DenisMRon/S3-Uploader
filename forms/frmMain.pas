unit frmMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.StdCtrls, FMX.Controls.Presentation, FMX.TabControl,
  FMX.Edit, FMX.EditBox, FMX.SpinBox,
  interfaces, model,
  System.Rtti, FMX.Grid.Style, FMX.Grid, FMX.ScrollBox,
  System.Generics.Collections;

type
  TfMain = class(TForm)
    TabControl1: TTabControl;
    tiSettings: TTabItem;
    tiLoads: TTabItem;
    pMain: TPanel;
    tiHistory: TTabItem;
    bAddFile: TButton;
    bAddFolder: TButton;
    odAdd: TOpenDialog;
    lbLoads: TListBox;
    sbTryCnt: TSpinBox;
    lbDefaultTryCnt: TLabel;
    sbThreadCnt: TSpinBox;
    lThreadCount: TLabel;
    gLoads: TGrid;
    scName: TStringColumn;
    scSize: TStringColumn;
    pcProgress: TProgressColumn;
    scStatus: TStringColumn;
    scTime: TStringColumn;
    pStart: TPanel;
    bStart: TButton;
    bStop: TButton;
    lbHistory: TListBox;
    lbHistoryItems: TListBox;
    procedure bAddFileClick(Sender: TObject);
    procedure bAddFolderClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure gLoadsGetValue(Sender: TObject; const ACol, ARow: Integer;
      var Value: TValue);
    procedure gLoadsCellClick(const Column: TColumn; const Row: Integer);
    procedure bStartClick(Sender: TObject);
    procedure bStopClick(Sender: TObject);
    procedure lbHistoryChange(Sender: TObject);
    procedure sbThreadCntChange(Sender: TObject);
  private
    { Private declarations }
    FSettings: ISettings;
    FLoadManager: ILoadManager;
    FHistory: IHistory;
    FLoadHistoryMap: TDictionary<ILoad, IHistoryItem>;
//    FLoads: TDictionary<Integer, ILoad>;

//    FLoadIndex: TDictionary<ILoad, Integer>;

  protected
    procedure AddLoad(aPath: string);
    procedure UpdateLoadList;
    function OnLoad(aLoad: ILoad; aType: TEventType): Boolean;
  public
    { Public declarations }
  end;

var
  fMain: TfMain;

implementation

uses
     frmLoadSettings;

{$R *.fmx}

procedure TfMain.AddLoad(aPath: string);
var L: ILoadSetup;
    vIdx: Integer;
    vLoad: ILoad;
begin
  fLoadSettings.LoadName:=aPath;
  if fLoadSettings.ShowModal = mrOk then
  begin
    L:=SettingsFab.NewLoadSetup;
//    L.CommonSetup.TryCount:=Round(fLoadSettings.sbTryCnt.Value);
    L.TryCount:=Round(fLoadSettings.sbTryCnt.Value);
    for var I:=Low(TLoadData) to High(TLoadData) do
      L.LoadData[I]:=fLoadSettings.LoadData[I];

    vIdx:=FSettings.LoadList.Add(L);
    vLoad:=LoadFab.NewLoad(FSettings, vIdx);
    vLoad.SetOnEvent(OnLoad);
    FLoadManager.Add(vLoad);
    vIdx:=FHistory.Add(vLoad.GetName, vLoad.GetSize);
    FLoadHistoryMap.Add(vLoad, FHistory.Items[vIdx]);
    OnLoad(vLoad, tetOnReady);
//    FLoads.Add(vIdx, vLoad);
//    FLoadIndex.Add(vLoad, vIdx);
  end;
  UpdateLoadList;
end;

procedure TfMain.bAddFileClick(Sender: TObject);
begin
  if odAdd.Execute then
    AddLoad(odAdd.Files.Text);
end;

procedure TfMain.bAddFolderClick(Sender: TObject);
var vPath: string;
begin
  if SelectDirectory('Выбор папки', ExtractFilePath(ParamStr(0)), vPath) then
    AddLoad(vPath);
end;

procedure TfMain.bStartClick(Sender: TObject);
begin
//  FLoads.Items[gLoads.Row].Start;
end;

procedure TfMain.bStopClick(Sender: TObject);
begin
//  FLoads.Items[gLoads.Row].Stop;
  FLoadManager.Items.Items[gLoads.Row].Stop
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
  FSettings:=SettingsFab.Settings;
  sbThreadCntChange(Self);
  FLoadManager:=LoadManagerFab.NewLoadManager(FSettings);
  FHistory:=HistoryFab.NewHistory;
  FLoadHistoryMap:=TDictionary<ILoad, IHistoryItem>.Create;
  //  FLoads:=TDictionary<Integer, ILoad>.Create;

//  FLoadIndex:=TDictionary<ILoad, Integer>.Create;
end;

procedure TfMain.FormDestroy(Sender: TObject);
begin
//  FreeAndNil(FLoadIndex);
//  FreeAndNil(FLoads);
  FreeAndNil(FLoadHistoryMap);
end;

procedure TfMain.gLoadsCellClick(const Column: TColumn; const Row: Integer);
begin
//  bStart.Enabled:=FLoads.Items[Row].Status = tlsReady;
//  bStop.Enabled:=FLoads.Items[Row].Status = tlsInProgress;
  bStop.Enabled:=FLoadManager.Items.Items[Row].Status = tlsInProgress;
end;

procedure TfMain.gLoadsGetValue(Sender: TObject; const ACol, ARow: Integer;
  var Value: TValue);
begin
  if aRow >= FLoadManager.Items.Count then
    Value:=EmptyStr
  else
  with FLoadManager.Items do
  if ACol = scName.Index then
    Value:=Items[aRow].GetName
  else
  if ACol = scSize.Index then
    Value:=Items[aRow].GetSize
  else
  if ACol = pcProgress.Index then
    Value:=Items[aRow].Progress
  else
  if ACol = scStatus.Index then
  begin
    case Items[aRow].Status of
      tlsReady: Value:='Готов к запуску';
      tlsSetup: Value:='Подключение';
      tlsInProgress: Value:='Загружается';
      tlsDone: Value:='Успешно завершен';
      tlsStop: Value:='Прерван';
    end;
  end;
end;

procedure TfMain.lbHistoryChange(Sender: TObject);
  function HIEventsToStr(aEvents: IHistoryEvents): string;
  begin
    with aEvents do
      Result:=DateTimeToStr(LoadTime) + ' ' +
              IntToStr(Size) + ' ' +
              TLoadStatusName[Status] + ' ' +
              Error;

  end;
begin
  with lbHistoryItems do
  try
    BeginUpdate;
    Clear;
    if lbHistory.ItemIndex > -1 then
      for var I:=0 to FHistory.Items[lbHistory.ItemIndex].Events.Count - 1 do
        Items.Add(HIEventsToStr(FHistory.Items[lbHistory.ItemIndex].Events.Items[I]));
  finally
    EndUpdate;
  end;
end;

function TfMain.OnLoad(aLoad: ILoad; aType: TEventType): Boolean;
var vHI: IHistoryItem;
begin


  if FLoadHistoryMap.TryGetValue(aLoad, vHI) then
    if aLoad.Status <> tlsError then
      vHI.Add(aLoad.Size, aLoad.Status)
    else
      vHI.Add(aLoad.Size, aLoad.Error);
//  lbHistory.Align

  UpdateLoadList;

  Result:=True;
end;

procedure TfMain.sbThreadCntChange(Sender: TObject);
begin
  FSettings.ThreadCount:=Round(sbThreadCnt.Value);
end;

procedure TfMain.UpdateLoadList;
var vIndex: integer;
begin
  lbLoads.BeginUpdate;
  try
    lbLoads.Clear;
    for var I:=0 to FSettings.LoadList.Count - 1 do
      lbLoads.Items.Add(FSettings.LoadList.Items[I].LoadData[tldName]);
  finally
    lbLoads.EndUpdate;
  end;

  gLoads.BeginUpdate;
  try
    gLoads.RowCount:=FLoadManager.Items.Count;
  finally
    gLoads.EndUpdate;
  end;

  with lbHistory do
  try
    BeginUpdate;
    vIndex:=ItemIndex;
    Clear;
    for var I:=0 to FHistory.Count - 1 do
      Items.Add(FHistory.Items[I].FileName + ': ' + IntToStr(FHistory.Items[I].Size));

    if vIndex in [0..Count - 1] then
      ItemIndex:=vIndex;
  finally
    EndUpdate;
  end;


end;

end.
