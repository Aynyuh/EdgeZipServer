unit UformMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ComCtrls, Winapi.WebView2, Winapi.ActiveX, Vcl.Edge, System.Zip, Vcl.Menus, System.IOUtils,
  System.Generics.Collections, UEdgeBrowserZipServer;

type
  TNavigationCompletedEventWrapper = class(TComponent)
  private
    FProc: TProc<TCustomEdgeBrowser, Boolean, COREWEBVIEW2_WEB_ERROR_STATUS>;
  public
    constructor Create(Owner: TComponent; Proc: TProc<TCustomEdgeBrowser, Boolean, COREWEBVIEW2_WEB_ERROR_STATUS>);
  published
    procedure Event(Sender: TCustomEdgeBrowser; IsSuccess: Boolean; WebErrorStatus: COREWEBVIEW2_WEB_ERROR_STATUS);
  end;

  TformMain = class(TForm)
    PageControl1: TPageControl;
    MainMenu1: TMainMenu;
    Help1: TMenuItem;
    Open1: TMenuItem;
    N1: TMenuItem;
    Variant11: TMenuItem;
    Variant21: TMenuItem;
    Variant31: TMenuItem;
    Variant32: TMenuItem;
    Variant51: TMenuItem;
    Variant61: TMenuItem;
    dialogOpenDocs: TOpenDialog;
    N2: TMenuItem;
    Exit1: TMenuItem;
    procedure Variant11Click(Sender: TObject);
    procedure Variant21Click(Sender: TObject);
    procedure Variant31Click(Sender: TObject);
    procedure Variant32Click(Sender: TObject);
    procedure Variant51Click(Sender: TObject);
    procedure Variant61Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
  private
    { Private declarations }
    function OpenDocumentation(const FileName: string; const StartPage: string): TEdgeBrowser;

    function DisplayTicket(const FileName: string; NavigationComplete: TNavigationCompletedEvent): TEdgeBrowser;

    function GetTicketJS(out A: TList<string>): Boolean;

    function AnonProc2NavigationCompleted(Owner: TComponent;
      Proc: TProc<TCustomEdgeBrowser, Boolean, COREWEBVIEW2_WEB_ERROR_STATUS>): TNavigationCompletedEvent;
  public
    { Public declarations }
  end;

var
  formMain: TformMain;

implementation

{$R *.dfm}

function TformMain.AnonProc2NavigationCompleted(Owner: TComponent; 
  Proc: TProc<TCustomEdgeBrowser, Boolean, COREWEBVIEW2_WEB_ERROR_STATUS>): TNavigationCompletedEvent;
begin
  Result := TNavigationCompletedEventWrapper.Create(Owner, Proc).Event;
end;

function TformMain.DisplayTicket(const FileName: string; NavigationComplete: TNavigationCompletedEvent): TEdgeBrowser;
begin
  var browser := OpenDocumentation(FileName, '');
  browser.OnNavigationCompleted := NavigationComplete;
  Result := browser;
end;

procedure TformMain.Exit1Click(Sender: TObject);
begin
  Close;
end;

function TformMain.GetTicketJS(out A: TList<string>): Boolean;
type
  TTicketFileds = (tsFullName, tsEmail, tsTravelPurpose, tsReservationId, tsAddress,
  ts1Source, ts1Destination, ts1Date, ts1Airline, ts1Flight, ts1Departure, ts1Duration,
  ts1Arrival, ts1Class, ts1Confirmation, ts1Status, ts1AirportInfo);

  function JS4Field(const Field: TTicketFileds; const Args: array of const): string;
  var
    js: string;
  begin
    case Field of
      tsFullName: js := '{ document.querySelector("#field-full-name").innerText = "%s" }';
      tsEmail: js := '{ document.querySelector("#field-email").innerText = "%s" }';
      tsTravelPurpose: js := '{ document.querySelector("#field-travel-purpose").innerText = "%s" }';
      tsReservationId: js := '{ document.querySelector("#field-reservation-id").innerText = "%s" }';
      tsAddress: js := '{ document.querySelector("#field-address").innerHTML = "%s" }';
      ts1Source: js := '{ document.querySelector("#t1-source").innerText = "%s" }';
      ts1Destination: js := '{ document.querySelector("#t1-destination").innerText = "%s" }';
      ts1Date: js := '{ document.querySelector("#t1-date").innerText = "%s" }';
      ts1Airline: js := '{ document.querySelector("#t1-airline").innerText = "%s" }';
      ts1Flight: js := '{ document.querySelector("#t1-flight").innerText = "%s" }';
      ts1Departure: js := '{ document.querySelector("#t1-departure").innerText = "%s" }';
      ts1Duration: js := '{ document.querySelector("#t1-duration").innerText = "%s" }';
      ts1Arrival: js := '{ document.querySelector("#t1-arrival").innerText = "%s" }';
      ts1Class: js := '{ document.querySelector("#t1-ticketclass").innerText = "%s" }';
      ts1Confirmation: js := '{ document.querySelector("#t1-confirmation").innerText = "%s" }';
      ts1Status: js := '{ document.querySelector("#t1-status").innerText = "%s" }';

      // <filed_name>: js := '<script>';
    end;

    Result := Format(js, Args);
  end;

begin
  A := TList<string>.Create;

  A.Add(JS4Field(tsFullName, ['John Doe']));
  A.Add(JS4Field(tsEmail, ['jdoe@contoso.com']));
  A.Add(JS4Field(tsTravelPurpose, ['Leisure']));
  A.Add(JS4Field(tsReservationId, ['ABC#123456']));
  A.Add(JS4Field(tsAddress, ['104 Hunter Ridge Rd<br>Butler, Pennsylvania(PA), 16001<br>United States']));
  A.Add(JS4Field(ts1Source, ['Moscow (SVO)']));
  A.Add(JS4Field(ts1Destination, ['Bangkok (BKK)']));
  A.Add(JS4Field(ts1Date, [FormatDateTime('dd mmm yy, ddd', Now, FormatSettings.Invariant)]));
  A.Add(JS4Field(ts1Airline, ['Aeroflot']));
  A.Add(JS4Field(ts1Flight, ['SU272']));
  A.Add(JS4Field(ts1Departure, ['22:20']));
  A.Add(JS4Field(ts1Duration, ['8h 54m']));
  A.Add(JS4Field(ts1Arrival, ['11:40']));
  A.Add(JS4Field(ts1Class, ['Business']));
  A.Add(JS4Field(ts1Confirmation, ['#ABCD123']));
  A.Add(JS4Field(ts1Status, ['<span class="badge badge-success py-1 px-2 font-weight-normal">Confirmed <i class="fas fa-check-circle"></i></span>']));

  // this is  demonstration function, but in real life scenario
  // we could get error when receiving fields data
  Result := True;
end;

procedure TformMain.Open1Click(Sender: TObject);
begin
  if (dialogOpenDocs.Execute(Handle)) then
    OpenDocumentation(dialogOpenDocs.FileName, '');
end;

function TformMain.OpenDocumentation(const FileName: string; const StartPage: string): TEdgeBrowser;
begin
  var tab := TTabSheet.Create(Self);
  tab.Parent := PageControl1;
  tab.Caption := IntToStr(PageControl1.PageCount + 1) + ' - ' + TPath.GetFileName(FileName);
  tab.PageControl := PageControl1;
  
  PageControl1.ActivePageIndex := PageControl1.PageCount - 1;

  var edgeBrowser := TEdgeBrowser.Create(Self);
  edgeBrowser.Parent := tab;
  edgeBrowser.Align := TAlign.alClient;

  var zipFile := TZipFile.Create;
  zipFile.Open(FileName, TZipMode.zmRead);

  var hostname := TPath.GetFileNameWithoutExtension(TPath.GetTempFileName) + '.com';
  var edgeServer := TEdgeZipServer.Create(zipFile, edgeBrowser, '*://' + hostname + '/*');
  edgeBrowser.Navigate('http://' + hostname + '/' + StartPage);

  Result := edgeBrowser;
end;

procedure TformMain.Variant11Click(Sender: TObject);
begin
  OpenDocumentation('..\..\..\Docs\Variant 1.zip', '');
end;

procedure TformMain.Variant21Click(Sender: TObject);
begin
  OpenDocumentation('..\..\..\Docs\Variant 2.zip', 'documentation.html');
end;

procedure TformMain.Variant31Click(Sender: TObject);
begin
  OpenDocumentation('..\..\..\Docs\Variant 3.zip', '');
end;

procedure TformMain.Variant32Click(Sender: TObject);
begin
  OpenDocumentation('..\..\..\Docs\Variant 4.zip', '');
end;

procedure TformMain.Variant51Click(Sender: TObject);
begin
  OpenDocumentation('..\..\..\Docs\Variant 5.zip', 'gen_chm.html');
end;

procedure TformMain.Variant61Click(Sender: TObject);
begin
  MessageBox(Handle, 'This example shows web page with custom fields values.', 'Varian 6', MB_ICONINFORMATION);
  
  var b := DisplayTicket('..\..\..\Docs\Variant 6.zip',
    AnonProc2NavigationCompleted(Self,
      procedure(Sender: TCustomEdgeBrowser; IsSuccess: Boolean; WebErrorStatus: COREWEBVIEW2_WEB_ERROR_STATUS)
      begin
        var fieldScripts: TList<string>;        
        { Getting fill-in scripts and runnig them }
        
        if (GetTicketJS(fieldScripts)) then
          for var s in fieldScripts do
            Sender.ExecuteScript(s);          
      end)
  );
end;

{ TNotifyEventWrapper }

constructor TNavigationCompletedEventWrapper.Create(Owner: TComponent; Proc: TProc<TCustomEdgeBrowser, Boolean, COREWEBVIEW2_WEB_ERROR_STATUS>);
begin
  inherited Create(Owner);
  FProc := Proc;
end;

procedure TNavigationCompletedEventWrapper.Event(Sender: TCustomEdgeBrowser; IsSuccess: Boolean; WebErrorStatus: COREWEBVIEW2_WEB_ERROR_STATUS);
begin
  FProc(Sender, IsSuccess, WebErrorStatus);
end;

end.
