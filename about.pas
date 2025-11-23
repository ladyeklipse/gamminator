{
  gamminator
  about.pas

  by Wolfgang Freiler

  last changes: 13.1.2005
}
unit about;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, shellapi;

type
  TAboutForm = class(TForm)
    ProgIcon: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Label3: TLabel;
    Button2: TButton;
    procedure Button2Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.dfm}

procedure TAboutForm.Button2Click(Sender: TObject);
begin
    if shellexecute(handle,'open','http://sourceforge.net/projects/gamminator',nil,nil,sw_show)<=32 then
        MessageDlg('The Gamminator website couldn''t be opened!'+#13+
                   'Please try again at a later point of time.',
                    mtError, [mbOK], 0);
    end;

end.
