unit UframeEdgeZipServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Winapi.WebView2, Winapi.ActiveX, Vcl.Edge,
  System.Zip, IdURI, Vcl.StdCtrls, Vcl.ExtCtrls, UEdgeBrowserZipServer;

type
  TframeEdgeZipServer = class(TFrame)
    EdgeBrowser1: TEdgeBrowser;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FHostName: string;
  protected
  public
//    EdgeServer: TEdgeZipServer;
//    FZipFile: TZipFile;
    { Public declarations }
    constructor Create(AOwner: TComponent; const FileName: string; const HostName: string); reintroduce; overload;
    property HostName: string read FHostName;
  end;

implementation

{$R *.dfm}

{ TframeEdgeZipServer }

procedure TframeEdgeZipServer.Button1Click(Sender: TObject);
begin
  var FZipFile := TZipFile.Create;
  FZipFile.Open('..\..\Docs\Variant 1.zip', TZipMode.zmRead);

  var EdgeServer := TEdgeZipServer.Create(FZipFile, EdgeBrowser1, '*://' + FHostName + '/*');
  EdgeBrowser1.Navigate('http://' + FHostName + '/');
end;

constructor TframeEdgeZipServer.Create(AOwner: TComponent; const FileName: string; const HostName: string);
begin
  inherited Create(AOwner);
  FHostName := HostName.Trim(['/']);


end;

end.
