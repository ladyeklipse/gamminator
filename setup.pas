{
  gamminator
  setup.pas

  by Wolfgang Freiler

  last changes: 6.1.2005
}
unit setup;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls,Inifiles,Menus,SHFolder;

function GetIniFileName:String;

type
  TSetupForm = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PlusHotkey: THotKey;
    MinusHotkey: THotKey;
    DefaultHotkey: THotKey;
    OKButton: TButton;
    CancelButton: TButton;
    ApplyButton: TButton;
    procedure PlusHotkeyChange(Sender: TObject);
    procedure ApplyButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure SaveSetup;
    procedure LoadSetup;
  public
    { Public declarations }
  end;

var
  SetupForm: TSetupForm;

implementation

{$R *.dfm}

function GetIniFileName:String;
var PPath:PChar;
begin
  Getmem(PPath,MAX_PATH);
  ShGetFolderPath(0,CSIDL_APPDATA,0,0,PPath);
  CreateDir(String(PPath)+'\Gamminator');
  Result:=String(PPath)+'\Gamminator\Gamminator.ini';
  FreeMem(PPath);
end;


procedure TSetupForm.SaveSetup;
var SetupFile:TIniFile;
begin
  SetupFile:=TIniFile.Create(GetIniFileName);
  SetupFile.WriteString('Hotkeys','Plus',ShortcutToText(PlusHotkey.Hotkey));
  SetupFile.WriteString('Hotkeys','Minus',ShortcutToText(MinusHotkey.Hotkey));
  SetupFile.WriteString('Hotkeys','Default',ShortcutToText(DefaultHotkey.Hotkey));
end;

procedure TSetupForm.LoadSetup;
var SetupFile:TIniFile;
begin
  SetupFile:=TIniFile.Create(GetIniFileName);
  PlusHotKey.HotKey:=TextToShortcut(SetupFile.ReadString('Hotkeys','Plus','Shift+Ctrl+F2'));
  MinusHotKey.HotKey:=TextToShortcut(SetupFile.ReadString('Hotkeys','Minus','Shift+Ctrl+F1'));
  DefaultHotKey.HotKey:=TextToShortcut(SetupFile.ReadString('Hotkeys','Default','Shift+Ctrl+F3'));
end;

procedure TSetupForm.PlusHotkeyChange(Sender: TObject);
begin
  ApplyButton.Enabled:=True;
end;

procedure TSetupForm.ApplyButtonClick(Sender: TObject);
begin
  SaveSetup;
  ApplyButton.Enabled:=False;
end;

procedure TSetupForm.CancelButtonClick(Sender: TObject);
begin
  close;
end;

procedure TSetupForm.OKButtonClick(Sender: TObject);
begin
  if ApplyButton.Enabled then ApplyButtonClick(Sender);
  close;
end;

procedure TSetupForm.FormShow(Sender: TObject);
begin
  LoadSetup;
end;

end.
