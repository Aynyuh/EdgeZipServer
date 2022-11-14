object formMain: TformMain
  Left = 0
  Top = 0
  Caption = 'formMain'
  ClientHeight = 542
  ClientWidth = 788
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  TextHeight = 15
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 788
    Height = 542
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 1047
    ExplicitHeight = 626
  end
  object MainMenu1: TMainMenu
    Left = 104
    Top = 72
    object Help1: TMenuItem
      Caption = 'Documentation'
      object Open1: TMenuItem
        Caption = 'Open'#8230
        OnClick = Open1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Variant11: TMenuItem
        Caption = 'Variant 1'
        OnClick = Variant11Click
      end
      object Variant21: TMenuItem
        Caption = 'Variant 2'
        OnClick = Variant21Click
      end
      object Variant31: TMenuItem
        Caption = 'Variant 3'
        OnClick = Variant31Click
      end
      object Variant32: TMenuItem
        Caption = 'Variant 4'
        OnClick = Variant32Click
      end
      object Variant51: TMenuItem
        Caption = 'Variant 5'
        OnClick = Variant51Click
      end
      object Variant61: TMenuItem
        Caption = 'Variant 6'
        OnClick = Variant61Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        OnClick = Exit1Click
      end
    end
  end
  object dialogOpenDocs: TOpenDialog
    Filter = 'Zip Files (*.zip)|*.zip'
    Left = 120
    Top = 152
  end
end
