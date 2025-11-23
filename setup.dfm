object SetupForm: TSetupForm
  Left = 244
  Top = 163
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Options'
  ClientHeight = 206
  ClientWidth = 286
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001001010100000000000280100001600000028000000100000002000
    00000100040000000000C0000000000000000000000000000000000000000000
    0000000080000080000000808000800000008000800080800000C0C0C0008080
    80000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000808
    8800000000007808000000080800008800000000800077800800000800888000
    8000000008808008080000000708000000000008870700000000000007080800
    8008080008708000800080080087008888800800800008800088000808000708
    88080000000087070808880000000708780800000000087000880000000081FE
    000001E2000007E0000003E0000003F0000023C000003FC00000E3C000002230
    0000002000000020000000620000001E0000001F0000001F0000007F0000}
  OldCreateOrder = False
  Position = poDesktopCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 1
    Top = 0
    Width = 284
    Height = 169
    Caption = 'Hotkey-Setup'
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 69
      Height = 13
      Caption = 'Raise Gamma:'
    end
    object Label2: TLabel
      Left = 16
      Top = 72
      Width = 71
      Height = 13
      Caption = 'Lower Gamma:'
    end
    object Label3: TLabel
      Left = 16
      Top = 120
      Width = 76
      Height = 13
      Caption = 'Default Gamma:'
    end
    object PlusHotkey: THotKey
      Left = 24
      Top = 40
      Width = 241
      Height = 19
      HotKey = 24689
      InvalidKeys = [hcNone]
      Modifiers = [hkShift, hkCtrl]
      TabOrder = 0
      OnChange = PlusHotkeyChange
    end
    object MinusHotkey: THotKey
      Left = 24
      Top = 88
      Width = 241
      Height = 19
      HotKey = 24688
      InvalidKeys = [hcNone]
      Modifiers = [hkShift, hkCtrl]
      TabOrder = 1
      OnChange = PlusHotkeyChange
    end
    object DefaultHotkey: THotKey
      Left = 24
      Top = 136
      Width = 241
      Height = 19
      HotKey = 24690
      InvalidKeys = [hcNone]
      Modifiers = [hkShift, hkCtrl]
      TabOrder = 2
      OnChange = PlusHotkeyChange
    end
  end
  object OKButton: TButton
    Left = 48
    Top = 176
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = OKButtonClick
  end
  object CancelButton: TButton
    Left = 128
    Top = 176
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = CancelButtonClick
  end
  object ApplyButton: TButton
    Left = 208
    Top = 176
    Width = 75
    Height = 25
    Caption = 'Apply'
    Enabled = False
    TabOrder = 3
    OnClick = ApplyButtonClick
  end
end
