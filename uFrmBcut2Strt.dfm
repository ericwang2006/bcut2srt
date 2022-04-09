object FrmBcut2Strt: TFrmBcut2Strt
  Left = 541
  Top = 255
  Width = 706
  Height = 510
  Caption = #24517#21098#23383#24149#23548#20986#24037#20855
  Color = clBtnFace
  Font.Charset = GB2312_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 690
    Height = 419
    Align = alClient
    BorderStyle = bsNone
    Font.Charset = GB2312_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Fixedsys'
    Font.Style = []
    Lines.Strings = (
      #21487#30452#25509#25226#24517#21098#24037#31243#25991#20214#25302#25918#21040#27492#31383#21475
      'Drop file here')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 419
    Width = 690
    Height = 52
    Align = alBottom
    BevelOuter = bvNone
    Color = 16578017
    TabOrder = 1
    object btnOpen: TButton
      Left = 16
      Top = 14
      Width = 115
      Height = 25
      Caption = #25171#24320#24517#21098#24037#31243#25991#20214
      TabOrder = 0
      OnClick = btnOpenClick
    end
    object btnSave: TButton
      Left = 144
      Top = 14
      Width = 97
      Height = 25
      Caption = #20445#23384#23383#24149
      TabOrder = 1
      OnClick = btnSaveClick
    end
    object btnHelp: TButton
      Left = 256
      Top = 14
      Width = 97
      Height = 25
      Caption = #24110#21161'(Github)'
      TabOrder = 2
      OnClick = btnHelpClick
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = '*.xml|*.xml'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 128
    Top = 304
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '.srt'
    FileName = 'project.srt'
    Filter = '*.srt|*.srt'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 224
    Top = 320
  end
end
