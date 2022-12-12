unit FilDifLib;
interface
uses DataFiles;

procedure tc (var spectrum: TSpectrum);
procedure satel (var spectrum: TSpectrum);
procedure interpolate (var spectrum: TSpectrum;var newnpts: integer);
procedure merge (var spectrum: TSpectrum;var mergeI,mergeF: double);

type  t2000=array [1..2000] of double;
{***********************************************************}
implementation
 procedure tc;

 var
  i,nw,l: integer;
  dx: single;
  buf,inten: ^T2000;

begin
new (buf);
new (inten);
with Spectrum do begin
  dx:=(ef-ei)/(npts-1);
  for i:=1 to npts do inten^[i]:=ei+(i-1)*dx;
  nw:=trunc((wf-ei)/dx+1);
  if nw<0 then nw:=0;
  for i:=1 to nw do buf^[i]:=1;
  if Epass>0 then begin
    l:=trunc((epass/2-ei+wf)/dx);
    if l<1 then l:=1;
    for i:=nw+1 to l-1 do buf^[i]:=EPass*EPass/(inten^[l]-wf);
    for i:=l to npts do   buf^[i]:=EPass*EPass/(inten^[i]-wf);
    end;
  if EPass=0 then begin
    for i:=nw+1 to npts do buf^[i]:=1;
    end;
  if EPass<0 then begin
    for i:=nw+1 to npts do buf^[i]:=(inten^[i]-wf)/sqr(-epass);
    end;
  for i:=1 to nw do buf^[i]:=buf^[nw+1];
  for i:=1 to npts do y[i]:=y[i]/buf^[i];
end;
dispose (inten);
dispose (buf);
end;
{*****************************************************************************}
procedure satel;
var
  i,j,limit,npunkte: integer;
  ratio,isat1,isat2,isat3: single;
  nsat1,nsat2,nsat3: integer;
  xx,buf,inten: ^t2000;

begin
new (xx);
new (buf);
new (inten);
with Spectrum do begin
  for i:=1 to npts do inten^[i]:=y[i];
  if abs(excit-1253.6)<0.1 then begin
    nsat1:=round(4.5*npts/(ef-ei));
    nsat2:=round(8.4*npts/(ef-ei));
    nsat3:=round(10.2*npts/(ef-ei));
    isat1:=0.012;
    isat2:=0.075;
    isat3:=0.07;
    end;
  if abs(excit-1486.6)<0.1 then begin
    nsat1:=round(5.2*npts/(ef-ei));
    nsat2:=round(9.8*npts/(ef-ei));
    nsat3:=round(11.5*npts/(ef-ei));
    isat1:=0.01;
    isat2:=0.05;
    isat3:=0.03;
    end;
  if (nsat3>npts) then begin
    dispose (inten);
    dispose (buf);
    dispose (xx);
    exit;
  end;

  limit:=nsat3+1;
  npunkte:=npts-limit+1;
  for i:=1 to npts do buf^[i]:=inten^[i]/(1+isat1+isat2+isat3);
  for i:=1 to 10 do begin
    for j:=limit to npts do xx[j]:=inten^[j]-(buf^[j-nsat1]*isat1+buf^[j-nsat2]*isat2+buf^[j-nsat3]*isat3);
    for j:=limit to npts do buf^[j]:=xx[j];
    end;
  ratio:=(xx[limit]+xx[limit+1]+xx[limit+2])/(y[limit]+y[limit+1]+y[limit+2]);
  for i:=1 to limit-1 do xx[i]:=y[i]*ratio;
  for i:=1 to npts do y[i]:=xx[i];
  end;
  dispose (xx);
end;
{*****************************************************************************}
procedure interpolate;
var
  i,index: integer;
  ex,ey,yold: ^t2000;

begin
new (ex);
new (ey);
new (yold);
with Spectrum do begin
  for i:=1 to npts do begin
    ex^[i]:=ei+(ef-ei)/(npts-1)*(i-1);
    yold^[i]:=y[i];
    end;
  for i:=1 to newnpts do ey^[i]:=ei+(ef-ei)/(newnpts-1)*(i-1);
  index:=1;
  for i:=1 to newnpts do begin
    while (ex^[index+1]<ey^[i]) and (index<npts) do inc (index);
    y[i]:=yold^[index]+(yold^[index+1]-yold^[index])*(ey^[i]-ex^[index])/(ex^[index+1]-ex^[index]);
    end;

  npts:=newnpts;
  end;
  dispose (yold);
  dispose (ey);
  dispose (ex);
end;
{*****************************************************************************}
procedure merge;
var i,i1,i2: integer;
begin
  with spectrum do begin
    if (mergeI<ei) or (mergeF>ef) then exit;
    i1:=1+trunc((mergeI-ei)/(ef-ei)*(npts-1));
    i2:=1+trunc((mergef-ei)/(ef-ei)*(npts-1));
    npts:=(i2-i1);
    for i:=i1 to i2 do y[i-i1+1]:=y[i];
    ei:=mergeI;
    ef:=mergeF;
  end;
end;
{*****************************************************************************}
{*****************************************************************************}

end.
