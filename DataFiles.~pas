unit DataFiles;
interface
uses
  SysUtils, Classes,StringUnit,Forms;
type

    tyyomicron=array[1..3000] of array[1..5] of single;
  tyyphoibos1=array[1..3000] of array[1..10] of single;
  ty=array[1..12000] of single;
  tr9=array[1..9] of double;

  TShortSpe=record
    ei,ef:single;
    npts:integer;
    y:array[1..12000] of single;
  end;



  TSpectrumType= (singlechan,multichan,xrd,singleold);
  Analysis = (PE,AES,EELS,PhoibosPE,OmicronPE,OmicronPEOld,BIS,hreels);

  spectr_txt_type= string [255];
  Tspectr_name= String [255];

  TSpectrum = class (TObject)
  public
  start_byte:byte;
  SpectrumType:TSpectrumType;  {single channel, multichannel, xrd or single channel old}
  DateTime:TDateTime;
  name: Tspectr_Name;         {Name of the File}
  npts: integer;              {Number of DataPoints}
  nrepeat:integer;
  nctron: integer;            {Number of Channeltrons, 1,5 or 9}
  x,y:ty;
  yy:tyyphoibos1;
  spe_type: analysis;         {Indicates type of Analsis
                                PE:   Photoelectron
                                AES:  Auger
                                EELS: Electron Energy Loss
                                PhoibosPE: Phoibos Analyzer; and others .}
  spe_type_str:string;
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

  vers:integer;            {version of data}
  slit:string[10];            {slitType 0 .. 7}
  anaMode,slitin,slitout,magnification:string [30];        {magnification mode}
  shift_e:array[1..5] of single;

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
  Skiplines:integer;
  FileModified:boolean;
  Shift_raw_e:tr9;
  yimin,yimax: double;

  end_byte:byte;
  constructor create;
  procedure load;virtual;
  procedure loadHREELS;virtual;
  procedure loadHREELSNew;virtual;
  procedure load_xy;virtual;
  procedure load_AncientY;virtual;
  procedure load_xrd;
  
  function Store:boolean;virtual;
  function StoreSingleChannel:boolean;virtual;
  function StorePhoibos:boolean;virtual;
  function StoreOmicronNew:boolean;virtual;
  function StoreOmicronOld:boolean;virtual;
  function store_XY:boolean;virtual;
  function store_VAMAS:boolean;virtual;
  procedure copy (var destination: TSpectrum);
  procedure minmax;
  procedure MCDExtractSum;
  destructor Destroy;virtual;
  end;



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
procedure TSpectrum.minmax;
var
  i:integer;
begin
  ymin:=y[1];
  ymax:=y[1];
  for i:=1 to npts do begin
    if ymin>y[i] then ymin:=y[i];
    if ymax<y[i] then ymax:=y[i];
  end;
  if ymax=ymin then ymax:=ymin+1;
end;
{************************************************************************}

procedure TSpectrum.load_xrd;
type
  t12000=array[1..12000] of double;
var
  st:TFileStream;
  f: text;
  i,io: integer;
  xx,d: double;
  teta:^t12000;
begin
  new (teta);
  try
    st:=TFileStream.Create (name,fmOpenRead);
      st.read (d,8);ei:=d;
      st.read (d,8);ef:=d;
      st.read (d,8);scanTime:=d;
      st.read (npts,4);
      st.read (teta^,8*npts);
      for i:=1 to npts do y[i]:=teta[i];
  except
    io_error:=1;
    loaded:=false;

  end;
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
  minmax;
  io_error:=0;
  loaded:=true;
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
  nctron:=1;
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
  minmax;
  io_error:=0;
  loaded:=true;
end;
{************************************************************************}
procedure TSpectrum.loadHREELSNew;
var
  f: text;
  i,io: integer;
  xx,de: double;
  ln:integer;
  tst,s:string;
  index:integer;
  s12:string[12];
  nrepeat:integer;
  chantime:integer;
begin
  assign (f,name);
  {$I-}
  reset (f);
  {$I+}
  io:=ioResult;
  if io<>0 then begin
    loaded:=false;
    io_error:=1;
//    CloseFile (f);
    exit;
  end;
  readln (f,s);
  tst:=system.copy (s,1,8);
  if tst <> 'Fil Volt' then begin
    io_error:=1;
    CloseFile (f);
    exit;
  end;
  spe_type:=hreels;
  for i:=1 to 42 do readln (f);

  readln (f,s12,ei);ei:=ei*1000;
  readln (f,s12,ef);ef:=ef*1000;
  readln (f,s12,de);
  readln (f,s12,chantime);
  readln (f,s12,nrepeat);
  readln (f,s12,npts);
  scantime:=chantime/1000*npts*nrepeat;
  for i:=1 to npts do readln (f,y[i]);
  CloseFile (f);

  epass:=1;
  minmax;
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
  minmax;
  io_error:=0;
  loaded:=true;
end;
{************************************************************************}
procedure TSpectrum.loadHREELS;
var
  f: text;
  i,io: integer;
  xx,de: double;
  ln:integer;
  tst,s:string;
  index:integer;
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
  repeat
    readln (f,s)
  until (equal (s,'%%%%% 021',0)) or eof(f);
  if eof (f) then begin
    io_error:=2;
    exit;
  end;
  spe_type:=hreels;
  readln (f,s);
  readln (f,tst);
  index:=0;
  s:=identify (tst,index);  //
  npts:=StrToInt(s);
  s:=identify (tst,index);
  de:=StrToFloat(s);
  s:=identify (tst,index);
  ei:=StrToFloat(s);
  s:=identify (tst,index);
  ef:=StrToFloat(s);
  readln (f,s);
  readln (f,s);
  for i:=1 to npts do begin
    readln (f,s);
    readln (f,tst);
    index:=7;
    s:=identify (tst,index);
    y[i]:=StrToFloat(s);
  end;
  minmax;
  epass:=1;
//  scantime:=chantime/1000*npts;
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
  minmax;
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
    nctron:=1;
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
        LineIndex:=0;
      end;
    until eof (fka) or (index>12000);
    if index>12000 then begin
      io_error:=2;
      loaded:=false;
      close (fka);
      exit;
    end;
  close (fka);
  npts:=index;
  ei:=1;
  ef:=npts;
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
  spe_type:=aes;
  StartEnergy:=-1;
  minmax;
  io_error:=0;
  loaded:=true;
end;
{************************************************************************}
function TSpectrum.Store;
begin
  Store:=StoreSingleChannel;   // call function then exit
  exit;


  if spe_type<>PhoibosPE then begin
      Store:=StoreSingleChannel;   // call function then exit
    exit;
  end;
  if spe_type=PhoibosPE then begin
    Store:=StorePhoibos;         // call function then exit
    exit;
  end;

end;
{************************************************************************}
function TSpectrum.StoreSingleChannel;
var
  s: TFileStream;
  f:file of single;
  i,j: integer;
  tmp: single;
  buf: boolean;
  ScanT:single;
begin
{ We store all in the single channel format ... i.e. only the y[i]
  since data operations are only done on y[i].
  The multichannel curves yy[i,1..9 or 1..5] are only for correction purpose, in case
  the energy shift (channeltron dispersion) is not done properly. This should
  only be relevant in accidental cases  }

   {Output for SINGLE format!!!!!!!!}

  StoreSingleChannel:=false;

  try s:=TFileStream.Create (name,fmCreate) except
    loaded:=false;
    io_error:=1;

    exit;
  end;

  //Store BIS spectrun .......................................................................................................
  if spe_type = bis then begin
  tmp:=15;                      // spe_type:=BIS

  s.write (tmp,4);
  excit:=1486.2;
  s.write (excit,4);
  s.write (Ei,4);
  s.write (Ef,4);
       ScanT:=ScanTime;
  s.write (ScanT,4);
        tmp:=npts;
  s.write (tmp,4);
  for i:=1 to npts do s.write (y[i],4);
  s.free;
  storeSingleChannel:=true;
  exit;
  end;
//END Store BIS spectrun .......................................................................................................
  if spe_type = hreels then begin
  tmp:=16;                      // spe_type:=BIS
  end;
//Store HREELS spectrun .......................................................................................................



//END Store HREELS spectrun .......................................................................................................

//  tmp:=ord(spe_type);
  tmp:=ord(pe);
  s.write (tmp,4);
  s.write (excit,4);
  tmp:=npts;
  ScanT:=ScanTime*1;
  s.write (AnaType,4);
  s.write (EPass,4);
  s.write (Ei,4);
  s.write (Ef,4);
  s.write (ScanT,4);
  tmp:=npts;
  s.write (tmp,4);

  s.write (y,4*npts);        // write the single channel curve format

  s.write(voltage,4);
  s.write (current,4);
  s.write ('',4);
  s.write ('',4);
  s.write ('',4);
  s.write ('',4);
  s.write ('',4);
  s.write (StartEnergy,4);
  FileModified:=false;
  storeSingleChannel:=true;
  s.free;
  end;

{************************************************************************}
function TSpectrum.StorePhoibos;
var
  s: TFileStream;
  f:file of single;
  i,j: integer;
  tmp: single;
  buf: boolean;
  ScanT:single;
begin
  StorePhoibos:=false;
  try s:=TFileStream.Create (name,fmCreate) except
    loaded:=false;
    io_error:=1;

    exit;
  end;


  tmp:=ord(spe_type);
  s.write (tmp,4);
  s.write (excit,4);
  tmp:=npts;
  ScanT:=ScanTime*1;
  s.write (AnaType,4);
  s.write (EPass,4);
  s.write (Ei,4);
  s.write (Ef,4);
  s.write (ScanT,4);
  tmp:=npts;
  s.write (tmp,4);

  s.write (vers,4);       // store the PHOIBOS curve format
  if vers=1 then begin
    s.write (slit, 10);
    s.write (anaMode,30);
  end;
  for i:=1 to 5 do s.write (shift_e[i],4);
  s.write (yy,4*5*npts);     // write the component curves
  s.write (y,4*npts);        // write the sum curve  ... this is the curve that will be worked on

  s.write(voltage,4);
  s.write (current,4);
  s.write ('',4);
  s.write ('',4);
  s.write ('',4);
  s.write ('',4);
  s.write ('',4);
  s.write (StartEnergy,4);
  FileModified:=false;
  StorePhoibos:=true;
  s.free;
  end;
{************************************************************************}

function TSpectrum.StoreOmicronOld ;
var
  s: TFileStream;
  f:file of single;
  i,j: integer;
  tmp: single;
  buf: boolean;
  ScanT:single;
begin

  StoreOmicronOld:=false;

  try s:=TFileStream.Create (name,fmCreate) except
    loaded:=false;
    io_error:=1;

    exit;
  end;


  tmp:=ord(spe_type);
  s.write (tmp,4);
  s.write (excit,4);
  tmp:=npts;
  ScanT:=ScanTime*1;
  s.write (AnaType,4);
  s.write (EPass,4);
  s.write (Ei,4);
  s.write (Ef,4);
  s.write (ScanT,4);
  tmp:=npts;
  s.write (tmp,4);

  for i:=1 to npts do yy[i,6]:=y[i];
  s.write(yy,4*6*npts);

  s.write(voltage,4);
  s.write (current,4);
  s.write ('',4);
  s.write ('',4);
  s.write ('',4);
  s.write ('',4);
  s.write ('',4);
  s.write (StartEnergy,4);
  FileModified:=false;
  storeOmicronOld:=true;
  s.free;
  end;

{************************************************************************}
function TSpectrum.StoreOmicronNew;
var
  s: TFileStream;
  f:file of single;
  i,j: integer;
  tmp: single;
  buf: boolean;
  ScanT:single;
begin
  StoreOmicronNew:=false;
  try s:=TFileStream.Create (name,fmCreate) except
    loaded:=false;
    io_error:=1;

    exit;
  end;
  tmp:=ord(spe_type);
  s.write (tmp,4);
  s.write (excit,4);
  tmp:=npts;
  ScanT:=ScanTime*1;
  s.write (AnaType,4);
  s.write (EPass,4);
  s.write (Ei,4);
  s.write (Ef,4);
  s.write (ScanT,4);
  tmp:=npts;
  s.write (tmp,4);

  s.write (vers,4);       // store the PHOIBOS curve format
  s.write (slitin, 30);
  s.write (slitout, 30);
  s.write (magnification, 30);
  for i:=1 to 5 do s.write (shift_raw_e[i],4);

  s.write (yy,4*5*npts);     // write the component curves
  s.write (y,4*npts);        // write the sum curve  ... this is the curve that will be worked on

  s.write(voltage,4);
  s.write (current,4);
  s.write ('',4);
  s.write ('',4);
  s.write ('',4);
  s.write ('',4);
  s.write ('',4);
  s.write (StartEnergy,4);
  FileModified:=false;
  StoreOmicronNew:=true;
  s.free;
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
    Phoibospe:
           begin
             locei:=excit-ei;
             locef:=excit-ef;
           end;
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
function TSpectrum.store_VAMAS:boolean;
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
    store_VAMAS:=false;
    exit;
  end;
  writeln (f,'VAMAS Surface Chemical Analysis Standard Data Transfer Format 1988 May 4');
  writeln (f,'European Commission - Institute for Transuranium Elements');
  writeln (f,'OMICRON EA');
  writeln (f,'');                         //operator
  writeln (f,ExtractFileName(Name));          //experiment identifier
  writeln (f,'0');                        //nbr of lines comment
  writeln (f,'NORM');
  writeln (f,'REGULAR');
  writeln (f,'1');                        //nbr spectral regions
  writeln (f,'0');                        //experiment variable label
  writeln (f,'0');
  writeln (f,'0');
  writeln (f,'0');
  writeln (f,'0');
  writeln (f,'1');                        //nbr of blocks
  writeln (f,'Region 1');                 //block identifier
  writeln (f,'Noname');                   //sample identifier
  writeln (f,'2006');
  writeln (f,'8');
  writeln (f,'31');
  writeln (f,'15');
  writeln (f,'35');
  writeln (f,'5');
  writeln (f,'255');                      //hours in advance greenwich time
  writeln (f,'0');                        //nbr comment lines

  if (excit>1486) and (excit<1487) then begin
    writeln (f,'XPS');                    //technique
    writeln (f,'Al K-alpha');
    writeln (f,'1486.6');
  end;
  if (excit>1253) and (excit<1254) then begin
    writeln (f,'XPS');                    //technique
    writeln (f,'Mg K-alpha');
    writeln (f,'1253.6');
  end;
  if (excit>21) and (excit<22) then begin
    writeln (f,'XPS');                    //technique
    writeln (f,'HeI');
    writeln (f,'21.22');
  end;
  if (excit>40) and (excit<41) then begin
    writeln (f,'XPS');                    //technique
    writeln (f,'HeII');
    writeln (f,'40.81');
  end;
  if (excit>48) and (excit<49) then begin
    writeln (f,'XPS');                    //technique
    writeln (f,'HeII*');
    writeln (f,'48.4');
  end;




  writeln (f,'0');                        //strength
  writeln (f,'0');                        //beam parameters (next 3)
  writeln (f,'0');
  writeln (f,'0');
  writeln (f,'0');
  if EPass>=0 then
    writeln (f,'FAT') else writeln (f,'FRR');
  if EPass>=0 then
    writeln (f,Epass:1:0) else writeln (f,-epass:1:0);
  writeln (f,'1E+37');                    //magnification
  writeln (f,'0.0');                      //work function
  writeln (f,'0');                        //target parameters (next 4)
  writeln (f,'0');
  writeln (f,'0');
  writeln (f,'0');
  writeln (f,'0');
  writeln (f,'xxx');                      //species label
  writeln (f,'xxx');                      //transition label
  writeln (f,'-1');                       //charge of detected species
  if spe_type=PE then begin
    writeln (f,'Binding Energy');
    writeln (f,'eV');
    writeln (f,excit-ei:2:2);
    writeln (f,-(ef-ei)/(npts-1):4:4);
  end else begin
    writeln (f,'Kinetic Energy');
    writeln (f,'eV');
    writeln (f,ei:2:2);
    writeln (f,(ef-ei)/(npts-1):4:4);
  end;

  writeln (f,'1');
  writeln (f,'');
  writeln (f,'Counts');
  writeln (f,'pulse counting');
  writeln (f,scantime/npts:2:3);
  writeln (f,'1');                        //Nbr of scans
  writeln (f,'0');                        //sample parameters (next 4)
  writeln (f,'0');
  writeln (f,'0');
  writeln (f,'0');
  writeln (f,'0');
  writeln (f,npts);                       //nub of ordinate values
  writeln (f,ymin:3:3);
  writeln (f,ymax:3:3);
  for i:=1 to npts do writeln (f,y[i]:3:3);
  writeln (f,'end of experiment');
  close (f);
  store_VAMAS:=true;
end;
{**************************************************************************}

{**************************************************************************}
procedure TSpectrum.copy;
begin
  move (start_byte,destination.start_byte,integer(@end_byte)-integer(@start_byte)+1);
end;
{**************************************************************************}

procedure TSpectrum.load;


// routine for EA10, OMICRON and PHOIBOS

var
  y1,y2,y3,y4,y5,y6:ty;
  s: TFileStream;
  fka: text;
  i,j,io,StreamNpts: integer;
  tmp,tmp1: single;
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
  lyy: ^tyyomicron;
begin

  {first check if HREELS format}
  loadhreelsNew;
  if io_error=0 then begin
    spe_type_str:='HREELS';
    exit;
  end;


  begin                           {Input for SINGLE format!!!!!!!!}
  try s:=TFileStream.Create (name,fmOpenRead) except
    loaded:=false;
    io_error:=1;
    exit;
  end;

  // format for all new spectra: EA10, OMICRON and PHOIBOS


  s.read (tmp,4);

  //tmp=15: BIS type ..........................................................
  if (tmp=15) or (tmp=16) then begin
    spe_type:=bis;
    spe_type_str:='BIS';
    s.read (excit,4);
    s.read (Ei,4);
    s.read (Ef,4);
    s.read (ScanTime,4);
    s.read (tmp1,4);
    npts:=round(tmp1);
    if tmp=16 then begin
      s.read (tmp,4);
      nrepeat:=trunc(tmp);
    end else nrepeat:=1;
    ScanTime:=ScanTime*nrepeat;
    for i:=1 to npts do s.read (y[i],4);

    epass:=1;
    minmax;
    current:=0;
    voltage:=0;
    SampleTemperature:=-300;
    ChamberPressure:=0;
    sample:='';
    adsorbate:='';
    co1:='';
    co2:='';
    co3:='';
    StartEnergy:=0;
    ymin:=y[1];
    ymax:=y[1];
    minmax;
    io_error:=0;
    loaded:=true;
    s.free;
    exit;
  end;
//end BIS ......................................................................

//start Photoemission

  if (tmp>5) or (tmp<0) or (trunc(tmp)<>tmp) then   // this is no known spectrum type
  begin
    loaded:=false;
    io_error:=2;
    s.free;
    exit;
  end;
//  tmp:=4;
  case trunc(tmp) of
    0: spe_type:=pe;
    1: spe_type:=aes;
    2: spe_type:=eels;
    3: spe_type:=PhoibosPE;
    4: spe_type:=OmicronPE;
    5: spe_type:=OmicronPEOld;
  end;

  case spe_type of
    PE:spe_type_str:='PE';
    AES:spe_type_str:='AES';
    EELS:spe_type_str:='EELS';
    PhoibosPE:spe_type_str:='PhoibosPE';
    OmicronPE:spe_type_str:='OmicronPE';
    OmicronPEOld:spe_type_str:='OmicronPEOld';
  end;


    // common data for all spectrometer types

  s.read (tmp,4);
  Excit:=tmp;
  if (spe_type=pe) or (spe_type=PhoibosPE) then hv:=Excit;
  if (spe_type=aes) or (spe_type=eels) then eprim:=Excit;

  s.read (Anatype,4);
  s.read (EPass,4);
  s.read (Ei,4);
  s.read (Ef,4);
  s.read (ScanTime,4);
  s.read (tmp,4);
  npts:=trunc (tmp);
  wf:=0;
  vers:=0;          // was soll das?

    // Phoibos type: slit type and analyzer mode

  if spe_type=PhoibosPE then begin
    s.read (vers,4);
    if vers=1 then begin                                //Phoibos 100
      s.read (slit, 10);
      s.read (anaMode,30);
      s.read (shift_e[1],5*4);
      for i:=1 to npts do for j:=1 to 6 do s.read(yy[i,j],4);
      for i:=1 to npts do y[i]:=yy[i,6];
      nctron:=5;
    end;
    if vers=2 then begin                                //Phoibos 150
      s.read (slit, 10);
      s.read (anaMode,30);
      s.read (shift_e[1],9*4);
      for i:=1 to npts do for j:=1 to 10 do s.read(yy[i,j],4);
      for i:=1 to npts do y[i]:=yy[i,10];
      nctron:=9;
    end;
    // read the component curves fromthe 5 channeltrons + sum curve (c11,c12,c13,c14,c15,c16), (c21,c22,c23,c24,c25),...
  end;

    // Standard OMICRON type: slitin, slitout and magnification

  if spe_type=OmicronPE then begin
    nctron:=5;
    s.read (vers,4);
    s.read (slitin, 30);
    s.read (slitout, 30);
    s.read (magnification, 30);
    s.read (shift_e[1],5*4);
    // read the component curves fromthe 5 channeltrons + sum curve (c11,c12,c13,c14,c15,c16), (c21,c22,c23,c24,c25),...
//    s.read (yy,4*6*npts);
    for i:=1 to npts do for j:=1 to 6 do s.read(yy[i,j],4);
    for i:=1 to npts do y[i]:=yy[i,6];
  end;

    // Old OMICRON type: no slit information but sum curve exist. It has been created by datatreatment program like ANALYSIS

  if spe_type=OmicronPEOld then begin
    nctron:=5;
    new (lyy);
    for i:=1 to npts do for j:=1 to 6 do s.read(yy[i,j],4);
    for i:=1 to npts do y[i]:=yy[i,6];
  end;



   //  EA10 type or old OMICRON type: no slit information

  if (spe_type=PE) or (spe_type=AES) or (spe_type=EELS) then begin
    StreamNpts:=(s.size-s.position) div 4;

        // EA10 .....  single channel spectra

    if StreamNpts<4*npts then begin
      spectrumType:=SingleChan;
      nctron:=1;
      s.read (y,4*npts);
      for i:=1 to npts do yy[i,6]:=y[i];

      // OMICRON  ...  multichannel spectra

    end else begin
      spectrumType:=MultiChan;
      nctron:=5;
      Spe_Type:=OmicronPEOld;
      new (lyy);
      s.read(lyy^,4*5*npts);
      for i:=1 to npts do for j:=1 to 5 do yy[i,j]:=lyy[i,j];
      dispose (lyy);
      MCDExtractSum;
    end;
  end;

    // common data for all spectrometer types

  if s.position<s.size  then begin
    s.read (voltage,4);
    s.read (current,4);
    s.read (SampleTemperature,4);
    s.read (ChamberPressure,4);
    s.read(sample,4);
    s.read (adsorbate,4);
    s.read (co1,4);
    s.read (co2,4);
    s.read (co3,4);
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
  minmax;
  io_error:=0;
  loaded:=true;
  exit;

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
      minmax;
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
  io_error:=2;
  loaded:=false;
  close (fka);
end;
end;
{************************************************************************}
procedure TSpectrum.MCDExtractSum;
type t2000=array[1..2000] of single;
var
  ii,iindex,inpts1: integer;
  ex,ey,yold: ^t2000;
  denew,deold,EnOffset:double;
  spe: array[1..5] of tShortSpe;
  ne,i,j,newnpts:integer;
  newei,newef:double;
  de,dne:single;
  s:^tyyomicron;
  cshift:array[1..5] of integer;
begin
  de:=0.025*Epass;
  // curve nbr 2: ei-de ... therefore first channel is
  dne:=(npts-1)/(ef-ei);
  npts:=round(1+(npts-1)*(ef-ei-4*de)/(ef-ei));
  ei:=ei+2*de;
  ef:=ef-2*de;
  cshift[1]:=round(2*de*dne);
  cshift[2]:=round(3*de*dne);
  cshift[3]:=round(1*de*dne);
  cshift[4]:=round(4*de*dne);
  cshift[5]:=round(0*de*dne);
  new (s);
  for i:=1 to npts do
    for j:=1 to 5 do s[i,j]:=yy[i+cshift[j],j];
  for i:=1 to npts do
    for j:=1 to 5 do yy[i,j]:=s[i,j];
  dispose (s);
  for i:=1 to npts do begin
    y[i]:=0;
    for j:=1 to 5 do y[i]:=y[i]+yy[i,j];
    yy[i,6]:=y[i];
  end;
  exit;



  for i:=1 to 5 do begin
    for j:=1 to npts do spe[i].y[j]:=yy[j,i];
    spe[i].ei:=ei;
    spe[i].ef:=ef;
    spe[i].npts:=npts;
  end;
  de:=0.025*Epass;
  with spe[2] do begin
    ei:=ei-de;
    ef:=ef-de;
  end;
  with spe[3] do begin
    ei:=ei+de;
    ef:=ef+de;
  end;
  with spe[4] do begin
    ei:=ei-2*de;
    ef:=ef-2*de;
  end;
  with spe[5] do begin
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
with Spe[i] do begin
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
    for j:=1 to npts do y[j]:=y[j]+spe[i].y[j];
  end;
end;
{**************************************************************************}
end.

{************************************************************************************************}
{************************************************************************************************}


