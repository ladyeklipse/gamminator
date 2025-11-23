{
  gamminator
  main.pas
  
  by Wolfgang Freiler
  
  last changes: 13.1.2005
}

unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, Math, Buttons,Shellapi, Menus,
  IniFiles, SHFolder, setup, about;

const
  FormTitle = 'Gamminator 0.5.6';
  WM_TASKBAREVENT = WM_USER + 1;

type
  TGammaForm = class(TForm)
    GraphBox: TPaintBox;
    Panel: TPanel;
    GammaTrackBar: TTrackBar;
    DefButton: TSpeedButton;
    InfoButton: TSpeedButton;
    Bevel1: TBevel;
    TrayPopup: TPopupMenu;
    RestoreWindow: TMenuItem;
    DefaultGamma: TMenuItem;
    Info1: TMenuItem;
    N1: TMenuItem;
    CloseWindow: TMenuItem;
    HelpButton: TSpeedButton;
    Help1: TMenuItem;
    SetupButton: TSpeedButton;
    Setup1: TMenuItem;
    KalibButton: TSpeedButton;
    PatternButton: TSpeedButton;
    procedure PatternButtonClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure GammaTrackBarChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GraphBoxPaint(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DefButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CloseWindowClick(Sender: TObject);
    procedure RestoreWindowClick(Sender: TObject);
    procedure InfoButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure HKPlusHotKey(Sender: TObject);
    procedure HKMinusHotKey(Sender: TObject);
    procedure HKDefaultHotKey(Sender: TObject);
    procedure SetupButtonClick(Sender: TObject);
    procedure KalibButtonClick(Sender: TObject);
  private
    Gamma:double;
    IconInTray:boolean;
    SystrayTextBuffer: PChar;
    tnid: TNOTIFYICONDATA;
    Exiting:boolean;
    CPos:TPoint;

    procedure LoadSetup;
    procedure DrawGammaGraph;
    procedure DrawGammaPattern;
    procedure TaskBarAddIcon;
    procedure TaskBarRemoveIcon;
  protected
    HKPlus:TShortcut;
    HKMinus:TShortcut;
    HKDefault:TShortcut;
    procedure RegisterKey(Shortcut:TShortcut;id:integer);
    procedure WMTASKBAREVENT(var message: TMessage); message WM_TASKBAREVENT;
    procedure WMHOTKEY (var message: TMessage); message WM_HOTKEY;
  public
    { Public declarations }
  end;

  TGammaRamp = packed record
    R : array[0..255] of word;
    G : array[0..255] of word;
    B : array[0..255] of word;
  end;

  function SetGammaDouble(GammaValue : double) : boolean;
  procedure UsageMeldung;


var
  GammaForm: TGammaForm;
implementation

{$R *.dfm}

function ShortcutEqual(Shortcut:TShortcut;Hotkey:integer):boolean;
var
  ShortcutKey: word;
  ShortcutShift: TShiftstate;
  Modifier: UINT;
begin
  Modifier := 0;
  ShortcutToKey(Shortcut, ShortcutKey, ShortcutShift);
  if ssShift in ShortcutShift then Modifier := Modifier or MOD_SHIFT;
  if ssAlt   in ShortcutShift then Modifier := Modifier or MOD_ALT;
  if ssCtrl  in ShortcutShift then Modifier := Modifier or MOD_CONTROL;

  result:= (loWord(Hotkey) = Modifier) and (hiWord(HotKey)=ShortcutKey);
end;

procedure TGammaForm.RegisterKey(Shortcut:TShortcut;id:integer);
var
  ShortcutKey: word;
  ShortcutShift: TShiftstate;
  Modifier: UINT;
begin
  Modifier := 0;
  ShortcutToKey(Shortcut, ShortcutKey, ShortcutShift);
  if ssShift in ShortcutShift then Modifier := Modifier or MOD_SHIFT;
  if ssAlt   in ShortcutShift then Modifier := Modifier or MOD_ALT;
  if ssCtrl  in ShortcutShift then Modifier := Modifier or MOD_CONTROL;
  RegisterHotKey(Handle, id, Modifier, loByte(ShortcutKey));
end;

procedure TGammaForm.LoadSetup;
var SetupFile:TIniFile;
begin
  SetupFile:=TIniFile.Create(GetIniFileName);
  HKPlus    := TextToShortcut(SetupFile.ReadString('Hotkeys','Plus','Shift+Ctrl+F2'));
  HKMinus   := TextToShortcut(SetupFile.ReadString('Hotkeys','Minus','Shift+Ctrl+F1'));
  HKDefault := TextToShortcut(SetupFile.ReadString('Hotkeys','Default','Shift+Ctrl+F3'));
  GammaTrackBar.Min:=strtoint(SetupFile.ReadString('Calibration','Lower','100'));
  GammaTrackBar.Max:=strtoint(SetupFile.ReadString('Calibration','Upper','910'));
end;

{
function SetGammaDouble(GammaValue : double) : boolean;
var
  i  : integer;
  DC : HDC;
  V  : double;
  GR : TGammaRamp;
begin
  for i := 0 to 255 do begin
    V := Power(i * 1/255,1/GammaValue);
    V := min(1,max(0,V));
    GR.R[i] := round(V * 65535);
    GR.G[i] := round(V * 65535);
    GR.B[i] := round(V * 65535);
  end;
  DC := GetDC(0);
  result:=SetDeviceGammaRamp(DC, GR);
  ReleaseDC(0, DC);
end;

function GetGammaDouble:double;
var
  Value: integer;
  DC : HDC;
  GammaRamp:TGammaRamp;
  Valuedbl:double;
begin
  DC := GetDC(0);
  GetDeviceGammaRamp(DC, GammaRamp);
  ReleaseDC(0, DC);
  Value:=GammaRamp.R[127]+GammaRamp.G[127]+GammaRamp.B[127];
  Valuedbl:=Value/(65535*3);
  Result:=1/logN(0.5,Valuedbl);
end;
}

// --- Setting Gamma for ALL Monitors ---
function SetGammaDouble(GammaValue : double) : boolean;
var
  i, DevIndex : integer;
  DC : HDC;
  V  : double;
  GR : TGammaRamp;
  d  : TDisplayDevice;
  SuccessCount : integer;
begin
  Result := False;
  SuccessCount := 0;

  // 1. Pre-calculate the Gamma Ramp (same for all monitors)
  for i := 0 to 255 do begin
    // Avoid division by zero if GammaValue is 0
    if GammaValue = 0 then V := 0
    else V := Power(i * 1/255, 1/GammaValue);
    
    V := min(1, max(0, V));
    GR.R[i] := round(V * 65535);
    GR.G[i] := round(V * 65535);
    GR.B[i] := round(V * 65535);
  end;

  // 2. Loop through all display devices
  DevIndex := 0;
  FillChar(d, SizeOf(d), 0);
  d.cb := SizeOf(d);

  while EnumDisplayDevices(nil, DevIndex, d, 0) do
  begin                                                     // Check if the device is part of the desktop (active)
    if (d.StateFlags and DISPLAY_DEVICE_ATTACHED_TO_DESKTOP) <> 0 then
    begin
      // Create a DC specific to this monitor driver
      DC := CreateDC(nil, d.DeviceName, nil, nil);
      if DC <> 0 then
      begin
        if SetDeviceGammaRamp(DC, GR) then
          Inc(SuccessCount);
        DeleteDC(DC); // Important: Release the specific DC
      end;
    end;
    Inc(DevIndex);
  end;

  // Return true if we successfully set it on at least one monitor
  Result := (SuccessCount > 0);
end;


// --- Getting Gamma from the PRIMARY Monitor ---
function GetGammaDouble: double;
var
  Value: integer;
  DC : HDC;
  GammaRamp: TGammaRamp;
  Valuedbl: double;
  d: TDisplayDevice;
  DevIndex: integer;
  FoundPrimary: boolean;
begin
  Result := 1.0; // Default safe value
  FoundPrimary := False;
  
  // 1. Find the Primary Monitor
  DevIndex := 0;
  FillChar(d, SizeOf(d), 0);
  d.cb := SizeOf(d);

  while EnumDisplayDevices(nil, DevIndex, d, 0) do
  begin
    if (d.StateFlags and DISPLAY_DEVICE_ATTACHED_TO_DESKTOP) <> 0 then
    begin
      // We only want to read from the Primary monitor to establish "Current Gamma"
      if (d.StateFlags and DISPLAY_DEVICE_PRIMARY_DEVICE) <> 0 then
      begin
        DC := CreateDC(nil, d.DeviceName, nil, nil);
        if DC <> 0 then
        begin
          if GetDeviceGammaRamp(DC, GammaRamp) then
            FoundPrimary := True;
          DeleteDC(DC);
        end;
        Break; // Found primary, stop looping
      end;
    end;
    Inc(DevIndex);
  end;

  if not FoundPrimary then Exit; // Return default 1.0 if failed

  // 2. Calculate Value
  Value := GammaRamp.R[127] + GammaRamp.G[127] + GammaRamp.B[127];
  Valuedbl := Value / (65535 * 3);

  // 3. SAFETY FIX: Prevent Zero Division
  // If Valuedbl is 1.0 (Linear Gamma), logN(0.5, 1.0) returns 0.
  if (Valuedbl >= 0.999) or (Valuedbl <= 0.001) then
  begin
    Result := 1.0;
  end
  else
  begin
    // Using Delphi's Math.LogN. 
    // If your original code had a custom logN function, ensure it is accessible.
    Result := 1 / LogN(0.5, Valuedbl);
  end;
end;

procedure UsageMeldung;
begin
  //MessageDlg('Verwendung von '+FormTitle+':'+#13#10#13#10+'Parameter:'+#13#10#13#10+'Bei Angabe einer Dezimalzahl als Parameter wird das Programm gestartet, der entsprechende Gammawert gesetzt, und das Programm sofort wieder beendet.'+#13#10#13#10+'"Gamminator 1.2" : setzt den Gammawert auf 1.2.'+#13#10+'"Gamminator ?" : zeigt diesen Hilfetext an.'+#13#10+'"Gamminator" : startet Gamminator mit der Oberfläche'+#13#10#13#10+'HotKeys:'+#13#10#13#10+'Während '+FormTitle+' läuft, kann per Hotkey der Gamma-Wert geändert werden, auch wenn ein anderes Programm aktiv ist.'+#13#10+'Die Hotkeys sind im Options-Fenster einfach einzustellen, und werden in der Datei "gamminator.ini" gespeichert.',mtInformation,[mbOk],0);
  MessageDlg('Usage of '+FormTitle+':'+#13#10#13#10+'Parameters:'+#13#10#13#10+'By passing a decimal number as a parameter to gamminator, the corresponding gamma value will be set and gamminator will be closed.'+#13#10#13#10+'"Gamminator 1.2" : sets the gamma value to 1.2.'+#13#10+'"Gamminator ?" : shows this help text.'+#13#10+'"Gamminator" : launches gamminator with the GUI.'+#13#10#13#10+'HotKeys:'+#13#10#13#10+'While Gamminator is running, the gamma value can be modified by global hotkeys, even in DirectX oder OpenGL Applications.'+#13#10+'To change the hotkeys, enter the setup window. The hotkeys will be saved in a file called "gamminator.ini" in your home directory.',mtInformation,[mbOk],0);
end;

procedure TGammaForm.WMTASKBAREVENT(var message: TMessage);
begin
     case message.LParamLo of
          // Doubleclick shows the main form
          WM_LBUTTONDBLCLK : begin
                               GetCursorPos(CPos);
                               GammaForm.Show;
                               Application.BringToFront;
                             end;
          // right click shows the popup menu
          WM_RBUTTONDOWN   : begin
                               GetCursorPos(CPos);
                               TrayPopup.Popup(CPos.x, CPos.y);
                             end;
     end;
end;

function GetShiftValue(Shortcut:TShortcut):UINT;
var
  ShortcutKey: word;
  ShortcutShift: TShiftstate;
  Modifier: UINT;
begin
  Modifier := 0;
  ShortcutToKey(Shortcut, ShortcutKey, ShortcutShift);
  if ssShift in ShortcutShift then Modifier := Modifier or MOD_SHIFT;
  if ssAlt   in ShortcutShift then Modifier := Modifier or MOD_ALT;
  if ssCtrl  in ShortcutShift then Modifier := Modifier or MOD_CONTROL;
  result:=Modifier;
end;

procedure TGammaForm.WMHOTKEY(var message: TMessage);
begin
  if (message.Msg = WM_HOTKEY) then begin
    if ShortcutEqual(HKPlus,message.LParam)    then HKPlusHotkey(nil);
    if ShortcutEqual(HKMinus,message.LParam)   then HKMinusHotkey(nil);
    if ShortcutEqual(HKDefault,message.LParam) then HKDefaultHotkey(nil);
  end;
end;

procedure TGammaForm.TaskBarAddIcon;
begin
  if IconInTray=True then Exit;
  Shell_NotifyIcon(NIM_ADD, @tnid);
  IconInTray:=True;
end;

procedure TGammaForm.TaskBarRemoveIcon;
begin
  if IconInTray=False then Exit;
  Shell_NotifyIcon(NIM_DELETE, @tnid);
  IconInTray:=False;
end;


procedure TGammaForm.DrawGammaGraph;
var Points:array of TPoint;
    i:integer;
    ArraySize:integer;
begin
  SetLength(Points,GraphBox.Width);
  ArraySize:=High(Points);
  for i:=0 to ArraySize do begin
    Points[i].X := i;
    Points[i].Y := GraphBox.Height-1-round(GraphBox.Height * Power(i/ArraySize, 1/Gamma));
  end;
  with GraphBox.Canvas do begin
    Brush.Color:=clBlack;
    Pen.Color:=clBlack;
    Rectangle(GraphBox.ClientRect);
    Pen.Color:=clWhite;
    PolyLine(Points);
    Font.color:=clWhite;
    Font.Name:='MS Sans Serif';
    Font.Size:=8;
    TextOut(4,4,FloatToStrF(Gamma,FFFixed,3,2));
  end;
end;

procedure TGammaForm.DrawGammaPattern;
var i:integer;
begin
  with GraphBox.Canvas do begin
    Pen.Color:=RGB(128,128,128);
    Brush.Color:=RGB(128,128,128);
    Rectangle(GraphBox.ClientRect);
    for i:=GraphBox.Height div 4 to GraphBox.Height * 3 div 4 do begin
      Pen.Color:=RGB((i mod 2)*255,(i mod 2)*255,(i mod 2)*255);
      moveto(GraphBox.Width div 4,i);
      lineto(GraphBox.Width * 3 div 4,i);
    end;
  end;
end;


procedure TGammaForm.FormPaint(Sender: TObject);
begin
  //GammaTicks
  GammaTrackBar.SetTick(1000-166);  //0.2
  GammaTrackBar.SetTick(1000-230);  //0.3
  GammaTrackBar.SetTick(1000-285);  //0.4
  GammaTrackBar.SetTick(1000-333);  //0.5
  GammaTrackBar.SetTick(1000-375);  //0.6
  GammaTrackBar.SetTick(1000-412);  //0.7
  GammaTrackBar.SetTick(1000-444);  //0.8
  GammaTrackBar.SetTick(1000-473);  //0.9
  GammaTrackBar.SetTick(1000-500);  //1

  GammaTrackBar.SetTick(1000-667);  //2
  GammaTrackBar.SetTick(1000-750);  //3
  GammaTrackBar.SetTick(1000-800);  //4
  GammaTrackBar.SetTick(1000-833);  //5
  GammaTrackBar.SetTick(1000-857);  //6
  GammaTrackBar.SetTick(1000-875);  //7
  GammaTrackBar.SetTick(1000-888);  //8
  GammaTrackBar.SetTick(1000-900);  //9


end;

procedure TGammaForm.GammaTrackBarChange(Sender: TObject);
begin
  Gamma:=(1000-GammaTrackBar.Position)/GammaTrackBar.Position;

  if PatternButton.Down then begin
//    DrawGammaPattern;
  end else begin
    DrawGammaGraph;
  end;

  SetGammaDouble(Gamma);
end;

procedure TGammaForm.FormCreate(Sender: TObject);
begin
  Caption:=FormTitle;
  Exiting:=false;
  LoadSetup;

  //Icon-Kram
  IconInTray:=False;
  SystrayTextBuffer:=StrAlloc(255);
  StrCopy(SystrayTextBuffer, FormTitle);
  tnid.cbSize:=sizeof(TNOTIFYICONDATA);
  tnid.Wnd:=Handle;
  tnid.uID:=1; //42
  tnid.uFlags:=NIF_MESSAGE or NIF_ICON or NIF_TIP;
  tnid.uCallbackMessage:=WM_TASKBAREVENT;
  tnid.hIcon:=GammaForm.Icon.Handle;
  StrCopy(tnid.szTip, SystrayTextBuffer);
  TaskBarAddIcon;
  //Hotkeys registern
  RegisterKey(HKPlus,1);
  RegisterKey(HKMinus,2);
  RegisterKey(HKDefault,3);
end;

procedure TGammaForm.GraphBoxPaint(Sender: TObject);
begin
  if PatternButton.Down then begin
    DrawGammaPattern;
  end else begin
    DrawGammaGraph;
  end;  
end;

procedure TGammaForm.FormDestroy(Sender: TObject);
begin
  //unregister hotkeys
  UnregisterHotKey(Handle,1);
  UnregisterHotKey(Handle,2);
  UnregisterHotKey(Handle,3);
  //remove taskbarbutton
  TaskBarRemoveIcon;
  StrDispose(SystrayTextBuffer);
end;

procedure TGammaForm.DefButtonClick(Sender: TObject);
begin
  GammaTrackBar.Position:=500;
  GammaTrackBarChange(Sender);
end;

procedure TGammaForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
   owner: tHandle;
begin
  if Exiting=False then
  begin
    owner:=GetWindow(Handle, GW_OWNER);
    ShowWindow(owner, SW_HIDE);
    Action:=caNone;
    Hide;
    GammaForm.TaskBarAddIcon;
  end;
end;

procedure TGammaForm.CloseWindowClick(Sender: TObject);
begin
  Exiting:=true;
  Close;
end;

procedure TGammaForm.RestoreWindowClick(Sender: TObject);
begin
  Show;
  Application.BringToFront;
end;

procedure TGammaForm.InfoButtonClick(Sender: TObject);
var AF:TAboutForm;
begin
  AF:=TAboutForm.Create(self);
  AF.ShowModal;
  AF.Free;
end;

procedure TGammaForm.FormShow(Sender: TObject);
begin
  if (CPos.X + GammaForm.Width) > Screen.Width then begin
    GammaForm.Left:=CPos.x - GammaForm.Width-16;
  end else begin
    GammaForm.Left:=CPos.x+16;
  end;
  if (CPos.Y + GammaForm.Height) > Screen.Height then begin
    GammaForm.Top:=CPos.Y - GammaForm.Height-16;
  end else begin
    GammaForm.Top:=CPos.Y+16;
  end;
end;

procedure TGammaForm.HelpButtonClick(Sender: TObject);
begin
  UsageMeldung;
end;

procedure TGammaForm.FormActivate(Sender: TObject);
begin
  Gamma:=GetGammaDouble;
  if (Gamma > 0.98)and(Gamma < 1.02) then Gamma:=1;
  GammaTrackBar.Position:=round(1000/(Gamma+1));
end;

procedure TGammaForm.HKPlusHotKey(Sender: TObject);
begin
  Gamma:=GetGammaDouble;
  if (Gamma > 0.98)and(Gamma < 1.02) then Gamma:=1;
  GammaTrackBar.Position:=round(1000/(Gamma+1));
  GammaTrackBar.Position:=max(GammaTrackbar.Min,GammaTrackbar.Position-10);
  Gamma:=(1000-GammaTrackBar.Position)/GammaTrackBar.Position;
  SetGammaDouble(Gamma);
end;

procedure TGammaForm.HKMinusHotKey(Sender: TObject);
begin
  Gamma:=GetGammaDouble;
  if (Gamma > 0.98)and(Gamma < 1.02) then Gamma:=1;
  GammaTrackBar.Position:=round(1000/(Gamma+1));
  GammaTrackBar.Position:=min(GammaTrackbar.Max,GammaTrackbar.Position+10);
  Gamma:=(1000-GammaTrackBar.Position)/GammaTrackBar.Position;
  SetGammaDouble(Gamma);
end;

procedure TGammaForm.HKDefaultHotKey(Sender: TObject);
begin
  Gamma:=1;
  GammaTrackBar.Position:=round(1000/(Gamma+1));
  Gamma:=(1000-GammaTrackBar.Position)/GammaTrackBar.Position;
  SetGammaDouble(Gamma);
end;

procedure TGammaForm.SetupButtonClick(Sender: TObject);
var FSetup:TSetupForm;
begin
  //unregister hotkeys
  UnregisterHotKey(Handle,1);
  UnregisterHotKey(Handle,2);
  UnregisterHotKey(Handle,3);
  //do setup
  FSetup:=TSetupForm.Create(self);
  FSetup.Left:=(Screen.Width + FSetup.Width) shr 2;
  FSetup.Top:=(Screen.Height + FSetup.Height) shr 2;
  FSetup.ShowModal;
  FSetup.Free;
  LoadSetup;
  //register new hotkeys
  RegisterKey(HKPlus,1);
  RegisterKey(HKMinus,2);
  RegisterKey(HKDefault,3);
end;

procedure TGammaForm.KalibButtonClick(Sender: TObject);
var TestValue:double;
    Lower, Upper:double;
    SetupFile:TIniFile;
begin
  if MessageDlg('By clicking yes, this program will check, which gamma values are available on your machine.',mtConfirmation,[mbYes, mbNo],0) = mrYes then begin
    if SetGammaDouble(1) then begin

      //test upper bound
      TestValue:=1;
      while SetGammaDouble(TestValue) do begin
        TestValue:=TestValue+0.01;
      end;
      Upper:=TestValue;

      //test lower bound
      TestValue:=1;
      while SetGammaDouble(TestValue) do begin
        TestValue:=TestValue-0.01;
      end;
      Lower:=TestValue;

      SetGammaDouble(Gamma);

      //output result
      MessageDlg('Gamma-Settings work!'+#13#10+
                 'Available Range: '+FloatToStrF(Lower,FFFixed,4,2)+' - '+FloatToStrF(Upper,FFFixed,4,2),mtInformation,[mbOK],0);

      //set trackbar values
      GammaTrackBar.Min:=round(1000/(Upper+1));
      GammaTrackBar.Max:=round(1000/(Lower+1));

      //save to inifile
      SetupFile:=TIniFile.Create(GetIniFileName);
      SetupFile.WriteString('Calibration','Lower',inttostr(GammaTrackBar.Min));
      SetupFile.WriteString('Calibration','Upper',inttostr(GammaTrackBar.Max));

    end else begin
      MessageDlg('Gamma-Settings don''t work! Try another driver for your video card!',mtError,[mbOK],0);
    end;
  end;
end;

procedure TGammaForm.PatternButtonClick(Sender: TObject);
begin
  //To Avoid flickering, we change the Background Color to the
  //one being used by the draw algorithm
  if PatternButton.Down then begin
    self.Color:=RGB(128,128,128);
  end else begin
    self.Color:=clBlack;
  end;
end;

end.
