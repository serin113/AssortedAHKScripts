;
; Just a bunch of random AutoHotkey stuff. Some made by me, others from forum copypasta.
; Will add credits soon.
;
; - serin113
;

#NoEnv
; avoids checking empty variables to see if they are environment variables, for speeeeeeeeeeed

SendMode Input
; switches to the SendInput method for Send, SendRaw, Click, and MouseMove/Click/Drag

CoordMode, Mouse, Screen
; sets coordmode for mouse-related commands to be relative to either the active window or the screen


;
; Functions
;

ProcessWait(PidOrName) {
; wait for process (duh)

    Process, Wait, %PidOrName%
    return ErrorLevel
}

ProcessExist(PidOrName) {
; check if process exists (duhhh)

    Process, Exist, %PidOrName%
    return ErrorLevel
}

IsAlwaysOnTop(Window) {
; check if window is alwaysontop (duhhhhhhhhhhh)

    WinGet, ExStyle, ExStyle, %Window%
    return (ExStyle & 0x8)
}

DeskToggle(rainmeter) { 
; toggle between Rainmeter and the desktop icons

    GroupAdd,Stickies,ASticky
	; add all Stickies as a group (http://www.zhornsoftware.co.uk/stickies/)
	
    ControlGet, HWND, Hwnd,, SysListView321, ahk_class Progman
	; get the window handle of the desktop
	
    If HWND = ; if the handle is empty
        ControlGet, HWND, Hwnd,, SysListView321, ahk_class WorkerW
		; get the window handle of desktop, which actually changes on certain conditions:
		; (http://www.autoitscript.com/forum/topic/119783-desktop-class-workerw/ )
		
    If DllCall("IsWindowVisible", UInt, HWND) {
	; if the desktop window (i.e. the icons) is visible
	
        SplashTextOn,,,Switching to Rainmeter... ; show some b00ty lol jk
        WinHide, ahk_group Stickies ; hide the Stickies
        WinHide, ahk_id %HWND% ; hide the desktop
        Run %rainmeter% !Show * ; show all teh Rainmeter skins
        SplashTextOff ; hide yer b00ty
    }
    Else
    {
        SplashTextOn,,,Switching to Desktop... ; show some more b00ty
        Run %rainmeter% !Hide * ; hide all teh Rainmeter skins
        WinShow, ahk_id %HWND% ; show the desktop
        WinShow, ahk_group Stickies ; show the Stickies
        SplashTextOff ; hide yer b00ty again
    }
    return
}
PB_PushNote(PB_Token, PB_Title, PB_Message) {
; 'tis a copypasta
; the Pushbullet access token can be found at (https://www.pushbullet.com/account)

    WinHTTP := ComObjCreate("WinHTTP.WinHttpRequest.5.1") ; create an HTTP object
    WinHTTP.SetProxy(0) ; don't use the proxy
    WinHTTP.Open("POST", "https://api.pushbullet.com/v2/pushes", 0) ; open a POST request to the PB API
    WinHTTP.SetCredentials(PB_Token, "", 0) ; send the token to the API for auth
    WinHTTP.SetRequestHeader("Content-Type", "application/json") ; set the type of response to JSON
    PB_Body := "{""type"": ""note"", ""title"": """ PB_Title """, ""body"": """ PB_Message """}" ; set the notification info
    WinHTTP.Send(PB_Body) ; send the request
    Result := WinHTTP.ResponseText ; get the API response
    Status := WinHTTP.Status ; gets HTTP error codes
    return Status ; return the status
}

;
; Variables
;

rainmeter := "%ProgramFiles%\Rainmeter\Rainmeter.exe" ; assuming you did install Rainmeter in the default folder
nircmd := "C:\Users\%A_UserName%\OneDrive\nircmd-x64\nircmd.exe" ; well, NirCmd's in my OneDrive, so I used that as an example.
pushbullet := "%ProgramFiles%\Pushbullet\pushbullet.exe" ; assuming you installed Pushbullet in the default folder

;
; Other stuff to be run every time the script starts
;

; basically, hide the desktop and show Rainmeter every time the script starts (at log on for me)
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
; if MusicBee is actually open
; assuming you are in Windows 8, not sure how it is on other versions, but you can check with the Window Spy

:O?*:np/::
{
    WinGetTitle, musicbee_title, ahk_class WindowsForms10.Window.8.app.0.2bf8098_r12_ad1
	; assuming you let the title show the song and the artist, maybe you changed it or something
	
    StringTrimRight, mus_title, musicbee_title, 11
	; remove the not-so-elegant "MusicBee - " part in the title, such self-inserts
	
    SendRaw, %mus_title%
	; replace "np/" with the... thing
	
    return
}
#IfWinExist



;
; Ctrl+Space toggles pinning the active window to top
;

^SPACE::
{
    if IsAlwaysOnTop(A) {
	; if the active window is screen-greedy
	
        Winset, Alwaysontop, off, A ; make it less greedy
		
        splashtext = Unpinned ; get the status
    }
    else{
	; if it isn't greedy
	
        Winset, Alwaysontop, on, A ; make it more greedy
		
        splashtext = Pinned ; get the status
    }

    SplashTextOn,100,, %splashtext% ; report status to the authorities
	
    Sleep 100 ; take a rest
    SplashTextOff ; kill the authorities

    return
}



;
; Win+Q toggles showing the list of hotkeys (for reference)
;

#q::
{
    if !WinExist("Hotkeys"){
	; if the list is not on the screen
	
        SplashTextOn, 280, 180, Hotkeys, Ctrl-Space: Toggle window pin on top`nWin-T: Focus taskbar`nWin-Z: Switch Rainmeter and desktop`nCtrl-PrtSc: Snipping Tool`nShift-PrtSc: Quick screenshot`nCtrl-Shift-PrtSc: Quick window screenshot`nWin-A: Set window priority`nCtrl-Shift-C: Show clipboard`nCtrl-Alt-ArrowKeys: Media controls
        ; show the list
		
		return
    }
    
    SplashTextOff ; else, hide the list

    return
}



;
; Win+A shows a popup menu to set the priority of the active window
; *copypasta from the old AutoHotkey docs
;

#a::
{
    if !WinExist("Set Priority"){
	; if the pr0n isn't on screen
	
        WinGet, active_pid, PID, A ; get the ID of the pr0n
        WinGetTitle, active_title, A ; get the pr0n title
		
		; set up the pr0n with text, list of options, and such
        Gui, 5:Add, Text,, `n%active_title%`n
        Gui, 5:Add, ListBox, vMyListBox gMyListBox r5 w200, Normal|High|Low|BelowNormal|AboveNormal
        Gui, 5:Add, Button, default, OK
		
		; show the pr0n collection
        Gui, 5:Show,, Set Priority
        return ; get back at it when something interesting happens

		; if either Esc or the close button was pressed
        5GuiEscape:
        5GuiClose:
        Gui, Destroy ; delete the pr0n collection
        return

		; if an option was chosen without doubletouching
        MyListBox:
        if A_GuiEvent <> DoubleClick
        return ; screw it
			
        ; else
        5ButtonOK: ; if "Oh YEAAAAH" was pressed
		
		; get the pr0n collection and delete it
        GuiControlGet, MyListBox
        Gui, Destroy
		
		; set your priorities straight
        Process, Priority, %active_pid%, %MyListBox%
        if ErrorLevel ; if set straight
            MsgBox Success: Its priority was changed to "%MyListBox%". ; party
        else ; if priorities aren't set straight
            MsgBox Error: Its priority could not be changed to "%MyListBox%". ; cry
        return ; get back to business
    }
    else{
        Gui, 5:Destroy ; delete all the pr0n
        return ; cry silently
    }
}



;
; Win+T activates the taskbar if autohide is on
; *Yeah, I know this can be done in AHK. Just found NirCmd a bit easier. XD
;

#t::
{
    Run %nircmd% win activate class "Shell_TrayWnd" ; Wake up, taskbar.
    Run %nircmd% win focus class "Shell_TrayWnd" ; FOCUS.
    Run %nircmd% win settopmost class "Shell_TrayWnd" 1 ; GET UP NOW.
    
    return
}



;
; Win+Z toggles between showing the desktop icons and showing all Rainmeter skins
;

#z::
{
    DeskToggle(rainmeter) ; hide all the desktop pr0n
    Sleep 100 ; get back to bed
    
    return
}



;
; Ctrl-PrintScreen opens the Snipping Tool
;

^PrintScreen::
{
    Run, "C:\Windows\Sysnative\SnippingTool.exe",,UseErrorLevel ; Sysnative?
    if ErrorLevel="ERROR" ; Nope.
        Run, "C:\Windows\System32\SnippingTool.exe",,UseErrorLevel ; System32?
    if ErrorLevel="ERROR" ; Nope.
        Run, "C:\Windows\SysWOW64\SnippingTool.exe",,UseErrorLevel ; SysWOW64, then?
        
    return ; assuming SnippingTool can never fail to launch, which is false
}



;
; Shift+PrintScreen takes an instant screenshot of the whole and saves it to a folder in Pictures
;

+PrintScreen::
{
    RunWait %nircmd% savescreenshot C:\Users\%A_UserName%\Pictures\Screenshots\New\scr~$currdate.MM_dd_yyyy$-~$currtime.HH_mm_ss$.png
	; screencap that pr0n, fast!
	
	; party
    SplashTextOn,,,Done!
    Sleep 1500
    SplashTextOff
	
    return ; get back to browsing the Internet
}



;
; Ctrl+Shift+PrintScreen takes an instant screenshot of the active window and saves it to a folder in Pictures
;

^+PrintScreen::
{
    RunWait %nircmd% savescreenshotwin C:\Users\%A_UserName%\Pictures\Screenshots\New\scr~$currdate.MM_dd_yyyy$-~$currtime.HH_mm_ss$.png
	; screencap that pr0n, with added hassle!
    
	; party again
	SplashTextOn,,,Done!
    Sleep 1500
    SplashTextOff
	
    return ; browse /b/
}



;
; Pressing the (almost) useless Pause button (at least in Windows) starts a lame alarm that sets off after 1 hour
;

Pause::
{
	; start waiting for 1 damn hour
    SplashTextOn,,,Alarm at 1 hour
    Sleep 2000
    SplashTextOff
    Sleep 3598000
	
	; get annoyed by the lack of ability to cancel the alarm
    SplashTextOn,,,ALARM
    RunWait, %nircmd% loop 60 1 beep 900 150
    SplashTextOff
	
    return ; burn the computer
}



;
; Ctrl-Alt-ArrowKeys controls a music player indirectly using a Rainmeter plugin
;

^!Right::Run, %rainmeter% !CommandMeasure mPlayer Next
^!Down::Run, %rainmeter% !CommandMeasure mPlayer PlayPause
^!Left::Run, %rainmeter% !CommandMeasure mPlayer Previous
^!Up::Run, %rainmeter% !CommandMeasure mPlayer Stop
; Thanks for not interfering, Captain Obvious.



; Ctrl-Shift-C toggles showing the raw clipboard content

^+c::
{
    if !WinExist("Clipboard"){
	; if teh pr0n links aren't shown yet
        SplashTextOn, 400, 500, Clipboard, %clipboard% ; show teh links
    }
    else {
        SplashTextOff ; hide teh links
    }
	
    return ; party
}



;
; Enables pasting to cmd using Ctrl-V
; *Another copypasta
;

#IfWinActive ahk_class ConsoleWindowClass
^V::
{
	SendInput {Raw}%clipboard% ; Kinda like actually typing, but having a USB-connected robot send it. You lazy s**t.
	return
}
#IfWinActive



;
; Alt-WindowDrag drags the whole windows even if clicked from inside it
; *Just matches the exact thing done by most Linux desktops.
; **Such huge copypasta
;

Alt & LButton::
{
    CoordMode, Mouse
	; switch to screen/absolute coordinates
	; Wait, I've done this already, right?
	
    MouseGetPos, EWD_MouseStartX, EWD_MouseStartY, EWD_MouseWin
	; get the current pointer position
	
    WinGetPos, EWD_OriginalPosX, EWD_OriginalPosY,,, ahk_id %EWD_MouseWin%
	; get the ID of window below the pointer
	
    WinGet, EWD_WinState, MinMax, ahk_id %EWD_MouseWin% 
	; get the state of that window
	
    if EWD_WinState = 0  ; if the window isn't maximized 
        SetTimer, EWD_WatchMouse, 10 ; track the mouse as the user drags it
    return
	
    EWD_WatchMouse: ; watch that little arrow
    GetKeyState, EWD_LButtonState, LButton, P ; check the stats of your (overly abused) index finger
    if EWD_LButtonState = U  ; button has been released
    {
        SetTimer, EWD_WatchMouse, off ; drag is complete
        return
    }
    GetKeyState, EWD_EscapeState, Escape, P
    if EWD_EscapeState = D  ; escape has been pressed
    {
        SetTimer, EWD_WatchMouse, off ; drag is cancelled
        WinMove, ahk_id %EWD_MouseWin%,, %EWD_OriginalPosX%, %EWD_OriginalPosY% ; revert all the changes (ugh, Sisyphus)
        return
    }
	
    ; otherwise, reposition the window to match the change in mouse coordinates caused by the user having dragged the mouse
    CoordMode, Mouse ; AGAIN???
    MouseGetPos, EWD_MouseX, EWD_MouseY ; AGAIN????
    WinGetPos, EWD_WinX, EWD_WinY,,, ahk_id %EWD_MouseWin% ; AGAIN?????
    SetWinDelay, -1   ; makes the below move faster/smoother, but I dunno why
    WinMove, ahk_id %EWD_MouseWin%,, EWD_WinX + EWD_MouseX - EWD_MouseStartX, EWD_WinY + EWD_MouseY - EWD_MouseStartY ; Just move it.
    EWD_MouseStartX := EWD_MouseX  ; "Update for the next timer-call to this subroutine", whatever this command is.
    EWD_MouseStartY := EWD_MouseY
	
    return
}



;
; Another huge copypasta incoming.
; All from (http://hawkee.com/snippet/7910/).
; 'Tis already explained below, so I won't bother.
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