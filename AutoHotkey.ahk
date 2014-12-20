;
; Just a bunch of random AutoHotkey stuff. Some made by me, others from forum copypasta.
; Will add credits soon.
;
; - serin113
;

#NoEnv
SendMode Input
CoordMode, Mouse, Screen

;
; Functions
;

ProcessWait(PidOrName) { ; wait for process (duh)
    Process, Wait, %PidOrName%
    return ErrorLevel
}
ProcessExist(PidOrName) { ; check if process exists (duhh)
    Process, Exist, %PidOrName%
    return ErrorLevel
}
IsAlwaysOnTop(Window) { ; check if window is alwaysontop (stop it captain obvious)
	WinGet, ExStyle, ExStyle, %Window%
	return (ExStyle & 0x8)
}
DeskToggle(rainmeter) {
	GroupAdd,Stickies,ASticky ; Stickies class
	ControlGet, HWND, Hwnd,, SysListView321, ahk_class Progman
	If HWND =
		ControlGet, HWND, Hwnd,, SysListView321, ahk_class WorkerW
	If DllCall("IsWindowVisible", UInt, HWND)
	{
		SplashTextOn,,,Switching to Rainmeter...
		WinHide, ahk_group Stickies
		WinHide, ahk_id %HWND%
		Run %rainmeter% !Show *
		SplashTextOff
	}
	Else
	{
		SplashTextOn,,,Switching to Desktop...
		Run %rainmeter% !Hide *
		WinShow, ahk_id %HWND%
		WinShow, ahk_group Stickies
		SplashTextOff
	}
	return
}
PB_PushNote(PB_Token, PB_Title, PB_Message) {
	; your access token can be found at (https://www.pushbullet.com/account)

    WinHTTP := ComObjCreate("WinHTTP.WinHttpRequest.5.1")
    WinHTTP.SetProxy(0)
    WinHTTP.Open("POST", "https://api.pushbullet.com/v2/pushes", 0)
    WinHTTP.SetCredentials(PB_Token, "", 0)
    WinHTTP.SetRequestHeader("Content-Type", "application/json")
    PB_Body := "{""type"": ""note"", ""title"": """ PB_Title """, ""body"": """ PB_Message """}"
    WinHTTP.Send(PB_Body)
    Result := WinHTTP.ResponseText
    Status := WinHTTP.Status
    return Status
}

;
; Variables
;

rainmeter := "%ProgramFiles%\Rainmeter\Rainmeter.exe"
nircmd := "C:\Users\%A_UserName%\OneDrive\nircmd-x64\nircmd.exe" ; well, NirCmd's in my OneDrive, so I used that as an example
pushbullet := "%ProgramFiles%\Pushbullet\pushbullet.exe"

;
; Other stuff to be run every time the script starts
;

ControlGet, HWND, Hwnd,, SysListView321, ahk_class Progman
If HWND =
	ControlGet, HWND, Hwnd,, SysListView321, ahk_class WorkerW
If DllCall("IsWindowVisible", UInt, HWND)
	DeskToggle(rainmeter)

RETURN ; end initialization

; =======
; HOTKEYS
; =======



;
; Autoreplaces "np/" with "Song - Artist" in MusicBee
;

#IfWinExist ahk_class WindowsForms10.Window.8.app.0.2bf8098_r12_ad1
:O?*:np/::
{
	WinGetTitle, musicbee_title, ahk_class WindowsForms10.Window.8.app.0.2bf8098_r12_ad1
	StringTrimRight, mus_title, musicbee_title, 11
	SendRaw, %mus_title%
	return
}
#IfWinExist



;
; Ctrl+Space toggles pinning the active window to top
;

^SPACE::
{
	if IsAlwaysOnTop(A) {
		Winset, Alwaysontop, off, A
		splashtext = Unpinned
	}
	else{
		Winset, Alwaysontop, on, A
		splashtext = Pinned
	}

	SplashTextOn,100,, %splashtext%
	Sleep 1000
	SplashTextOff

	return
}



;
; Win+Q toggles showing the list of hotkeys (for reference)
;

#q::
{
	if !WinExist("Hotkeys"){
		SplashTextOn, 280, 180, Hotkeys, Ctrl-Space: Toggle window pin on top`nWin-T: Focus taskbar`nWin-Z: Switch Rainmeter and desktop`nCtrl-PrtSc: Snipping Tool`nShift-PrtSc: Quick screenshot`nCtrl-Shift-PrtSc: Quick window screenshot`nWin-A: Set window priority`nCtrl-Shift-C: Show clipboard`nCtrl-Alt-ArrowKeys: Media controls
		return
	}
	
	SplashTextOff

	return
}



;
; Win+A shows a popup menu to set the priority of the active window
; *copypasta from the old AutoHotkey docs
;

#a::
{
	if !WinExist("Set Priority"){
		WinGet, active_pid, PID, A
		WinGetTitle, active_title, A
		Gui, 5:Add, Text,, `n%active_title%`n
		Gui, 5:Add, ListBox, vMyListBox gMyListBox r5 w200, Normal|High|Low|BelowNormal|AboveNormal
		Gui, 5:Add, Button, default, OK
		Gui, 5:Show,, Set Priority
		return

		5GuiEscape:
		5GuiClose:
		Gui, Destroy
		return

		MyListBox:
		if A_GuiEvent <> DoubleClick
			return
		; else fall through to the next label:
		5ButtonOK:
		GuiControlGet, MyListBox
		Gui, Destroy
		Process, Priority, %active_pid%, %MyListBox%
		if ErrorLevel
			MsgBox Success: Its priority was changed to "%MyListBox%".
		else
			MsgBox Error: Its priority could not be changed to "%MyListBox%".
		return
	}
	else{
		Gui, 5:Destroy
		return
	}
}



;
; Win+T activates the taskbar if autohide is on
; *Yeah, I know this can be done in AHK. Just found NirCmd a bit easier. XD
;

#t::
{
	Run %nircmd% win activate class "Shell_TrayWnd"
	Run %nircmd% win focus class "Shell_TrayWnd"
	Run %nircmd% win settopmost class "Shell_TrayWnd" 1
	
	return
}



;
; Win+Z toggles between showing the desktop icons and showing all Rainmeter skins
;

#z::
{
	DeskToggle(rainmeter)
	Sleep 100
	
	return
}



;
; Ctrl-PrintScreen opens the Snipping Tool
;

^PrintScreen::
{
	Run, "C:\Windows\Sysnative\SnippingTool.exe",,UseErrorLevel
	if ErrorLevel="ERROR"
		Run, "C:\Windows\System32\SnippingTool.exe",,UseErrorLevel
	if ErrorLevel="ERROR"
		Run, "C:\Windows\SysWOW64\SnippingTool.exe",,UseErrorLevel ; hooray for trial-and-error =p
		
	return
}



;
; Shift+PrintScreen takes an instant screenshot of the whole and saves it to a folder in Pictures
;

+PrintScreen::
{
	RunWait %nircmd% savescreenshot C:\Users\%A_UserName%\Pictures\Screenshots\New\scr~$currdate.MM_dd_yyyy$-~$currtime.HH_mm_ss$.png
	SplashTextOn,,,Done!
	Sleep 1500
	SplashTextOff
	Return
}



;
; Ctrl+Shift+PrintScreen takes an instant screenshot of the active window and saves it to a folder in Pictures
;

^+PrintScreen::
{
	RunWait %nircmd% savescreenshotwin C:\Users\%A_UserName%\Pictures\Screenshots\New\scr~$currdate.MM_dd_yyyy$-~$currtime.HH_mm_ss$.png
	SplashTextOn,,,Done!
	Sleep 1500
	SplashTextOff
	Return
}



;
; Pressing the (almost) useless Pause button (at least in Windows) starts a lame alarm that sets off after 1 hour
;

Pause::
{
	SplashTextOn,,,Alarm at 1 hour
	Sleep 2000
	SplashTextOff
	Sleep 3598000
	SplashTextOn,,,ALARM
	RunWait, %nircmd% loop 60 1 beep 900 150
	SplashTextOff
	return
}



;
; Ctrl-Alt-ArrowKeys controls a music player indirectly using a Rainmeter plugin
;

^!Right::Run, %rainmeter% !CommandMeasure mPlayer Next
^!Down::Run, %rainmeter% !CommandMeasure mPlayer PlayPause
^!Left::Run, %rainmeter% !CommandMeasure mPlayer Previous
^!Up::Run, %rainmeter% !CommandMeasure mPlayer Stop



; Ctrl-Shift-C toggles showing the raw clipboard content

^+c::
{
	if !WinExist("Clipboard"){
		SplashTextOn, 400, 500, Clipboard, %clipboard%
	}
	else {
		SplashTextOff
	}
	return
}



;
; Enables pasting to cmd using Ctrl-V
; *another copypasta
;

#IfWinActive ahk_class ConsoleWindowClass
^V::
{
SendInput {Raw}%clipboard%
return
}
#IfWinActive



;
; Alt-WindowDrag drags the whole windows even if clicked from inside it
; *Just matches the exact thing done by most Linux desktops.
; **Yet another copypasta
;

Alt & LButton::
{
    CoordMode, Mouse  ; Switch to screen/absolute coordinates.
    MouseGetPos, EWD_MouseStartX, EWD_MouseStartY, EWD_MouseWin
    WinGetPos, EWD_OriginalPosX, EWD_OriginalPosY,,, ahk_id %EWD_MouseWin%
    WinGet, EWD_WinState, MinMax, ahk_id %EWD_MouseWin% 
    if EWD_WinState = 0  ; Only if the window isn't maximized 
        SetTimer, EWD_WatchMouse, 10 ; Track the mouse as the user drags it.
    return
    EWD_WatchMouse:
    GetKeyState, EWD_LButtonState, LButton, P
    if EWD_LButtonState = U  ; Button has been released, so drag is complete.
    {
        SetTimer, EWD_WatchMouse, off
        return
    }
    GetKeyState, EWD_EscapeState, Escape, P
    if EWD_EscapeState = D  ; Escape has been pressed, so drag is cancelled.
    {
        SetTimer, EWD_WatchMouse, off
        WinMove, ahk_id %EWD_MouseWin%,, %EWD_OriginalPosX%, %EWD_OriginalPosY%
        return
    }
    ; Otherwise, reposition the window to match the change in mouse coordinates
    ; caused by the user having dragged the mouse:
    CoordMode, Mouse
    MouseGetPos, EWD_MouseX, EWD_MouseY
    WinGetPos, EWD_WinX, EWD_WinY,,, ahk_id %EWD_MouseWin%
    SetWinDelay, -1   ; Makes the below move faster/smoother.
    WinMove, ahk_id %EWD_MouseWin%,, EWD_WinX + EWD_MouseX - EWD_MouseStartX, EWD_WinY + EWD_MouseY - EWD_MouseStartY
    EWD_MouseStartX := EWD_MouseX  ; Update for the next timer-call to this subroutine.
    EWD_MouseStartY := EWD_MouseY
    return
}



;
; Huge copypasta incoming. 'Tis already explained below.
;


; Prohibit applications from disabling windows or controls, by simply clicking
; on them.  This is especially useful when you wish to access a parent window
; while a settings or dialog window is visible, ie; a Save/Open dialog.
; 
; Example:  Winamp's main window becomes disabled when selecting an Equalizer
; setting from the list of presets.  This script makes Winamp always accessible,
; so you can always keep the preset list open if you desire. -- Raccoon 2010

Enable_Window_Under_Cursor() ; By Raccoon 31-Aug-2010
{
  MouseGetPos,,, WinHndl, CtlHndl, 2
  WinGet, Style, Style, ahk_id %WinHndl%
  if (Style & 0x8000000) { ; WS_DISABLED.
    WinSet, Enable,, ahk_id %WinHndl%
  }
  WinGet, Style, Style, ahk_id %CtlHndl%
  if (Style & 0x8000000) { ; WS_DISABLED.
    WinSet, Enable,, ahk_id %CtlHndl%
  }
}

;#If Enable_Window_Under_Cursor()||True
;~LButton::Return
;#If ; End If

~LButton::
{
  if (Enable_Window_Under_Cursor()||True)
  {
    Return
  }
  else
  {
    Enable_Window_Under_Cursor()
    Return
  }
}