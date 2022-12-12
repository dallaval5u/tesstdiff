unit FileDifGlb;

interface
uses DataFiles;
var
  x,dx: double;
  Genei, GenEf: double;
  ni,nf,shift: integer;
  file_b_y: array[-200 .. 2200] of double;
  SpectrumLoaded: Boolean;
  Spectrum,File_A,File_A_Back,File_B,File_B_Back:TSpectrum;
  Show_File_A,Show_File_B,Show_File_Dif:Boolean;
  File_A_Scale:boolean;
implementation
begin
  spectrum := TSpectrum.create;
  File_A := TSpectrum.create;
  File_B := TSpectrum.create;
  File_A_Back := TSpectrum.create;
  File_B_Back := TSpectrum.create;
end.
