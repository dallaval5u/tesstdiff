program FileDifference;

uses
  Forms,
  FileDif in 'FileDif.pas' {FileDifWnd},
  FileDifGlb in 'FileDifGlb.pas',
  graph in 'graph.pas' {Grafik},
  FilDifLib in 'FilDifLib.pas',
  DataFiles in 'DataFiles.pas',
  StringUnit in 'StringUnit.pas',
  SaveFileWindowUnit in 'SaveFileWindowUnit.pas' {SaveFileWindow},
  HelpUnit in '..\..\..\..\Program Files (x86)\Borland\Delphi7\Demos\RichEdit\HelpUnit.pas' {HelpForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFileDifWnd, FileDifWnd);
  Application.CreateForm(TGrafik, Grafik);
  Application.CreateForm(TSaveFileWindow, SaveFileWindow);
  Application.CreateForm(THelpForm, HelpForm);
  Application.Run;
end.
