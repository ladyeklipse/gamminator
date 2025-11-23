; gamminator.nsi
;
; Install Script for NSIS
;
; by Wolfgang Freiler

;--------------------------------

  Name "Gamminator 0.5.7.0"
  OutFile "gamminator-0.5.7-setup.exe"

  InstallDir "$PROGRAMFILES\Gamminator"

;--------------------------------

LicenseText "GNU General Public License: http://www.gnu.org/licenses/gpl.txt"
LicenseData "gpl.txt"


VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "Gamminator"
VIProductVersion "0.5.7.0"




  ;Pages
  Page license
  Page directory
  ;Page instfiles

  UninstPage uninstConfirm
  UninstPage instfiles


Page custom StartMenuGroupSelect "" ": Start Menu Folder"
Function StartMenuGroupSelect
	Push $R1

	StartMenu::Select /checknoshortcuts "Don't create a start menu folder" /autoadd /lastused $R0 "Gamminator"
	Pop $R1

	StrCmp $R1 "success" success
	StrCmp $R1 "cancel" done
		; error
		MessageBox MB_OK $R1
		Return
	success:
	Pop $R0

	done:
	Pop $R1
FunctionEnd

Page instfiles
Section

	SetOutPath $INSTDIR
	File "build\gamminator.exe"
	File "gpl.txt"
	File "readme.txt"
	File "color.ico"

 	;Uninstall-Information
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Gamminator" "DisplayName" "Gamminator"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Gamminator" "UninstallString" "$INSTDIR\Uninst.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Gamminator" "DisplayIcon" "$INSTDIR\color.ico"

    WriteUninstaller "$INSTDIR\Uninst.exe"


	# this part is only necessary if you used /checknoshortcuts
	StrCpy $R1 $R0 1
	StrCmp $R1 ">" skip

		SetShellVarContext All
		CreateDirectory $SMPROGRAMS\$R0
		CreateShortCut "$SMPROGRAMS\$R0\Gamminator.lnk" $INSTDIR\gamminator.exe
		CreateShortCut "$SMPROGRAMS\$R0\Readme.lnk" $INSTDIR\readme.txt
		CreateShortCut "$SMPROGRAMS\$R0\GNU General Public License.lnk" $INSTDIR\gpl.txt
		CreateShortCut "$SMPROGRAMS\$R0\Uninstall Gamminator.lnk" $INSTDIR\uninst.exe
        WriteRegStr HKLM "SOFTWARE\Gamminator" "StartMenu" $R0

	skip:
SectionEnd



Section "Uninstall"

  Delete "$INSTDIR\uninst.exe"

  Delete "$INSTDIR\gamminator.exe"
  Delete "$INSTDIR\gpl.txt"
  Delete "$INSTDIR\color.ico"
  
  RMDir "$INSTDIR"
  
  #delete start menu
  
  ReadRegStr $R0 HKLM "Software\Gamminator" "StartMenu"
  
  SetShellVarContext All
  Delete "$SMPROGRAMS\$R0\Gamminator.lnk"
  Delete "$SMPROGRAMS\$R0\Readme.lnk"
  Delete "$SMPROGRAMS\$R0\GNU General Public License.lnk"
  Delete "$SMPROGRAMS\$R0\Uninstall Gamminator.lnk"
  RMDir "$SMPROGRAMS\$R0"

  DeleteRegKey HKLM "SOFTWARE\Gamminator"
  #DeleteRegValue HKLM "SOFTWARE\Gamminator" "StartMenu"
  DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Gamminator"

SectionEnd
