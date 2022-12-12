unit StringUnit;
interface
uses strUtils, SysUtils,classes;
function Equal (s,text:string; posi:word):boolean;
function LineNumber (startLine:word;text:string):word;
function value (startLine:word;text:string):double;
function identify (var tst:string; var index:integer):string;
var
  sp:textFile;
  s2: TStringList;
  s:string;

implementation
//*********************************************************************************************************
function Equal (s, text:string;posi:word):boolean;
var
  i:integer;
  stLoc,stloc1:string;
begin
  stLoc1:=text;
  stLoc:= MidStr (s,posi,length(text));
  Equal:= (StrComp (pchar(stLoc),pchar(stLoc1))=0);
end;

//*********************************************************************************************************
function LineNumber (startLine:word;text:string):word;
var
  s:string;
  i:integer;
begin
  i:=StartLine;
  LineNumber:=0;
  repeat
    if equal (s2.Strings[i],text,0) then begin
      s:=text;
      LineNumber:=i;
      break;
    end;
      inc (i)
    until i=s2.count;
end;
//*********************************************************************************************************
function value (startLine:word;text:string):double;
var
  ln,space:integer;
  s:string;
begin
  ln:=LineNumber (startLine,text);
  s:=s2.Strings[ln];
  space:=posex (' ',s,length(text)+1);
  s:=copy (s,space,29-space);
  value:=StrToFloat(s);
end;
//*********************************************************************************************************
function identify (var tst:string; var index:integer):string;
var
  i,i1,i2:integer;
  s:string;
begin
  i:=index;
  while tst[i]=' ' do inc(i);     //search for first non <space> character
  i1:=i;
  while tst[i]<>' ' do inc(i);    //search for last non <space> character
  i2:=i;
  index:=i;                       // return new index;
  identify:=copy (tst,i1,i2-i1-1);
end;
//*********************************************************************************************************
begin
  s2:=TStringList.Create;
end.
 