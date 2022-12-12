unit graph;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DataFiles,FileDif,FileDifGlb;

type
  TGrafik = class(TForm)
    procedure plot;
    procedure replot;
    procedure MoveMouse(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure MouseClicked(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    function ChanToScreen (var chan:integer):Integer;
    function IntenToScreen (var spe:TSpectrum;inten:double):Integer;
    procedure ShowCoordinates;
    procedure Point (var p:TPoint);
    procedure Init1(Sender: TObject);
    procedure Init;
  private
    CursorChan,x0,x1,y0,y1: integer;
    CursorInten,CursorXnorm,CursorYnorm: double;
    CursorX,CursorY: integer;
    zx0,zx1,zy0,zy1:double;
    R: Trect;
    SpikePos,OldSpikePos:TPoint;
    ButtonDown: boolean;
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    ZoomSearchFrame: boolean;
    OldZoomCorner,ZoomCorner: TRect;
    imin,imax: integer;
//    yimin,yimax: double;
  end;
var
  Grafik: TGrafik;

implementation


{$R *.DFM}
{*****************************************************}
procedure TGrafik.Init;
begin
  x0:=5;
  y0:=5;
  x1:=grafik.ClientWidth-10;
  y1:=grafik.ClientHeight-10;
  r.left:=0;
  r.top:=0;
  r.right:=x1+10;
  r.bottom:=y1+10;
  buttonDown:=false;
end;
{*****************************************************}
procedure TGrafik.Init1(Sender: TObject);
begin
  init;
end;
{*****************************************************}
function TGrafik.ChanToScreen (var chan:integer):Integer;
var
  sx:double;
begin
    sx:=(chan-imin)/(imax-imin);
    ChanToScreen:=round(x0+x1*sx);
end;
{*****************************************************}
function TGrafik.IntenToScreen (var spe:TSpectrum;inten:double):Integer;
var
  sy: double;
begin
  with spe do begin
    sy:=(inten-yimin)/(yimax-yimin);
    IntenToScreen:=round(y0+y1*(1-sy))
  end;
end;
{*****************************************************}
procedure TGrafik.plot;
var
  i,i1: integer;
  begin
  if not SpectrumLoaded then exit;
  grafik.caption:=spectrum.name;
  init;
  Canvas.FillRect (r);
  Canvas.Pen.Color:=clBlack;
   //plot diff file
  if Show_File_Dif then begin
    if File_A_Scale then for i:=imin to imax do begin
      if (i=imin) then Canvas.MoveTo (ChanToScreen(i),IntenToScreen (File_A,spectrum.y[i]))
      else             Canvas.LineTo (ChanToScreen(i),IntenToScreen (File_A,spectrum.y[i]));
    end;
    if not File_A_Scale then for i:=imin to imax do begin
      if (i=imin) then Canvas.MoveTo (ChanToScreen(i),IntenToScreen (spectrum,spectrum.y[i]))
      else             Canvas.LineTo (ChanToScreen(i),IntenToScreen (spectrum,spectrum.y[i]));
    end;
  end;

   //plot File_A
  if Show_File_A then begin
    for i:=imin to imax do begin
      if (i=imin) then Canvas.MoveTo (ChanToScreen(i),IntenToScreen (File_A,File_A.y[i]))
      else             Canvas.LineTo (ChanToScreen(i),IntenToScreen (File_A,File_A.y[i]));
    end;
  end;

   //plot File_B
  Canvas.Pen.Color:=clRed;
  if Show_File_B then begin
    for i:=imin to imax do begin
       i1:=i+shift;
      if (i=imin) then Canvas.MoveTo (ChanToScreen(i1),IntenToScreen (File_A,File_B.y[i]*x))
      else             Canvas.LineTo (ChanToScreen(i1),IntenToScreen (File_A,File_B.y[i]*x));
    end;
  end;

end;
{*****************************************************}
procedure TGrafik.replot;
var
  i: integer;
begin
// with spectrum do begin
 if Show_File_A then with File_A do begin
    ymax:=y[imin];
    ymin:=y[imin];
    for i:=imin to imax do begin
      if ymax<y[i] then ymax:=y[i];
      if ymin>y[i] then ymin:=y[i];
    end;
    yimin:=ymin;
    yimax:=ymax;
  end;
 if Show_File_B then with File_B do begin
    ymax:=y[imin];
    ymin:=y[imin];
    for i:=imin to imax do begin
      if ymax<y[i] then ymax:=y[i];
      if ymin>y[i] then ymin:=y[i];
    end;
    yimin:=ymin;
    yimax:=ymax;
  end;
 if Show_File_Dif then with Spectrum do begin
    ymax:=y[imin];
    ymin:=y[imin];
    for i:=imin to imax do begin
      if ymax<y[i] then ymax:=y[i];
      if ymin>y[i] then ymin:=y[i];
    end;
    yimin:=ymin;
    yimax:=ymax;
  end;
  plot;
end;
{*****************************************************}
procedure TGrafik.Point (var p:TPoint);
begin
  with Canvas do begin
    MoveTo (p.x,p.y-1);
    LineTo (p.x,p.y+1);
  end;
end;
{***************************************************}
procedure TGrafik.FormPaint(Sender: TObject);
begin
  plot;
end;
{***************************************************}

procedure TGrafik.ShowCoordinates;
var
  s: string;
  lyy,intint: double;
begin
  if (CursorXnorm>=0) and (CursorXnorm<=1) and (CursorYnorm>=0) and (CursorYnorm<=1) then
   with spectrum do begin
    CursorChan:=round(imin+(imax-imin)*CursorXnorm);
    str (CursorChan:6,s);
    FileDifWnd.Channel.Text:=s;
    str (ei+(ef-ei)*(CursorChan-1)/(npts-1):6:3,s);
    FileDifWnd.EKin.Text:=s;
    str (excit-(ei+(ef-ei)*(CursorChan-1)/(npts-1)):6:3,s);
    FileDifWnd.EBind.Text:= s;
    CursorInten:=yimin+(yimax-yimin)*CursorYnorm;
    if abs(CursorInten)>1 then str (CursorInten:2:2,s) else str (CursorInten:12,s);
    FileDifWnd.MouseY.Text:=s;
    lyy:=y[CursorChan];
    if abs(lyy)>1 then str (lyy:2:2,s) else str (lyy:12,s);
    FileDifWnd.Counts.Text:=s;
    intint:=lyy/(scantime/npts);
    if abs(intint)>1 then str (intint:2:2,s) else str (intint:12,s);
    FileDifWnd.Intensity.Text:=s;
  end else
  begin
    FileDifWnd.Channel.Text:='';
    FileDifWnd.EKin.Text:=   '';
    FileDifWnd.EBind.Text:=  '';
    FileDifWnd.MouseY.Text:='';
    FileDifWnd.Counts.Text:='';
    FileDifWnd.Intensity.Text:='';
  end;
end;
{*****************************************************}
procedure TGrafik.MoveMouse(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  p: TPoint;
begin
  if not SpectrumLoaded then exit;
  CursorX:=x;
  CursorY:=y;
  CursorXnorm:=(x-x0)/(x1);
  CursorYnorm:=1-((y-y0)/(y1));
  ShowCoordinates;
    {Do Zooming}
  if ZoomSearchFrame then begin
    ZoomCorner.Right:=CursorX;
    ZoomCorner.Bottom:=CursorY;
    with OldZoomCorner do Canvas.Rectangle (Left,Top,Right,Bottom);
    with ZoomCorner do begin
      Right:=CursorX;
      Bottom:=CursorY;
      Canvas.Rectangle (Left,Top,Right,Bottom);
    end;
    OldZoomCorner:=ZoomCorner;
  end;
end;
 {***********************************************************************}
procedure TGrafik.MouseClicked(Sender: TObject);
var
  EKintmp,ISSMass: double;
  st: string;
begin
end;
{***************************************************}
{***************************************************}

end.
