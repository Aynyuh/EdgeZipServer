object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 666
  ClientWidth = 990
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
    Width = 990
    Height = 666
    Align = alClient
    TabOrder = 0
    UserDataFolder = '%LOCALAPPDATA%\bds.exe.WebView2'
    ExplicitWidth = 986
    ExplicitHeight = 665
  end
end
