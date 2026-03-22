; NSIS installer script for hello-world-gui
; Usage: makensis -DVERSION=v1.0.0 -DARCH=x86_64 hello-world-gui.nsi
; The hello-world-gui.exe binary must be in the same directory as this script.

Unicode true

!ifndef VERSION
  !define VERSION "dev"
!endif
!ifndef ARCH
  !define ARCH "x86_64"
!endif

!define APP_NAME    "Hello World GUI"
!define APP_EXE     "hello-world-gui.exe"
!define REG_KEY     "Software\Microsoft\Windows\CurrentVersion\Uninstall\HelloWorldGUI"

Name          "${APP_NAME}"
OutFile       "hello-world-gui-windows-${ARCH}-setup.exe"
Icon          "hello-world-gui.ico"
UninstallIcon "hello-world-gui.ico"
InstallDir    "$PROGRAMFILES64\${APP_NAME}"
RequestExecutionLevel admin
SetCompressor lzma

Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles

Section "Install"
  SetOutPath "$INSTDIR"
  File "${APP_EXE}"
  WriteUninstaller "$INSTDIR\uninstall.exe"
  CreateShortcut "$DESKTOP\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}"
  CreateDirectory "$SMPROGRAMS\${APP_NAME}"
  CreateShortcut  "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${APP_EXE}"
  WriteRegStr HKLM "${REG_KEY}" "DisplayName"     "${APP_NAME}"
  WriteRegStr HKLM "${REG_KEY}" "DisplayVersion"  "${VERSION}"
  WriteRegStr HKLM "${REG_KEY}" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "${REG_KEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "${REG_KEY}" "DisplayIcon"     "$INSTDIR\${APP_EXE},0"
SectionEnd

Section "Uninstall"
  Delete "$INSTDIR\${APP_EXE}"
  Delete "$INSTDIR\uninstall.exe"
  Delete "$DESKTOP\${APP_NAME}.lnk"
  Delete "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk"
  RMDir  "$SMPROGRAMS\${APP_NAME}"
  RMDir  "$INSTDIR"
  DeleteRegKey HKLM "${REG_KEY}"
SectionEnd
