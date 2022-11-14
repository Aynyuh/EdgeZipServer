object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 464
  ClientWidth = 890
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object EdgeBrowser1: TEdgeBrowser
    Left = 0
    Top = 0
    Width = 890
    Height = 464
    Align = alClient
    TabOrder = 0
    UserDataFolder = '%LOCALAPPDATA%\bds.exe.WebView2'
    ExplicitLeft = 208
    ExplicitTop = 120
    ExplicitWidth = 100
    ExplicitHeight = 41
  end
end
