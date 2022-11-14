unit UEdgeBrowserZipServer;

interface

uses
  Vcl.Edge,
  System.Zip,
  System.SysUtils,
  System.RTLConsts,
  System.Net.Mime,
  Winapi.WebView2,
  Winapi.ActiveX,
  IdURI,
  System.Classes,
  System.Win.ComObj,
  Winapi.Windows;

type
  TEdgeZipServer = class
  private const
    sSlash = '\';
    sBackSlash = '/';
  private
    FEdgeBrowser: TCustomEdgeBrowser;
    FZipFile: TZipFile;
    FMimeTypes: TMimeTypes;
    FZipFileNames: TArray<string>;
    FCallOldHandlers: Boolean;
    FUriFilter: string;
    FOldWebResourceRequestedHandler: TWebResourceRequestedEvent;
    FOldCreateWebViewCompleted: TWebViewStatusEvent;

    /// <summary>
    ///   Gets zip file filenames and normalize paths to backslash-notation
    /// </summary>
    procedure LoadZipFileNames;
    /// <summary>
    ///   TCustomEdgeBrowser.OnWebResourceRequested event handler
    /// </summary>
    procedure DoWebResourceRequested(Sender: TCustomEdgeBrowser;
      Args: TWebResourceRequestedEventArgs);
    /// <summary>
    ///   TCustomEdgeBrowser.OnCreateWebViewCompleted event handler
    /// </summary>
    procedure DoCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HResult);
    /// <summary>
    ///   Examine request, search for zip file and construct response
    /// </summary>
    procedure HandleRequest(Args: TWebResourceRequestedEventArgs);
  protected const
    indexFiles: array [0 .. 2] of string = ('index.html', 'index.htm', 'default.htm');
  protected
    function DetectMime(const Url: string; out AType: string): Boolean;
    function CheckPathContainsRootFile(const Path: string): Integer;
    function IndexOfPath(const Path: string): Integer;
    function GetUriRelativePath(const uri: string): string;
    function FindZipIndexForUri(const uri: string; out mimeStr: string): Integer;
  public
    /// <summary>
    ///   See filters format here
    ///   https://learn.microsoft.com/en-us/dotnet/api/microsoft.web.webview2.core.corewebview2.addwebresourcerequestedfilter
    /// </summary>
    constructor Create(const Zip: TZipFile; const EdgeBrowser: TCustomEdgeBrowser;
      const UriFilter: string);
    destructor Destroy; override;
    /// <summary>
    ///   When True call OnCreateWebViewCompleted and OnWebResourceRequested event handlers if assigned. Default False.
    /// </summary>
    property CallOldEventHandlers: Boolean read FCallOldHandlers write FCallOldHandlers;
    /// <summary>
    ///   Link to assigned TZipFile
    /// </summary>
    property ZipFile: TZipFile read FZipFile;
    property EdgeBrowser: TCustomEdgeBrowser read FEdgeBrowser;
  end;

function IncludeTrailingSlash(const S: string): string;
function RemoveLeadingSlash(const S: string): string;

implementation

function IncludeTrailingSlash(const S: string): string;
begin
  Result := S;
  if (Result[High(Result)] <> '/') then
    Result := Result + '/';
end;

function RemoveLeadingSlash(const S: string): string;
begin
  Result := S;
  if (Result[Low(Result)] = '/') then
    Result := Result.TrimLeft(['/']);
end;

{ TEdgeBrowserZipServer }

function TEdgeZipServer.DetectMime(const Url: string; out AType: string): Boolean;
var
  ext: string;
  mimeKind: TMimeTypes.TKind;
begin
  ext := ExtractFileExt(Url);
  Result := FMimeTypes.GetExtInfo(ext, AType, mimeKind);
end;

function TEdgeZipServer.CheckPathContainsRootFile(const Path: string): Integer;
var
  testPath, slashPath: string;
begin
  Result := -1;
  slashPath := StringReplace(Path, sSlash, sBackSlash, [rfReplaceAll]);
  slashPath := IncludeTrailingSlash(slashPath);
  slashPath := RemoveLeadingSlash(slashPath);

  for var I := Low(indexFiles) to High(indexFiles) do
  begin
    testPath := slashPath + indexFiles[I];
    Result := IndexOfPath(testPath);
    if Result >= 0 then
      Exit;
  end;
end;

constructor TEdgeZipServer.Create(const Zip: TZipFile; const EdgeBrowser: TCustomEdgeBrowser;
  const UriFilter: string);
begin
  inherited Create;

  if not Assigned(Zip) then
    raise EArgumentNilException.Create(Format(SParamIsNil, ['Zip']));

  if not Assigned(EdgeBrowser) then
    raise EArgumentNilException.Create(Format(SParamIsNil, ['EdgeBrowser']));

  if Zip.Mode = TZipMode.zmClosed then
    raise EArgumentException.Create(SZipNotOpen);

  // nobody told you but seems like filter is case sensetive
  // it means that it won't fire up OnWebResourceRequested event
  // if we add filter with upper case characters. For example
  // filter contoSO.com will not work for requests for contoso.com
  FUriFilter := UriFilter.ToLowerInvariant;

  FZipFile := Zip;
  LoadZipFileNames;

  FMimeTypes := TMimeTypes.Create;
  FMimeTypes.AddDefTypes;

  { Setting up EdgeBrowser }

  FEdgeBrowser := EdgeBrowser;
  FCallOldHandlers := False;

  // save previous handlers and setting our own

  // OnWebResourceRequested
  if Assigned(EdgeBrowser.OnWebResourceRequested) then
    FOldWebResourceRequestedHandler := FEdgeBrowser.OnWebResourceRequested
  else
    FOldWebResourceRequestedHandler := nil;

  FEdgeBrowser.OnWebResourceRequested := DoWebResourceRequested;

  // OnCreateWebViewCompleted
  if Assigned(FEdgeBrowser.OnCreateWebViewCompleted) then
    FOldCreateWebViewCompleted := FEdgeBrowser.OnCreateWebViewCompleted
  else
    FOldCreateWebViewCompleted := nil;

  FEdgeBrowser.OnCreateWebViewCompleted := DoCreateWebViewCompleted;

  // this call will work only if WebView already created
  // in case you're trying to re-use EdgeBrowser where's content already loaded
  FEdgeBrowser.AddWebResourceRequestedFilter(FUriFilter, COREWEBVIEW2_WEB_RESOURCE_CONTEXT_ALL);
end;

destructor TEdgeZipServer.Destroy;
begin
  FMimeTypes.Free;
  SetLength(FZipFileNames, 0);
  FZipFile := nil;

  FEdgeBrowser.RemoveWebResourceRequestedFilter(FUriFilter, COREWEBVIEW2_WEB_RESOURCE_CONTEXT_ALL);

  FEdgeBrowser.OnCreateWebViewCompleted := FOldCreateWebViewCompleted;
  FEdgeBrowser.OnWebResourceRequested := FOldWebResourceRequestedHandler;

  inherited Destroy;
end;

procedure TEdgeZipServer.DoCreateWebViewCompleted(Sender: TCustomEdgeBrowser; AResult: HResult);
begin
  if Succeeded(AResult) then
    FEdgeBrowser.AddWebResourceRequestedFilter(FUriFilter, COREWEBVIEW2_WEB_RESOURCE_CONTEXT_ALL)
  else
    OleCheck(AResult);

  if (FCallOldHandlers and Assigned(FOldCreateWebViewCompleted)) then
    FOldCreateWebViewCompleted(Sender, AResult);
end;

procedure TEdgeZipServer.DoWebResourceRequested(Sender: TCustomEdgeBrowser;
  Args: TWebResourceRequestedEventArgs);
begin
  HandleRequest(Args);

  if (FCallOldHandlers and Assigned(FOldWebResourceRequestedHandler)) then
    FOldWebResourceRequestedHandler(Sender, Args);
end;

function TEdgeZipServer.GetUriRelativePath(const Uri: string): string;
var
  IdURI: TIdURI;
begin
  IdURI := TIdURI.Create(Uri);
  Result := IdURI.URLDecode(IdURI.Path + IdURI.Document);
  IdURI.Free;
end;

function TEdgeZipServer.FindZipIndexForUri(const Uri: string; out MimeStr: string): Integer;
var
  FileName: string;
begin
  FileName := GetUriRelativePath(Uri);

  // if user explicitly request for folder then we check if it contains index.html file first
  // we need this in case when archive contains file and folder with the same names
  if (fileName.EndsWith(sBackSlash)) then
    Result := CheckPathContainsRootFile(FileName)
  else
  begin
    Result := IndexOfPath(FileName);
    if (Result = -1) then
      Result := CheckPathContainsRootFile(FileName);
  end;

  if Result >= 0 then
    FileName := FZipFileNames[Result];

  // make sure it returns correct ext and mime
  DetectMime(FileName, MimeStr);
end;

procedure TEdgeZipServer.HandleRequest(Args: TWebResourceRequestedEventArgs);
var
  resourceRequest: ICoreWebView2WebResourceRequest;
  response: ICoreWebView2WebResourceResponse;
  puri: PWideChar;
  memFile: TStream;
  header: TZipHeader;
  stream: IStream;
  mimeStr: string;
  idx: Integer;
begin
  if Succeeded(Args.ArgsInterface.Get_Request(resourceRequest)) then
  begin
    resourceRequest.Get_uri(puri);

    idx := FindZipIndexForUri(puri, mimeStr);

    if (idx >= 0) then
    begin
      // make a response with a file from ZipArchive
      memFile := TMemoryStream.Create;
      FZipFile.Read(idx, memFile, header);

      stream := TStreamAdapter.Create(memFile, TStreamOwnership.soOwned);
      ResourceRequest.Set_Content(stream);

      FEdgeBrowser.EnvironmentInterface.CreateWebResourceResponse(stream, 200, 'OK',
        PWideChar('Content-Type: ' + mimeStr), response);

      Args.ArgsInterface.Set_Response(response);
    end;

    CoTaskMemFree(puri);
  end;
end;

function TEdgeZipServer.IndexOfPath(const Path: string): Integer;
var
  slashPath: string;
begin
  Result := -1;
  slashPath := StringReplace(Path, sSlash, sBackSlash, [rfReplaceAll]);
  slashPath := RemoveLeadingSlash(Path);

  for var I := 0 to Length(FZipFileNames) - 1 do
  begin
    if (SameStr(slashPath, FZipFileNames[I])) then
      Exit(I);
  end;
end;

procedure TEdgeZipServer.LoadZipFileNames;
begin
  FZipFileNames := Copy(FZipFile.FileNames, 0, Length(FZipFile.FileNames));

  // once and for all we replace backslashes to slashes so we don't need to care about it anymore
  for var I := Low(FZipFileNames) to High(FZipFileNames) do
    FZipFileNames[I] := StringReplace(FZipFileNames[I], sSlash, sBackSlash, [rfReplaceAll]);
end;

end.
