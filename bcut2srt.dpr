program bcut2srt;

uses
  Forms,
  uFrmBcut2Strt in 'uFrmBcut2Strt.pas' {FrmBcut2Strt};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '�ؼ���Ļ��������';
  Application.CreateForm(TFrmBcut2Strt, FrmBcut2Strt);
  Application.Run;
end.
