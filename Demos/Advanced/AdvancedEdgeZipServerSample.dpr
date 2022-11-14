program AdvancedEdgeZipServerSample;

uses
  Vcl.Forms,
  UformMain in 'UformMain.pas' {formMain},
  UEdgeBrowserZipServer in '..\..\Library\UEdgeBrowserZipServer.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TformMain, formMain);
  Application.Run;
end.
