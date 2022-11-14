object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 287
  ClientWidth = 441
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object Label1: TLabel
    Left = 64
    Top = 160
    Width = 313
    Height = 41
    Alignment = taCenter
    AutoSize = False
    Caption = 
      'You can find embedded resource in "Project -> Resources and Imag' +
      'es" menu of this project.'
    Layout = tlCenter
    WordWrap = True
  end
  object Button1: TButton
    Left = 118
    Top = 120
    Width = 205
    Height = 25
    Caption = 'Show Embedded Help'
    TabOrder = 0
    OnClick = Button1Click
  end
end
