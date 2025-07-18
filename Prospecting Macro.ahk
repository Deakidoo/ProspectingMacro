#NoEnv
#SingleInstance
SendMode Input
SetWorkingDir %A_ScriptDir%

global Loop := 0
global TotalLoops :=0
global RepeatClicks := 10
global DigHoldTime := 0.65
global ShakeHoldTime := 25
global ActionDelay := 1.5
global DirectionTime := 1
global AutoSell := 0
global SellRate := 0
global DirectionChoice := Left/Right
global FirstDir := a
global SecondDir := d
global webhookURL :=
global MacroRunning := false
global MacroPaused := false

IniRead, RepeatClicks, settings.ini, Config, RepeatClicks, %RepeatClicks%
IniRead, DigHoldTime, settings.ini, Config, DigHoldTime, %DigHoldTime%
IniRead, ShakeHoldTime, settings.ini, Config, ShakeHoldTime, %ShakeHoldTime%
IniRead, ActionDelay, settings.ini, Config, ActionDelay, %ActionDelay%
IniRead, DirectionTime, settings.ini, Config, DirectionTime, %DirectionTime%
IniRead, savedChoice, settings.ini, Config, DirectionChoice, %DirectionChoice%
IniRead, AutoSell, settings.ini, Config, AutoSell, %AutoSell%
IniRead, SellRate, settings.ini, Config, SellRate, %SellRate%
IniRead, SellX, settings.ini, Config, SellX, %SellX%
IniRead, SellY, settings.ini, Config, SellY, %SellY%
IniRead, FirstDir, settings.ini, Config, FirstDir, %FirstDir%
IniRead, SecondDir, settings.ini, Config, SecondDir, %SecondDir%
IniRead, webhookURL, settings.ini, Config, webhookURL, %webhookURL%

Gui, Add, GroupBox, x10 y10 w280 h75, Dig Settings
Gui, Add, Edit, x20 y30 w30 h20 vRepeatClicks, %RepeatClicks%
Gui, Add, Text, x55 y33, Dig Repeat Count
Gui, Add, Edit, x20 y55 w30 h20 vDigHoldTime, %DigHoldTime%
Gui, Add, Text, x55 y58, Dig Hold Time (Seconds)

Gui, Add, GroupBox, x10 y90 w280 h50, Shake Settings
Gui, Add, Edit, x20 y110 w30 h20 vShakeHoldTime, %ShakeHoldTime%
Gui, Add, Text, x55 y113, Shake Hold Time (Seconds)

Gui, Add, GroupBox, x10 y145 w280 h95, Sell Settings
Gui, Add, CheckBox, x20 y165 vAutoSell Checked%AutoSell%, Auto-Sell Items
Gui, Add, Edit, x20 y185 w30 h20 vSellRate, %SellRate%
Gui, Add, Text, x55 y188, Sell every X Loops
Gui, Add, Button, x20 y210 gSetSellPosition, Set Sell All Button Position

Gui, Add, GroupBox, x10 y240 w280 h75, Movement Settings
Gui, Add, DropDownList, x20 y260 vDirectionChoice gUpdateDirection, Forward/Backward|Left/Right
GuiControl, ChooseString, DirectionChoice, %savedChoice%
Gui, Add, Text, x150 y263, Movement Type
Gui, Add, Edit, x20 y285 w30 h20 vDirectionTime, %DirectionTime%
Gui, Add, Text, x55 y288, Movement Hold Time (Seconds)

Gui, Add, GroupBox, x10 y315 w280 h75, Other Settings
Gui, Add, Edit, x20 y335 w30 h20 vActionDelay, %ActionDelay%
Gui, Add, Text, x55 y338, Delay Between Actions (Seconds)
Gui, Add, Edit, x20 y360 w120 h20 vwebhookURL, %webhookURL%
Gui, Add, Text, x150 y363, Discord Webhook Link

Gui, Add, Button, x10 y395 w280 h30 gSaveSettings, Save Settings

Gui, Add, Button, x10 y425 w140 h30 gStartMacro, Start Macro (F1)
Gui, Add, Button, x150 y425 w140 h30 Reload, Stop Macro (F2)

Gui, Show, w300 h465, Prospecting Macro
return

GuiClose:
ExitApp
return

SendDiscordMessage(webhookURL, message) {

    FormatTime, messageTime, , hh:mm:ss tt
    fullMessage := "[" . messageTime . "] " . message

    json := "{""content"": """ . fullMessage . """}"
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")

    try {
        whr.Open("POST", webhookURL, false)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(json)
        whr.WaitForResponse()
        status := whr.Status

        if (status != 200 && status != 204) {
            return
        }
    } catch {
        return
    }

}

UpdateDirection:
Gui, Submit, NoHide
if (DirectionChoice = "Forward/Backward") {
    FirstDir := "w"
    SecondDir := "s"
} else {
    FirstDir := "a"
    SecondDir := "d"
}
GuiControl,, FirstDir, %FirstDir%
GuiControl,, SecondDir, %SecondDir%
return

SetSellPosition:
Gui, Hide
ToolTip, Click on Sell All button to set its position
KeyWait, LButton, D
MouseGetPos, SellX, SellY
ToolTip, Sell All Position set!
Sleep, 1000
ToolTip
Gui, Show
return

SaveSettings:
Gui, Submit, NoHide
IniWrite, %RepeatClicks%, settings.ini, Config, RepeatClicks
IniWrite, %DigHoldTime%, settings.ini, Config, DigHoldTime
IniWrite, %ShakeHoldTime%, settings.ini, Config, ShakeHoldTime
IniWrite, %ActionDelay%, settings.ini, Config, ActionDelay
IniWrite, %AutoSell%, settings.ini, Config, AutoSell
IniWrite, %SellRate%, settings.ini, Config, SellRate
IniWrite, %SellX%, settings.ini, Config, SellX
IniWrite, %SellY%, settings.ini, Config, SellY
IniWrite, %DirectionTime%, settings.ini, Config, DirectionTime
IniWrite, %DirectionChoice%, settings.ini, Config, DirectionChoice
IniWrite, %FirstDir%, settings.ini, Config, FirstDir
IniWrite, %SecondDir%, settings.ini, Config, SecondDir
IniWrite, %webhookURL%, settings.ini, Config, webhookURL
ToolTip, Settings Saved!
Sleep, 1000
ToolTip
return

StartMacro:
Gui, Submit, NoHide
SendDiscordMessage(webhookURL, " Macro Started" )
MacroRunning := true
SetTimer, MacroLoop, -1
return

MacroLoop:
while (MacroRunning) {
    Loop++
    TotalLoops++
    ToolTip, Walking
    Send {%FirstDir% down}
    Sleep, % DirectionTime * 1000
    Send {%FirstDir% up}
    Sleep, % ActionDelay * 1000
    
    ToolTip, Digging
    Loop, %RepeatClicks% {
        Click down
        Sleep, % DigHoldTime * 1000
        Click up
        Sleep, 1500
    }
    
    ToolTip, Walking
    Sleep, % ActionDelay * 1000
    Send {%SecondDir% down}
    Sleep, % DirectionTime * 1000
    Send {%SecondDir% up}
    Sleep, % ActionDelay * 1000
    
    Click down
    Sleep 1000
    Click up
    ToolTip, Shaking
    Click down
    Sleep, % ShakeHoldTime * 1000
    Click up
    
    if (AutoSell = 1 && Loop >= SellRate) {
        ToolTip, Auto Selling
        Loop := 0
        Send g
        Sleep, 1000
        Random, randX, -10, 10
        Random, randY, -10, 10
        MouseMove, % SellX+randX, % SellY+randY, 0
        Sleep, 250
        Click
        Click
        Click
        SendDiscordMessage(webhookURL, " Auto Sold!" )
        Sleep, 3500
        Send g
    }

    ToolTip, Looping
    SendDiscordMessage(webhookURL, " Loop Completed, Total Loops Completed: " TotalLoops )
    Sleep, % ActionDelay * 1000
}
return

F1::Gosub, StartMacro
F2::Reload
