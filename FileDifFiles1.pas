unit FileDifFiles;
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, Grids, Calendar, Gauges;
type
  Analysis = (PE,AES,EELS);
  spectr_txt_type= string [255];
  Tspectr_name= String [255];

  TSpectrum = class (TObject)
  public
  DateTime:TDateTime;
  name: Tspectr_Name;         {Name of the File}
  npts: integer;              {Number of DataPoints}
  y:array[1..2000] of single;
  spe_type: analysis;         {Indicates type of Analsis
                                PE:   Photoelectron
                                AES:  Auger
                                EELS: Electron Energy Loss}
  AnaType,                    {Type of Analyser
                                0: DPCMA Livermore
                                1: CPA Livermore
                                2: CPA Karlsruhe EA10}
  Excit,                      {Generally: Excitation Energy}
  EPass,                      {Pass Energy of Analyser (eV)
                               0 : Auger Mode: No retardation}
  ei,                         {Initial Kinetic Energy}
  ef,                         {Final Kinetic Energy}
  wf,                         {Work Function}
  ScanTime,                  {Scan Time (sec)}

  bei,                        {Initial Binding Energy}
  bef,                        {Final Binding Energy}
  dei,                        {Initial Energy Loss}
  def,                        {Final Energy Loss}
  hv,                         {Excitation Radiation XPS/UPS}
  EPrim,                      {Energy of the Exciting Electrons AES/EELS}

  chamberpressure,            {Chamber Pressure}
  sampletemperature,          {Sample Temperature}
  voltage,                         {Synchrotron Beam Current}
  current,                       {Synchrotron Mesh Current}
  StartEnergy,                {StartEnergy (Keithley Electrometer)}
  ymin,ymax                   {Ymin and YMax}
  : single;

  adsorbate,                  {Description of adsorbate}
  sample,                     {Description of sample}
  co1,                        {Comment 1}
  co2,                        {Comment 2}
  co3                         {Comment 3}
  :spectr_txt_type;
  io_error: integer;          {1: file not found
                               2: file type error
                               3: other type of error   }
  loaded: boolean;
//GraphCoord: TGraphCoordinates;

  constructor create;
  procedure load_xrd;
  procedure load;virtual;
  procedure load_xy;virtual;
  procedure load_AncientY;virtual;
  function store:boolean;virtual;
  function store_XY:boolean;virtual;
  procedure copy (destination: TSpectrum);
  destructor Destroy;virtual;
  end;
var
  spectrum,File_A,File_B,File_A_Back,File_B_Back: TSpectrum;
  skipLines: Integer;
  FileModified: Boolean;

implementation
{************************************************************************}
constructor TSpectrum.create;
begin
  spe_type:=aes;
  anatype:=0;
  excit:=0;
  epass:=1;
  ei:=0;
  ef:=1;
  scantime:=0;
  bei:=1;
  bef:=0;
  startenergy:=0;
  npts:=0;
  loaded:=false;
  ymin:=0;
  ymax:=1;
end;
{************************************************************************}
destructor TSpectrum.Destroy;
begin
  inherited Destroy;
end;
{************************************************************************}

procedure TSpectrum.load_xrd;
type
  t2000=array[1..2000] of double;
var
  st:TFileStream;
  f: text;
  i,io: integer;
  xx,d: double;
  teta:^t2000;
begin
  new (teta);

  st:=TFileStream.Create (name,fmOpenRead);
    st.read (d,8);ei:=d;
    st.read (d,8);ef:=d;
    st.read (d,8);scanTime:=d;
    st.read (npts,4);
    st.read (teta^,8*npts);
    for i:=1 to npts do y[i]:=teta[i];

  st.free;
  dispose (teta);
  epass:=1;
  current:=0;
  voltage:=0;
  SampleTemperature:=-300;
  ChamberPressure:=0;
  sample:='';
  adsorbate:='';
  co1:='';
  co2:='';
  co3:='';
  StartEnergy:=-1;
  ymin:=y[1];
  ymax:=y[1];
  for i:=1 to npts do begin
    if ymin>y[i] then ymin:=y[i];
    if ymax<y[i] then ymax:=y[i];
  end;
  if ymax=ymin then begin
    ymax:=ymax+1;
    ymin:=ymin-1;
  end;
  io_error:=0;
  loaded:=true;
end;
{************************************************************************}

{procedure TSpectrum.load;
type
  fs = file of single;
var
  s: TFileStream;
   fka: text;
  i,io: integer;
  tmp: single;
  error: boolean;
  ch: char;
  st: string[15];
  buf,lei,lde,levpc,ltime,lnpts: double;
  st1: string;
  st8: string[8];
  index,lineindex: integer;
  error1: integer;
  ftime: longint;
  c: char;

begin
 // loadold;exit;
//  if OpenFormat.New_Format=1 then

}  {Input for SINGLE format!!!!!!!!}


{  begin }  {Input for SINGLE format!!!!!!!!}
{  try s:=TFileStream.Create (name,fmOpenRead) except
    loaded:=false;
    io_error:=1;
    exit;
  end;

  s.read (tmp,4);
  if (tmp>2) or (tmp<0) then
  begin
    loaded:=false;
    io_error:=2;
    s.free;
    exit;
  end;
  case trunc(tmp) of
    0: spe_type:=pe;
    1: spe_type:=aes;
    2: spe_type:=eels;
    end;
  if (tmp=0) or (tmp=1) or (tmp=2) then begin
    s.read (tmp,4);
    Excit:=tmp;
    if (spe_type=pe) then hv:=Excit;
    if (spe_type=aes) or (spe_type=eels) then eprim:=Excit;

    s.read (Anatype,4);
    s.read (EPass,4);
    s.read (Ei,4);
    s.read (Ef,4);
    s.read (ScanTime,4);
    s.read (tmp,4);
    npts:=trunc (tmp);
    wf:=0;
    s.read (y,4*npts);

    if s.position<s.size  then begin
      s.read (voltage,4);
      s.read (current,4);
      s.read (SampleTemperature,4);
      s.read (ChamberPressure,4);
      s.read(sample,80);
      s.read (adsorbate,80);
      s.read (co1,80);
      s.read (co2,80);
      s.read (co3,80);
    if s.position<s.size then s.read (StartEnergy,4) else StartEnergy:=-1;

    end else begin
      current:=0;
      voltage:=0;
      SampleTemperature:=-300;
      ChamberPressure:=0;
      sample:='';
      adsorbate:='';
      co1:='';
      co2:='';
      co3:='';
      StartEnergy:=-1;
    end;
    s.free;
    ymin:=y[1];
    ymax:=y[1];
    for i:=1 to npts do begin
      if ymin>y[i] then ymin:=y[i];
      if ymax<y[i] then ymax:=y[i];
    end;
    if ymax=ymin then begin
      ymax:=ymax+1;
      ymin:=ymin-1;
    end;
//  graphcoord.x1:=ei;
//  graphcoord.x2:=ef;
    buf:=(ymax-ymin)/50;
//  graphcoord.y1:=ymax+buf;
 // graphcoord.y2:=ymin-buf;
 // graphcoord.n1:=1;
//  graphcoord.n2:=npts;
    io_error:=0;
    loaded:=true;
    exit;
  end else begin
    s.free;
    assign (fka,name);                          {Karlsruhe - Sciavo}
{    reset (fka);
    read (fka,ch);
    if ch=#32 then begin
      reset (fka);
      readln (fka,lei,lde,levpc,ltime,lnpts);
      if abs(lde-levpc*lnpts)<1e-10 then begin
        spe_type:=pe;
        excit:=0;
        anatype:=2;
        epass:=1;
        ei:=lei;
        ef:=ei+lde;
        wf:=0;
        scantime:=ltime;
        npts:=trunc(lnpts);
        for i:=1 to npts do readln (fka,y[i]);
        ymin:=y[1];
        ymax:=y[1];
        for i:=1 to npts do begin
          if ymin>y[i] then ymin:=y[i];
          if ymax<y[i] then ymax:=y[i];
        end;
        if ymax=ymin then begin
          ymax:=ymax+1;
          ymin:=ymin-1;
        end;
//      graphcoord.x1:=ei;
//      graphcoord.x2:=ef;
        buf:=(ymax-ymin)/50;
//      graphcoord.y1:=ymax+buf;
//      graphcoord.y2:=ymin-buf;
//      graphcoord.n1:=1;
//      graphcoord.n2:=npts;
        current:=0;
        voltage:=0;
        SampleTemperature:=-300;
        ChamberPressure:=0;
        sample:='';
        adsorbate:='';
        co1:='';
        co2:='';
        co3:='';
        StartEnergy:=-1;
        close (fka);
        io_error:=0;
        loaded:=true;
        exit;
      end;
    end;
  end;
  io_error:=2;
  loaded:=false;
  close (fka);
end;
end;
}{************************************************************************}


procedure TSpectrum.load;
type
  tyy=array[1..1500]of array[1..5] of single;
var
  s: TFileStream;
  fka: text;
  i,j,io,StreamNpts: integer;
  tmp: single;
  error: boolean;
  ch: char;
  st: string[15];
  buf,lei,lde,levpc,ltime,lnpts: double;
  st1: string;
  st8: string[8];
  index,lineindex: integer;
  error1: integer;
  ftime: longint;
  c: char;
  yy:^tyy;
{..................................................................................}

procedure MCDExtractSum;
type
  TShortSpe=record
    ei,ef:single;
    npts:integer;
    y:array[1..2000] of single;
  end;

  t2000=array[1..2000] of single;
  tspe=array[1..5] of tShortSpe;
var
  ii,iindex,inpts1: integer;
  ex,ey,yold: ^t2000;
  denew,deold,EnOffset:double;
  spe:^tspe;
  i,j,newnpts:integer;
  newei,newef:double;
  de:single;
begin
  new (spe);
  for i:=1 to 5 do begin
    for j:=1 to npts do spe^[i].y[j]:=yy^[j,i];
    spe^[i].ei:=ei;
    spe^[i].ef:=ef;
    spe^[i].npts:=npts;
  end;
  de:=0.025*Epass;
  with spe^[2] do begin
    ei:=ei-de;
    ef:=ef-de;
  end;
  with spe^[3] do begin
    ei:=ei+de;
    ef:=ef+de;
  end;
  with spe^[4] do begin
    ei:=ei-2*de;
    ef:=ef-2*de;
  end;
  with spe^[5] do begin
    ei:=ei+2*de;
    ef:=ef+2*de;
  end;
 begin
    newei:=ei+2*de;
    newef:=ef-2*de;
    newnpts:=1+round((npts-1)/(ef-ei)*(newef-newei));
    for i:=1 to npts do y[i]:=0;
    ei:=newei;
    ef:=newef;
    npts:=newnpts;
 end;

{... Energy Interpolation ...}
new (ex);
new (ey);
new (yold);
  for i:=1 to 5 do begin
with spe^[i] do begin
  for ii:=1 to npts do begin
    ex^[ii]:=ei+(ef-ei)/(npts-1)*(ii-1);
    yold^[ii]:=y[ii];
    end;
  for ii:=1 to newnpts do ey^[ii]:=newei+(newef-newei)/(newnpts-1)*(ii-1);
  iindex:=1;
  for ii:=1 to newnpts do begin
    while (ex^[iindex+1]<ey^[ii]) and (iindex<npts) do inc (iindex);
    y[ii]:=yold^[iindex]+(yold^[iindex+1]-yold^[iindex])*(ey^[ii]-ex^[iindex])/(ex^[iindex+1]-ex^[iindex]);
    end;

  npts:=newnpts;
  ef:=newef;
  ei:=newei;
  end;
  end;
  dispose (yold);
  dispose (ey);
  dispose (ex);
 {.............................}

  for i:=1 to 5 do begin
    for j:=1 to npts do y[j]:=y[j]+spe^[i].y[j];
  end;
  dispose (spe);
end;
{**************************************************************************}

{..................................................................................}

begin

  begin   {Input for SINGLE format!!!!!!!!}
  try s:=TFileStream.Create (name,fmOpenRead) except
    loaded:=false;
    io_error:=1;
    exit;
  end;

  s.read (tmp,4);
  if (tmp>2) or (tmp<0) then
  begin
    loaded:=false;
    io_error:=2;
    s.free;
    exit;
  end;
//  ShortName:=ExtractFileName(Name);
  case trunc(tmp) of
    0: spe_type:=pe;
    1: spe_type:=aes;
    2: spe_type:=eels;
    end;
  if (tmp=0) or (tmp=1) or (tmp=2) then begin
    s.read (tmp,4);
    Excit:=tmp;
    if (spe_type=pe) then hv:=Excit;
    if (spe_type=aes) or (spe_type=eels) then eprim:=Excit;

    s.read (Anatype,4);
    s.read (EPass,4);
    s.read (Ei,4);
    s.read (Ef,4);
    s.read (ScanTime,4);
    s.read (tmp,4);
    npts:=trunc (tmp);
    wf:=0;
    StreamNpts:=(s.size-s.position-40) div 4;
    if StreamNpts=npts then begin
//      spectrumType:=SingleChan;
      s.read (y,4*npts);
    end;
    if StreamNpts=5*npts then begin
//      spectrumType:=MultiChan;
      new (yy);
      s.read(yy^,4*5*npts);
      MCDExtractSum;
      dispose (yy);
    end;

    if s.position<s.size  then begin
      s.read (voltage,4);
      s.read (current,4);
      s.read (SampleTemperature,4);
      s.read (ChamberPressure,4);
      s.read(sample,80);
      s.read (adsorbate,80);
      s.read (co1,80);
      s.read (co2,80);
      s.read (co3,80);
    if s.position<s.size then s.read (StartEnergy,4) else StartEnergy:=-1;

    end else begin
      current:=0;
      voltage:=0;
      SampleTemperature:=-300;
      ChamberPressure:=0;
      sample:='';
      adsorbate:='';
      co1:='';
      co2:='';
      co3:='';
      StartEnergy:=-1;
    end;
    s.free;
    ymin:=y[1];
    ymax:=y[1];
    for i:=1 to npts do begin
      if ymin>y[i] then ymin:=y[i];
      if ymax<y[i] then ymax:=y[i];
    end;
    if ymax=ymin then begin
      ymax:=ymax+1;
      ymin:=ymin-1;
    end;
    io_error:=0;
    loaded:=true;
    exit;
  end else begin
    s.free;
    assign (fka,name);                          {Karlsruhe - Sciavo}
    reset (fka);
    read (fka,ch);
    if ch=#32 then begin
      reset (fka);
      readln (fka,lei,lde,levpc,ltime,lnpts);
      if abs(lde-levpc*lnpts)<1e-10 then begin
        spe_type:=pe;
        excit:=0;
        anatype:=2;
        epass:=1;
        ei:=lei;
        ef:=ei+lde;
        wf:=0;
        scantime:=ltime;
        npts:=trunc(lnpts);
        for i:=1 to npts do readln (fka,y[i]);
        ymin:=y[1];
        ymax:=y[1];
        for i:=1 to npts do begin
          if ymin>y[i] then ymin:=y[i];
          if ymax<y[i] then ymax:=y[i];
        end;
        if ymax=ymin then begin
          ymax:=ymax+1;
          ymin:=ymin-1;
        end;
        current:=0;
        voltage:=0;
        SampleTemperature:=-300;
        ChamberPressure:=0;
        sample:='';
        adsorbate:='';
        co1:='';
        co2:='';
        co3:='';
        StartEnergy:=-1;
        close (fka);
        io_error:=0;
        loaded:=true;
        exit;
      end;
    end;
  end;
  io_error:=2;
  loaded:=false;
  close (fka);
end;
end;
{************************************************************************}





procedure TSpectrum.load_xy;
var
  f: text;
  i,io: integer;
  xx: double;
begin
  assign (f,name);
  {$I-}
  reset (f);
  {$I+}
  io:=ioResult;
  if io<>0 then begin
    loaded:=false;
    io_error:=1;
    exit;
  end;
  for i:=1 to SkipLines do begin
    readln (f);
  end;
  i:=0;
  repeat
  inc (i);
  readln (f,xx,y[i]);
  if i=1 then ei:=xx;
  until eof (f);
  close (f);
  ef:=xx;
  npts:=i;
  epass:=1;
  scantime:=1;
  current:=0;
  voltage:=0;
  SampleTemperature:=-300;
  ChamberPressure:=0;
  sample:='';
  adsorbate:='';
  co1:='';
  co2:='';
  co3:='';
  StartEnergy:=-1;
  ymin:=y[1];
  ymax:=y[1];
  for i:=1 to npts do begin
    if ymin>y[i] then ymin:=y[i];
    if ymax<y[i] then ymax:=y[i];
  end;
  if ymax=ymin then begin
    ymax:=ymax+1;
    ymin:=ymin-1;
  end;
  io_error:=0;
  loaded:=true;
end;
{************************************************************************}

procedure TSpectrum.load_AncientY;
var
  fka: text;
  error1,i,io,lineIndex,index: integer;
  xx: double;
  c: char;
  st8: string[8];
{******************************************************************}
  function readnbr (var f:text;var error:integer):single;
  var
    st: string[8];
    c: char;
    x: single;
  begin
    st:='';
    repeat
      read (f,c);
      if (c>='0') and (c<='9') then st:=st+c;
    until (c='.') or (eof(f));
    if eof(f) then exit;
    val (st,x,error);
    readnbr:=x;
  end;
{******************************************************************}

begin
    assign (fka,name);                          {Karlsruhe - Gouder}
    reset (fka);
    lineIndex:=0;
    index:=0;
//    read (fka,c); {compensate to 13 10}
    if c='t' then
       for i:=1 to 2 do begin
       readln (fka);
       end else reset (fka);
    repeat
      inc (lineIndex);
      inc (index);
      if not eof (fka) then y[index]:=readnbr (fka,error1);
      if eof(fka) then dec (index);    {trying to read last point, eof was reached)}
      if error1>0 then begin
        io_error:=2;
        close (fka);
        exit;
      end;
      if lineIndex=16 then begin
        readln (fka);
//    read (fka,c); {compensate to 13 10}
        LineIndex:=0;
      end;
    until eof (fka) or (index>2000);
    if index>2000 then begin
      io_error:=2;
      loaded:=false;
      close (fka);
      exit;
    end;
  close (fka);
  ef:=xx;
  npts:=index;
  epass:=1;
  scantime:=1;
  current:=0;
  voltage:=0;
  SampleTemperature:=-300;
  ChamberPressure:=0;
  sample:='';
  adsorbate:='';
  co1:='';
  co2:='';
  co3:='';
  spe_type:=pe;
  StartEnergy:=-1;
  ymin:=y[1];
  ymax:=y[1];
  for i:=1 to npts do begin
    if ymin>y[i] then ymin:=y[i];
    if ymax<y[i] then ymax:=y[i];
  end;
  if ymax=ymin then begin
    ymax:=ymax+1;
    ymin:=ymin-1;
  end;
  io_error:=0;
  loaded:=true;
end;
{************************************************************************}
function TSpectrum.store;
var
  f:file of single;
  i: integer;
  tmp: single;
  buf: boolean;
  {-------------------------------------------------------------------}
procedure save_si_str (st: spectr_txt_type);
var
  ps: ^single;
  i,le: integer;
begin
  ps:=addr(st);
  le:= length(st) div 4;
  for i:=0 to le do
  begin
    write (f,ps^);
    inc(ps);
  end;
end;
  {-------------------------------------------------------------------}
begin
  assign (f,name);
  {$I-}
  rewrite(f);
  {$I+}
  if ioresult<>0 then begin
    store:=false;
    exit;
  end;
  case spe_type of
    pe   : tmp:=0;
    aes  : tmp:=1;
    eels : tmp:=2;
    end;

  write (f,tmp);
  write (f,excit);
  tmp:=npts;
  write (f,AnaType,Epass,Ei,Ef,ScanTime,tmp);
  for i:=1 to npts do write (f,y[i]);
  write (f,voltage,current,SampleTemperature,ChamberPressure);
  save_si_str (sample);
  save_si_str (adsorbate);
  save_si_str (co1);
  save_si_str (co2);
  save_si_str (co3);
  write (f,StartEnergy);
  closeFile (f);
  FileModified:=false;
  store:=true;
  end;
{************************************************************************}
function TSpectrum.store_XY;
var
  f:text;
  i: integer;
  locei,locef: single;
begin
  assign (f,name);
  {$I-}
  rewrite(f);
  {$I+}
  if ioresult<>0 then begin
    store_XY:=false;
    exit;
  end;
  case spe_type of
    pe   : begin
             locei:=excit-ei;
             locef:=excit-ef;
           end;
    aes  : begin
             locei:=ei;
             locef:=ef;
           end;

    end;
  for i:=1 to npts do writeln (f,locei+(locef-locei)/(npts-1)*(i-1):3:5,#9,y[i]:3:5);
  close (f);
    store_XY:=true;
  end;
{**************************************************************************}
procedure TSpectrum.copy;
begin
  destination.name:=name;
  destination.DateTime:=DateTime;
  destination.npts:=npts;
  destination.y:=y;
  destination.spe_type:=spe_type;
  destination.AnaType:=AnaType;
  destination.Excit:=Excit;
  destination.EPass:=Epass;
  destination.ei:=ei;
  destination.ef:=ef;
  destination.wf:=wf;
  destination.ScanTime:=ScanTime;
  destination.bei:=bei;
  destination.bef:=bef;
  destination.dei:=dei;
  destination.def:=def;
  destination.hv:=hv;
  destination.EPrim:=EPrim;
  destination.chamberpressure:=chamberPressure;
  destination.sampletemperature:=SampleTemperature;
  destination.voltage:=voltage;
  destination.current:=current;
  destination.StartEnergy:=StartEnergy;
  destination.ymin:=ymin;
  destination.ymax:=ymax;
  destination.adsorbate:=adsorbate;
  destination.sample:=sample;
  destination.co1:=co1;
  destination.co2:=co2;
  destination.co3:=co3;
  destination.io_error:=io_error;
  destination.loaded:=loaded;
//destination.graphCoord:=graphCoord;
end;
{**************************************************************************}
{**************************************************************************}
begin
  spectrum := TSpectrum.create;
  File_A := TSpectrum.create;
  File_B := TSpectrum.create;
  File_A_Back := TSpectrum.create;
  File_B_Back := TSpectrum.create;
end.
{**************************************************************************}
{**************************************************************************}

