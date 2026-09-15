unit frmLoadSettings;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.EditBox, FMX.SpinBox, FMX.StdCtrls, FMX.Controls.Presentation,
  interfaces;

type
  TfLoadSettings = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    bOk: TButton;
    Panel2: TPanel;
    pTryCnt: TPanel;
    lbTryCnt: TLabel;
    sbTryCnt: TSpinBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FLoadDataEdit: array[TLoadData] of TEdit;
    FLoadName: string;
  protected
    function GetLoadData(aIndex: TLoadData): string;
    procedure SetLoadName(aValue: string);
  public
    property LoadData[Index: TLoadData]: string read GetLoadData;
    property LoadName: string read FLoadName write SetLoadName;

    { Public declarations }
  end;

var
  fLoadSettings: TfLoadSettings;

implementation

{$R *.fmx}

procedure TfLoadSettings.FormCreate(Sender: TObject);
var P: TPanel;
    L: TLabel;
    E: TEdit;
    vHeight: Single;
begin
  vHeight:=pTryCnt.AbsoluteHeight;
  for var I:=Low(LoadDataNames) to High(LoadDataNames) do
  begin
    P:=TPanel.Create(Self);
    P.Parent:=Self;
    P.Visible:=True;
    P.Height:=pTryCnt.Height;
    P.Width:=pTryCnt.Width;
    P.Position.X:=0;
    P.Position.Y:=vHeight * Ord(I);
    P.Align:=TAlignLayout.Top;
    L:=TLabel.Create(P);
    L.Parent:=P;
    L.Visible:=True;
    L.Position:=lbTryCnt.Position;
    L.Height:=lbTryCnt.Height;
    L.Width:=lbTryCnt.Width;
    L.Align:=lbTryCnt.Align;
    L.Anchors:=lbTryCnt.Anchors;
    L.Text:=LoadDataNames[I];

    E:=TEdit.Create(P);
    E.Parent:=P;
    E.Visible:=True;
    E.Position:=sbTryCnt.Position;
    E.Height:=sbTryCnt.Height;
    E.Width:=sbTryCnt.Width;
    E.Align:=sbTryCnt.Align;
    E.Anchors:=sbTryCnt.Anchors;
    E.ReadOnly:=(I = tldName);
    FLoadDataEdit[I]:=E;
  end;
end;

procedure TfLoadSettings.FormShow(Sender: TObject);
begin
  FLoadDataEdit[tldName].Text:=FLoadName;
end;

function TfLoadSettings.GetLoadData(aIndex: TLoadData): string;
begin
  Result:=FLoadDataEdit[aIndex].Text;
end;

procedure TfLoadSettings.SetLoadName(aValue: string);
begin
  FLoadDataEdit[tldName].Text:=aValue;
  FLoadDataEdit[tldName].Repaint;
  FLoadName:=aValue;
end;

end.
