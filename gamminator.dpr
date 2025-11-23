program gamminator;

uses
  Forms,
  dialogs,
  SysUtils,
  main in 'main.pas' {GammaForm},
  setup in 'setup.pas' {SetupForm},
  about in 'about.pas' {AboutForm};

var
  Code:integer;
  Zahl:double;
{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Gamminator 0.5.7';
  if ParamCount<1 then begin
    //Normaler Modus
    Application.CreateForm(TGammaForm, GammaForm);
  end else begin
    //Parameter Modus
    if ParamStr(1)='?' then begin
      UsageMeldung;
    end else begin
      Val(ParamStr(1), Zahl, Code);
      if Code <> 0 then begin
        MessageDlg('Keine gültige Dezimalzahl angegeben!', mtError, [mbOk], 0);
      end else begin
        if (Zahl < 0.1) or (Zahl > 9) then begin
          MessageDlg('Nur Gamma-Werte zwischen 0,1 und 9 werden akzeptiert!', mtError, [mbOk], 0);
        end else begin
          SetGammaDouble(Zahl);
        end;
      end;
    end;
  end;
  Application.ShowMainForm:=False;
  Application.Run;
end.
