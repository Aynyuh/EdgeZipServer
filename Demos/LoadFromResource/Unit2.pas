unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UEdgeBrowserZipServer, System.Zip, Winapi.WebView2,
  Winapi.ActiveX, Vcl.Edge;

type
  TForm2 = class(TForm)
    EdgeBrowser1: TEdgeBrowser;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    resourceStream: TResourceStream;
    edgeServer: TEdgeZipServer;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
begin
  resourceStream := TResourceStream.Create(HInstance, 'Variant1', RT_RCDATA);
  var zipFile := TZipFile.Create;
  zipFile.Open(resourceStream, TZipMode.zmRead);
  edgeServer := TEdgeZipServer.Create(zipFile, EdgeBrowser1, '*://contoso.com/*');
  EdgeBrowser1.Navigate('http://contoso.com/');
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  if (edgeServer.ZipFile.Mode <> TZipMode.zmClosed) then
    edgeServer.ZipFile.Close;

  edgeServer.ZipFile.Destroy;
  resourceStream.Destroy;
  edgeServer.Destroy;
end;

end.
