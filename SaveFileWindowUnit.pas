unit SaveFileWindowUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,DataFiles,FileDifGlb, StdCtrls;

type
  TSaveFileWindow = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    BEIEdt: TEdit;
    BEFEdt: TEdit;
    SaveBt: TButton;
    Button1: TButton;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SaveBtClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    ls:TSpectrum;
  end;

var
  SaveFileWindow: TSaveFileWindow;

implementation

{$R *.dfm}
//********************************************************************************
procedure TSaveFileWindow.Button1Click(Sender: TObject);
begin
  close;
end;
//********************************************************************************
procedure TSaveFileWindow.FormShow(Sender: TObject);
begin
  with spectrum do BEiedt.Text:=formatFloat('#.###',(excit-ei));
  with spectrum do BEfedt.Text:=formatFloat('#.###',(excit-ef));
end;
//********************************************************************************

procedure TSaveFileWindow.SaveBtClick(Sender: TObject);
var
  io:boolean;
  i,ni,nf:integer;
begin
  spectrum.copy(ls);
  SaveDialog1.Execute;
  with ls do begin
    name:=SaveDialog1.fileName;
    ei:=excit-strtofloat(BEiEdt.Text);
    ef:=excit-strtofloat(BEfEdt.Text);
    ni:=round (1+(ei-spectrum.ei)/(spectrum.ef-spectrum.ei)*(spectrum.npts-1));
    nf:=round (1+(ef-spectrum.ei)/(spectrum.ef-spectrum.ei)*(spectrum.npts-1));
    npts:=nf-ni+1;
    scantime:=spectrum.scanTime*(npts-1)/(spectrum.npts-1);
    for i:=1 to npts do y[i]:=spectrum.y[i+ni-1];
    io:=FileExists (Name);
    if io=true then begin
      if Application.MessageBox ('File exists already .. Overwrite it?','File Save As',mb_OKCancel or mb_IconExclamation)
      =id_ok then io:=false;
    end;
    if not io then Store;
  end;
  close;
end;
//********************************************************************************
procedure TSaveFileWindow.FormCreate(Sender: TObject);
begin
  ls:=TSpectrum.create;
end;
//********************************************************************************
//********************************************************************************

end.
