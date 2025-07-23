; Created by Deakidoo!

#NoEnv
#SingleInstance
SendMode Input
SetWorkingDir %A_ScriptDir%

global DigX := 1162
global DigY := 472
global DigGX := 1206
global DigGY := 819
global ShakeX := 731 
global ShakeY := 815
global Loop := 0
global TotalLoops :=0
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

IniRead, DigX, settings.ini, Config, DigX, %DigX%
IniRead, DigY, settings.ini, Config, DigY, %DigY%
IniRead, DigGX, settings.ini, Config, DigGX, %DigGX%
IniRead, DigGY, settings.ini, Config, DigGY, %DigGY%
IniRead, ShakeX, settings.ini, Config, ShakeX, %ShakeX%
IniRead, ShakeY, settings.ini, Config, ShakeY, %ShakeY%
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

Gui, Add, GroupBox, x10 y0 w280 h95, Positions
Gui, Add, Button, x20 y15 gSetDigHoldPosition, Dig Charge Position
Gui, Add, Button, x20 y40 gSetDigGuagePosition, Dig Repeat Position
Gui, Add, Button, x20 y65 gSetShakeGuagePosition, Shake Hold Position

Gui, Add, GroupBox, x10 y100 w280 h95, Sell Settings
Gui, Add, CheckBox, x20 y115 vAutoSell Checked%AutoSell%, Auto-Sell Items
Gui, Add, Edit, x20 y135 w30 h20 vSellRate, %SellRate%
Gui, Add, Text, x55 y138, Sell every X Loops
Gui, Add, Button, x20 y160 gSetSellPosition, Set Sell All Button Position

Gui, Add, GroupBox, x10 y200 w280 h75, Movement Settings
Gui, Add, DropDownList, x20 y220 vDirectionChoice gUpdateDirection, Forward/Backward|Left/Right
GuiControl, ChooseString, DirectionChoice, %savedChoice%
Gui, Add, Text, x150 y223, Movement Type
Gui, Add, Edit, x20 y245 w30 h20 vDirectionTime, %DirectionTime%
Gui, Add, Text, x55 y248, Movement Hold Time (Seconds)

Gui, Add, GroupBox, x10 y280 w280 h75, Other Settings
Gui, Add, Edit, x20 y300 w30 h20 vActionDelay, %ActionDelay%
Gui, Add, Text, x55 y303, Delay Between Actions (Seconds)
Gui, Add, Edit, x20 y325 w120 h20 vwebhookURL, %webhookURL%
Gui, Add, Text, x150 y325, Discord Webhook Link

Gui, Add, Button, x10 y360 w280 h30 gSaveSettings, Save Settings

Gui, Add, Button, x10 y390 w140 h30 gStartMacro, Start Macro (F1)
Gui, Add, Button, x150 y390 w140 h30 Reload, Stop Macro (F2)

Gui, Show, w300 h430, Prospecting Macro
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
IniWrite, %DirectionChoice%, settings.ini, Config, DirectionChoice
IniWrite, %FirstDir%, settings.ini, Config, FirstDir
IniWrite, %SecondDir%, settings.ini, Config, SecondDir
return

SetSellPosition:
Gui, Hide
ToolTip, Click on Sell All button to set its position.
KeyWait, LButton, D
MouseGetPos, SellX, SellY
ToolTip, Position Set!
Sleep, 1000
ToolTip
Gui, Show
return

SetDigHoldPosition:
Gui, Hide
ToolTip, Hover over the green area of the dig charge bar and press space to set the position.
KeyWait, Space, D
MouseGetPos, DigX, DigY
ToolTip, Position Set!
Sleep, 1000
ToolTip
Gui, Show
return

SetDigGuagePosition:
Gui, Hide
ToolTip, Click on the far left of the pan fill area. (GRAY AREA)
KeyWait, LButton, D
MouseGetPos, DigGX, DigGY
ToolTip, Position Set!
Sleep, 1000
ToolTip
Gui, Show
return

SetShakeGuagePosition:
Gui, Hide
ToolTip, Click on the far right of the pan fill area. (GRAY AREA)
KeyWait, LButton, D
MouseGetPos, ShakeX, ShakeY
ToolTip, Position Set!
Sleep, 1000
ToolTip
Gui, Show
return

SaveSettings:
Gui, Submit, NoHide
IniWrite, %DigX%, settings.ini, Config, DigX
IniWrite, %DigY%, settings.ini, Config, DigY
IniWrite, %DigGX%, settings.ini, Config, DigGX
IniWrite, %DigGY%, settings.ini, Config, DigGY
IniWrite, %ShakeX%, settings.ini, Config, ShakeX
IniWrite, %ShakeY%, settings.ini, Config, ShakeY
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
global Loop = 0
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
    Loop, {
        PixelGetColor, PixelColor, % DigGX, DigGY, RGB
        if (PixelColor != 0x8C8C8C)
            break
        Click down
        Loop {
            PixelGetColor, PixelColor, DigX, DigY, RGB
            if (PixelColor = 0xFFFFFF)
                break
            Sleep, 2
        }
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
    Loop {
        PixelGetColor, PixelColor, ShakeX, ShakeY, RGB
        if (PixelColor = 0x8C8C8C)
            break
        Sleep, 10
    }
    Click up
    Sleep 1500
    
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
