unit uFrmBcut2Strt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ShellAPI;

type
  TFrmBcut2Strt = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    btnOpen: TButton;
    btnSave: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    btnHelp: TButton;
    procedure btnOpenClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
  private
    procedure DropFiles(var Msg: TMessage); message WM_DropFILES;
    procedure BcutToSrt(const AFileName: string);
  public

  end;

var
  FrmBcut2Strt: TFrmBcut2Strt;

implementation

uses XMLIntf, XmlDoc;

{$R *.dfm}

procedure TFrmBcut2Strt.btnOpenClick(Sender: TObject);
begin
  if not OpenDialog1.Execute then
    Exit;
  BcutToSrt(OpenDialog1.FileName);
end;

procedure TFrmBcut2Strt.btnSaveClick(Sender: TObject);
var
  S: string;
  FS: TFileStream;
begin
  if SaveDialog1.Execute then
  begin
    S := UTF8Encode(Memo1.Text);
    FS := TFileStream.Create(SaveDialog1.FileName, fmCreate);
    try
      FS.Write(Pointer(S)^, Length(S));
    finally
      FS.Free;
    end;
  end;
end;

procedure TFrmBcut2Strt.btnHelpClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', 'https://github.com/ericwang2006/bcut2srt', nil, nil, SW_SHOW);
end;

procedure TFrmBcut2Strt.DropFiles(var Msg: TMessage);
var
  i, Count: Integer;
  buffer: array[0..1024] of Char;
begin
  inherited;
  Count := DragQueryFile(Msg.WParam, $FFFFFFFF, nil, 256); // 第一次调用得到拖放文件的个数
  for i := 0 to Count - 1 do
  begin
    buffer[0] := #0;
    DragQueryFile(Msg.WParam, i, buffer, sizeof(buffer)); // 第二次调用得到文件名称
    if SameText(ExtractFileExt(buffer), '.xml') then
      BcutToSrt(buffer);
  end;
end;

procedure TFrmBcut2Strt.FormCreate(Sender: TObject);
begin
  { UAC权限 使用这三行
    ChangeWindowMessageFilter(WM_DROPFILES, MSGFLT_ADD);
    ChangeWindowMessageFilter(WM_COPYDATA, MSGFLT_ADD);
    ChangeWindowMessageFilter(WM_COPYGLOBALDATA , MSGFLT_ADD);
  }
  DragAcceptFiles(Handle, True);
end;

procedure _BcutToSrt(const AFileName: string; List: TStrings);

  function inPointToStr(inPoint: Int64): string;
  var
    h, m, s, ms: Integer;
  begin
    inPoint := inPoint div 1000;

    ms := inPoint mod 1000;
    inPoint := inPoint div 1000;

    h := inPoint div 3600;
    Dec(inPoint, 3600 * h);

    m := inPoint div 60;

    s := inPoint - 60 * m;

    Result := Format('%.2d:%.2d:%.2d,%.3d', [h, m, s, ms]);
  end;

var
  AXmlDoc: IXMLDocument;
  videoTrack, videoTracks, trackCaptions, caption: IXMLNode;
  NodeList: IXMLNodeList;
  I, J: Integer;
  inPoint, duration: Int64;
  sText: string;
  bFound: Boolean;
begin
  AXmlDoc := TXMLDocument.Create(nil);
  List.BeginUpdate;
  List.Clear;
  try
    AXmlDoc.LoadFromFile(AFileName);

    videoTracks := AXmlDoc.DocumentElement.ChildNodes.FindNode('timeline');
    if not Assigned(videoTracks) then
      raise Exception.Create('not found timeline');

    videoTracks := videoTracks.ChildNodes.FindNode('videoTracks');
    if not Assigned(videoTracks) then
      raise Exception.Create('not found videoTracks');

    bFound := False;
    for i := 0 to videoTracks.ChildNodes.Count - 1 do
    begin
      videoTrack := videoTracks.ChildNodes[i];
      trackCaptions := videoTrack.ChildNodes.FindNode('trackCaptions');
      if Assigned(trackCaptions) then
      begin
        bFound := True;
        NodeList := trackCaptions.ChildNodes;
        for j := 0 to NodeList.Count - 1 do
        begin
          caption := NodeList.Get(J);
          sText := caption.Attributes['text'];
          inPoint := StrToInt64(VarToStr(caption.Attributes['inPoint']));
          duration := StrToInt64(VarToStr(caption.Attributes['duration']));
          List.Add(IntToStr(j + 1));
          List.Add(inPointToStr(inPoint) + ' --> ' + inPointToStr(inPoint + duration));
          List.Add(sText);
          List.Add('');
        end;
        Break;
      end;
    end;
    if not bFound then
      raise Exception.Create('not found subtitle');
  finally
    AXmlDoc := nil;
    List.EndUpdate;
  end;
end;

procedure TFrmBcut2Strt.BcutToSrt(const AFileName: string);
begin
  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;
  try
    try
      _BcutToSrt(AFileName, Memo1.Lines);
    except
      on E: Exception do
        Application.MessageBox(PChar(E.Message), '提示', MB_OK + MB_ICONWARNING);
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

end.

