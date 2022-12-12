unit FileDif;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, ExtCtrls,FileDifGlb,DataFiles,FilDifLib, ComCtrls;

type
  TFileDifWnd = class(TForm)
    OpenFileABt: TButton;
    FileAEdt: TEdit;
    OpenFileBBt: TButton;
    FileBEdt: TEdit;
    Panel1: TPanel;
    SaveFileBt: TButton;
    SaveWinBt: TButton;
    MainMenu1: TMainMenu;
    Exit1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel3: TPanel;
    Channel: TEdit;
    EKin: TEdit;
    EBind: TEdit;
    MouseY: TEdit;
    Counts: TEdit;
    Intensity: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    SaveDialog1: TSaveDialog;
    GroupBox1: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    ApplyABt: TButton;
    BEiAEdt: TEdit;
    BEfAEdt: TEdit;
    nptsAEdt: TEdit;
    GroupBox2: TGroupBox;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    ApplyBBt: TButton;
    BEiBEdt: TEdit;
    BEfBEdt: TEdit;
    NPTSBEdt: TEdit;
    RestoreABt: TButton;
    RestoreBBt: TButton;
    SaveFileBBt: TButton;
    Panel4: TPanel;
    FileACheck: TCheckBox;
    FileDifCheck: TCheckBox;
    GroupBox3: TGroupBox;
    FileBUd: TUpDown;
    FileBRL: TUpDown;
    ShiftEdt: TEdit;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    XEdt: TEdit;
    Label2: TLabel;
    DXEdt: TEdit;
    FileBCheck: TCheckBox;
    GroupBox5: TGroupBox;
    FileAScBt: TRadioButton;
    SubtrScBt: TRadioButton;
    Help1: TMenuItem;
    procedure Exit1Click(Sender: TObject);
    procedure OpenFileABtClick(Sender: TObject);
    procedure OpenFileBBtClick(Sender: TObject);
    procedure XEdtExit(Sender: TObject);
    procedure DXEdtExit(Sender: TObject);
    procedure SaveFileBtClick(Sender: TObject);
    procedure SaveWinBtClick(Sender: TObject);
    procedure ApplyABtClick(Sender: TObject);
    procedure RestoreABtClick(Sender: TObject);
    procedure ApplyBBtClick(Sender: TObject);
    procedure RestoreBBtClick(Sender: TObject);
    procedure FileBCheckClick(Sender: TObject);
    procedure SaveFileBBtClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FileBUdClick(Sender: TObject; Button: TUDBtnType);
    procedure FileBRLClick(Sender: TObject; Button: TUDBtnType);
    procedure FileACheckClick(Sender: TObject);
    procedure FileDifCheckClick(Sender: TObject);
    procedure SubtrScBtClick(Sender: TObject);
    procedure FileAScBtClick(Sender: TObject);
    procedure XEdtKeyPress(Sender: TObject; var Key: Char);
    procedure DXEdtKeyPress(Sender: TObject; var Key: Char);
    procedure ShiftEdtKeyPress(Sender: TObject; var Key: Char);
    procedure ShiftEdtExit(Sender: TObject);
    procedure Help1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FileDifWnd: TFileDifWnd;

implementation

uses graph, SaveFileWindowUnit, HelpUnit;


{$R *.DFM}

{******************************************************************************************************}
procedure TFileDifWnd.Exit1Click(Sender: TObject);
begin
  close;
end;
{******************************************************************************************************}
procedure TFileDifWnd.OpenFileABtClick(Sender: TObject);
var
  LocalSpectrum: TSpectrum;
  i: integer;
  Send: TObject;
  AncientFormat: Boolean;
  s: string;

begin
  AncientFormat:=false;
  LocalSpectrum :=TSpectrum.Create;
  if OpenDialog1.Execute
  then begin
    LocalSpectrum.Name:=OpenDialog1.FileName;
    LocalSpectrum.load;
    if LocalSpectrum.io_error=1 then begin
      Application.MessageBox ('File not found','File Input Error',mb_OK or MB_IconStop);
    end;
    if LocalSpectrum.io_error=2 then begin
      LocalSpectrum.load_AncientY;
      if LocalSpectrum.io_error=2 then begin
        Application.MessageBox ('Wrong file format','File Input Error',mb_OK or MB_IconExclamation);
      end;
      AncientFormat:=true;
    end;
  end else exit;
  if LocalSpectrum.loaded then begin
    SpectrumLoaded:=true;
    LocalSpectrum.copy (File_A);
    LocalSpectrum.copy (File_A_Back);
    FileAEdt.Text:=File_A.Name;
    LocalSpectrum.copy (spectrum);
  end;
  LocalSpectrum.Free;
  with File_A do begin
    genei:=ei;
    genef:=ef;
    str (excit-ei:3:3,s);BeiAedt.text:=s;
    str (excit-ef:3:3,s);BefAedt.text:=s;
    str (npts:4,s);nptsAedt.text:=s;
  end;

  grafik.imin:=1;
  grafik.imax:=File_A.npts;
  FileACheck.Checked:=true;
  FileDifCheck.Checked:=false;
  grafik.replot;
                                 // should not be put under OpenFIleB because FileB is only opened once
  OpenFileBBt.Enabled:=true;
  end;
{******************************************************************************************************}

procedure TFileDifWnd.OpenFileBBtClick(Sender: TObject);
var
  LocalSpectrum: TSpectrum;
  i: integer;
  Send: TObject;
  AncientFormat: Boolean;
  s:string;
  begin
  AncientFormat:=false;
  LocalSpectrum :=TSpectrum.Create;
  if OpenDialog1.Execute then begin
    LocalSpectrum.Name:=OpenDialog1.FileName;
//    LocalSpectrum.Name:='vb.599.smo';
    LocalSpectrum.load;
    if LocalSpectrum.io_error=1 then begin
      Application.MessageBox ('File not found','File Input Error',mb_OK or MB_IconStop);
    end;
    if LocalSpectrum.io_error=2 then begin
      LocalSpectrum.load_AncientY;
      if LocalSpectrum.io_error=2 then begin
        Application.MessageBox ('Wrong file format','File Input Error',mb_OK or MB_IconExclamation);
      end;
      AncientFormat:=true;
    end;
  end;
  if LocalSpectrum.loaded then begin
    SpectrumLoaded:=false;                      //do not plot for FileB
    LocalSpectrum.copy (File_B);
    FileBEdt.Text:=File_B.Name;
    with File_b do begin
      for i:=1 to npts do file_b_y[i]:=y[i];
      for i:=-200 to 0 do file_b_y[i]:=y[1];
      for i:=npts to npts+200 do file_b_y[i]:=y[npts];
    end;
  end;
  LocalSpectrum.copy (File_B_Back);
  LocalSpectrum.Free;
  with File_B do begin
    str (excit-ei:3:3,s);BeiBedt.text:=s;
    str (excit-ef:3:3,s);BefBedt.text:=s;
    str (npts:4,s);nptsBedt.text:=s;
  end;

  File_A_Scale:=true;
  x:=0;
  XEdt.Text:='0';
  dx:=0.01;
  dxEdt.Text:='0.01';
  FileBUD.Position:=0;
  FileBRL.Position:=0;
  shift:=0;
  ShiftEdt.Text:='0';

  grafik.imin:=1;
  grafik.imax:=File_B.npts;
  FileBCheck.Checked:=true;       // does the Grafik.replot
  FileDifCheck.Checked:=false;
  FileASCBt.Checked:=true;
  SpectrumLoaded:=true;

  grafik.replot;
                                 // should not be put under OpenFIleB because FileB is only opened once
end;
{******************************************************************************************************}
procedure TFileDifWnd.XEdtExit(Sender: TObject);
var
  c: integer;
begin
  val (XEdt.Text,X,C);
  if C<>0 then XEdt.Text:='xxxxxx';
  grafik.replot;
end;
{******************************************************************************************************}
procedure TFileDifWnd.DXEdtExit(Sender: TObject);
var
  c: integer;
begin
  val (DXEdt.Text,DX,C);
  if C<>0 then DXEdt.Text:='xxxxxx';
end;
{******************************************************************************************************}
procedure TFileDifWnd.SaveFileBBtClick(Sender: TObject);
var
  filename: string;
  f: file;
  io: boolean;
begin
  begin
    filename:=Spectrum.name;
    SaveDialog1.filename:=filename;
    if SaveDialog1.Execute
    then begin
      filename:=SaveDialog1.fileName;
      io:=FileExists (FileName);
      if io=true then begin
        if Application.MessageBox ('File exists already .. Overwrite it?','File Save As',mb_OKCancel or mb_IconExclamation)
        =id_ok then io:=false;
      end;
      if io=false then begin
        File_B.Name:=filename;
        //include shift for storing, then remove shift for continuing work
         with file_b do begin
           ei:=ei+(ef-ei)/(npts-1)*shift;
           ef:=ef+(ef-ei)/(npts-1)*shift;
         end;
        if not File_B.store then Application.MessageBox ('Invalid Filename','File write error',mb_OK or mb_IconExclamation);
         with file_b do begin
           ei:=ei-(ef-ei)/(npts-1)*shift;
           ef:=ef-(ef-ei)/(npts-1)*shift;
         end;
      end;
    end;
  end;
end;
{******************************************************************************************************}

procedure TFileDifWnd.SaveFileBtClick(Sender: TObject);
var
  filename: string;
  f: file;
  io: boolean;
begin
  begin
    filename:=Spectrum.name;
    SaveDialog1.filename:=filename;
    if SaveDialog1.Execute
    then begin
      filename:=SaveDialog1.fileName;
      io:=FileExists (FileName);
      if io=true then begin
        if Application.MessageBox ('File exists already .. Overwrite it?','File Save As',mb_OKCancel or mb_IconExclamation)
        =id_ok then io:=false;
      end;
      if io=false then begin
        Spectrum.Name:=filename;
        if not Spectrum.store then
        Application.MessageBox ('Invalid Filename','File write error',mb_OK or mb_IconExclamation);
      end;
    end;
  end;
end;
{******************************************************************************************************}
procedure TFileDifWnd.SaveWinBtClick(Sender: TObject);
var
  filename: string;
  f: file;
  io: boolean;
  i: integer;
begin
  SaveFileWindow.ShowModal;
end;

{******************************************************************}
procedure TFileDifWnd.ApplyABtClick(Sender: TObject);
var
  s: string;
  newNpts,io: integer;
  mergeI,mergeF: double;
begin
  with file_a do begin
    val (BEiAEdt.Text,mergeI,io);
    if io=0 then mergeI:=excit-mergeI else begin
      mergeI:=ei;
     end;
    val (BEFAEdt.Text,MergeF,io);
    if io=0 then mergef:=excit-MergeF else begin
      mergeF:=ef;
    end;

    val (nptsAEdt.Text,newNpts,io);
    if io<>0 then begin
      newNpts:=npts;
      NptsAEdt.Text:='xxxxx';
    end;
  end;
  Merge (File_A,MergeI,MergeF);
  InterPolate (File_A,NewNpts);
  file_A.copy (spectrum);
  with grafik do begin
    imin:=1;
    imax:=spectrum.npts;
    grafik.replot;
  end;

  with spectrum do begin
    genei:=ei;
    genef:=ef;
    str (excit-ei:3:3,s);BeiAedt.text:=s;
    str (excit-ef:3:3,s);BefAedt.text:=s;
    str (npts:4,s);nptsAedt.text:=s;
  end;
end;
{******************************************************************}

procedure TFileDifWnd.RestoreABtClick(Sender: TObject);
var  s: string;
begin
  file_A_Back.copy (file_A);
  file_A.copy (spectrum);
  with grafik do begin
    imin:=1;
    imax:=spectrum.npts;
    grafik.replot;
  end;

  with spectrum do begin
    genei:=ei;
    genef:=ef;
    str (excit-ei:3:3,s);BeiAedt.text:=s;
    str (excit-ef:3:3,s);BefAedt.text:=s;
    str (npts:4,s);nptsAedt.text:=s;
  end;

end;
{******************************************************************}
{******************************************************************}
{******************************************************************}

procedure TFileDifWnd.ApplyBBtClick(Sender: TObject);
var
  s: string;
  newNpts,io: integer;
  mergeI,mergeF: double;
begin
  with file_B do begin
    val (BEiBEdt.Text,mergeI,io);
    if io=0 then mergeI:=excit-mergeI else begin
      mergeI:=ei;
     end;
    val (BEFBEdt.Text,MergeF,io);
    if io=0 then mergef:=excit-MergeF else begin
      mergeF:=ef;
    end;

    val (nptsBEdt.Text,newNpts,io);
    if io<>0 then begin
      newNpts:=npts;
      NptsBEdt.Text:='xxxxx';
    end;
  end;
  Merge (File_B,MergeI,MergeF);
  InterPolate (File_B,NewNpts);
  with File_B do begin
    str (excit-ei:3:3,s);BeiBedt.text:=s;
    str (excit-ef:3:3,s);BefBedt.text:=s;
    str (npts:4,s);nptsBedt.text:=s;
  end;
end;
{******************************************************************}
procedure TFileDifWnd.RestoreBBtClick(Sender: TObject);
var  s: string;
begin
  file_B_Back.copy (file_B);
  with File_B do begin
    genei:=ei;
    genef:=ef;
    str (excit-ei:3:3,s);BeiAedt.text:=s;
    str (excit-ef:3:3,s);BefAedt.text:=s;
    str (npts:4,s);nptsAedt.text:=s;
  end;
end;
{******************************************************************}
procedure TFileDifWnd.FileBCheckClick(Sender: TObject);
begin
  Show_File_B:=FileBCheck.Checked;
  x:=StrToFloat(XEdt.text);
  Grafik.replot;
end;
{******************************************************************}
procedure TFileDifWnd.FormShow(Sender: TObject);
begin
  //OpenFileBBtClick (Sender);
end;
{******************************************************************}
procedure TFileDifWnd.FileBUdClick(Sender: TObject; Button: TUDBtnType);
var
  i:integer;
begin
  x:=StrToFloat (Xedt.Text);
  dx:=StrToFloat (dXedt.Text);
  if Button=BtNext then x:=x+dx;
  if Button=BtPrev then x:=x-dx;
  XEdt.Text:=formatFloat ('0.000',x);
  spectrum.current:=x;
  for i:=1 to spectrum.npts do spectrum.y[i]:=file_a.y[i]-x*file_b_y[i-shift];
  grafik.replot;
end;
{******************************************************************}
procedure TFileDifWnd.FileBRLClick(Sender: TObject; Button: TUDBtnType);
var
  i:integer;
begin
  if Button=BTPrev then dec (shift);
  if Button=BTNext then inc (shift);
  spectrum.voltage:=shift;
  ShiftEdt.Text:=formatFloat ('0',shift);;
  for i:=1 to spectrum.npts do spectrum.y[i]:=file_a.y[i]-x*file_b_y[i-shift];
  grafik.replot;
end;
{******************************************************************}
procedure TFileDifWnd.FileACheckClick(Sender: TObject);
begin
  Show_File_A:=FileACheck.Checked;
  grafik.replot;
end;
{******************************************************************}
procedure TFileDifWnd.FileDifCheckClick(Sender: TObject);
var
  i:integer;
begin
  Show_File_Dif:=FileDifCheck.Checked;
  spectrum.current:=x;
  for i:=1 to spectrum.npts do spectrum.y[i]:=file_a.y[i]-x*file_b_y[i-shift];
  grafik.replot;
end;
{******************************************************************}
procedure TFileDifWnd.SubtrScBtClick(Sender: TObject);
begin
  File_A_Scale:=not SubtrScBt.checked;
  grafik.replot;
end;
{******************************************************************}
procedure TFileDifWnd.FileAScBtClick(Sender: TObject);
begin
  File_A_Scale:= FileAScBt.checked;
  grafik.replot;
end;
{******************************************************************}
procedure TFileDifWnd.XEdtKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then begin
    key:=#0;
    FileBUd.SetFocus;
  end;
end;
{******************************************************************}
procedure TFileDifWnd.DXEdtKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then begin
    key:=#0;
    FileBUd.SetFocus;
  end;
end;
{******************************************************************}
procedure TFileDifWnd.ShiftEdtKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then begin
    key:=#0;
    FileBRL.SetFocus;
  end;
end;
procedure TFileDifWnd.ShiftEdtExit(Sender: TObject);
var
  c,itmp:integer;
begin
  val (ShiftEdt.Text,itmp,C);
  if C=0 then begin
    shift:=itmp;
    grafik.replot;
  end else ShiftEdt.Text:='';
end;
{******************************************************************}

procedure TFileDifWnd.Help1Click(Sender: TObject);
begin
  HelpForm.Show;
end;

end.
