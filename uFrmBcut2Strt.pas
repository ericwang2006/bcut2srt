unit uFrmBcut2Strt;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ShellAPI;

type
  TFrmBcut2Strt = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Button1: TButton;
    btnSave: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure Button1Click(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure DropFiles(var Msg: TMessage); message WM_DropFILES;
    procedure ToSrt(const AFileName: string);
  public

  end;

var
  FrmBcut2Strt: TFrmBcut2Strt;

implementation

uses XMLIntf, XmlDoc, math;

{$R *.dfm}

function inPointToStr(inPoint: Integer): string;
var
  h, m, s, msec: Integer;
begin
  inPoint := Trunc(inPoint / 1000);
  msec := Round((inPoint / 1000 - Trunc(inPoint / 1000)) * 1000);
  inPoint := Trunc(inPoint / 1000);

  h := Trunc(inPoint / 60 / 60);
  inPoint := inPoint - 60 * 60 * h;

  m := Trunc(inPoint / 60);
  s := inPoint - 60 * m;

  Result := Format('%.2d:%.2d:%.2d,%.3d', [h, m, s, msec]);
end;

procedure TFrmBcut2Strt.Button1Click(Sender: TObject);
begin
  if not OpenDialog1.Execute then
    Exit;
  ToSrt(OpenDialog1.FileName);
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
      ToSrt(buffer);
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

procedure TFrmBcut2Strt.ToSrt(const AFileName: string);
var
  AXmlDoc: IXMLDocument;
  videoTrack, videoTracks, trackCaptions, caption: IXMLNode;
  i, j, inPoint, duration: Integer;
  sText: string;
  bFound: Boolean;
begin
  AXmlDoc := TXMLDocument.Create(nil);
  Memo1.Lines.BeginUpdate;
  Memo1.Clear;
  Screen.Cursor := crHourGlass;
  Application.ProcessMessages;
  try
    try
      AXmlDoc.LoadFromFile(AFileName);
      videoTracks := AXmlDoc.DocumentElement.ChildNodes.FindNode('timeline').ChildNodes.FindNode('videoTracks');
      bFound := False;
      for i := 0 to videoTracks.ChildNodes.Count - 1 do
      begin
        videoTrack := videoTracks.ChildNodes[i];
        trackCaptions := videoTrack.ChildNodes.FindNode('trackCaptions');
        if trackCaptions <> nil then
        begin
          bFound := True;
          for j := 0 to trackCaptions.ChildNodes.Count - 1 do
          begin
            caption := trackCaptions.ChildNodes[j];
            sText := caption.Attributes['text'];
            inPoint := caption.Attributes['inPoint'];
            duration := caption.Attributes['duration'];

            Memo1.Lines.Add(IntToStr(j + 1));
            Memo1.Lines.Add(inPointToStr(inPoint) + ' --> ' + inPointToStr(inPoint + duration));
            Memo1.Lines.Add(sText);
            Memo1.Lines.Add('');
          end;
          Break;
        end;
      end;
      if not bFound then
        Application.MessageBox('我拿着望远镜也没找到字幕啊!', '提示', MB_OK + MB_ICONWARNING);
    except
      on E: Exception do
        Application.MessageBox(PChar('好像出现了灾难性故障:' + sLineBreak + E.Message), '提示', MB_OK + MB_ICONWARNING);
    end;
  finally
    AXmlDoc := nil;
    Memo1.Lines.EndUpdate;
    Screen.Cursor := crDefault;
  end;
end;

end.

