
<#
    .SYNOPSIS

    PowerBomber a text based game based on Bomber Man.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 21
    Code listing: PowerBomber.ps1
    
    .EXAMPLE
    C:\PS> .\PowerBomber.ps1
#>


using module '.\Modules\PathFinder.psm1'
using module '.\Modules\Level.psm1'
using module '.\Modules\GameObject.psm1'
using module '.\Modules\Sound.psm1'

#Variables###########################
$global:gameLoopRunning = $True
$global:exitGame = $false
$global:displayWidth = 107
$global:displayHeight = 52
$global:playerScore = 0
$global:highScore = 0
$global:currentLevel = -1
$global:gameLevelCount = 0

#Performance Metrics
$global:fps = 0
$global:frames = 0
$global:fpsTimer = New-Object -TypeName System.Diagnostics.Stopwatch 
$global:totalFrames = 0 #used to trigger events that dont fire every frame

$global:titleScreen = ""
$global:gameOverScreen = ""
$global:endGameScreen = ""
$global:gameCompeteScreen = ""

[System.Collections.ArrayList]$global:screenBuffer = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$global:backgroundBuffer = New-Object System.Collections.ArrayList
[System.Collections.ArrayList]$global:levels = New-Object System.Collections.ArrayList

[PathFinder]$global:pathFinder

#####################################

#Functions#########################################################################################################
function LoadLevel([string]$file) {
    [Array]$buffer = @()
   
    #read lines and loop through each line
    Get-Content $file | ForEach-Object {
        $buffer += $_
    }

    return $buffer
} 

function Setup-Display([int]$width, [int] $height) {
    $psHost = Get-Host
    $window = $psHost.ui.rawui
    $newSize = $window.windowsize
    $newSize.height = $height
    $newSize.width = $width
    $window.windowsize = $newSize
}

function Read-Character() {
    
    if ([console]::KeyAvailable) {
        return $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
    }

    return $null
}


function Clear-ScreenBuffer() {
    for ($i = 0; $i -lt 110; $i++) { 
        $null = $global:screenBuffer.Add(@(""))
    }
}


function Move-Cursor([int]$x, [int] $y) {
    $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $x , $y
} 

function Spawn-Bomb([Guid]$oID, [int]$x, [int] $y) {
    $bomb = New-Object GameObject
    $bomb.LoadObject("Bomb.txt")
    $bomb.xPosition = $x
    $bomb.yPosition = $y
    $bomb.OriginID = $oID
    $bomb.SetupJob($global:levels[$global:currentLevel])
    $global:levels[$global:currentLevel].objects += $bomb
} 

function Read-PlayerInput() {
    #See what keys the player is pressing
    $char = Read-Character

    $global:levels[$global:currentLevel].objects[0].xPositionOld = $global:levels[$global:currentLevel].objects[0].xPosition;
    $global:levels[$global:currentLevel].objects[0].yPositionOld = $global:levels[$global:currentLevel].objects[0].yPosition;

  
    if ($char -eq 'q') {
        $global:exitGame = $True
        $global:gameLoopRunning = $False
    }
    elseif ($char -eq 'a') {
        $global:levels[$global:currentLevel].objects[0].PlaySound("MOVE")
        $global:levels[$global:currentLevel].objects[0].xPosition -= 5
    }
    elseif ($char -eq 'd') {
        $global:levels[$global:currentLevel].objects[0].PlaySound("MOVE")
        $global:levels[$global:currentLevel].objects[0].xPosition += 5
    }
    elseif ($char -eq 'w') {
        $global:levels[$global:currentLevel].objects[0].PlaySound("MOVE")
        $global:levels[$global:currentLevel].objects[0].yPosition -= 3
    }
    elseif ($char -eq 's') {
        $global:levels[$global:currentLevel].objects[0].PlaySound("MOVE")
        $global:levels[$global:currentLevel].objects[0].yPosition += 3
    }
    elseif ($char -eq ' ') {
        Spawn-Bomb $global:levels[$global:currentLevel].objects[0].ID ($global:levels[$global:currentLevel].objects[0].xPosition) ($global:levels[$global:currentLevel].objects[0].yPosition)
    }
    elseif ($char -eq 't') {
    }

    #Keep player inside the display
    if ($global:levels[$global:currentLevel].objects[0].xPosition -le 0) {
        $global:levels[$global:currentLevel].objects[0].xPosition = 1
    }
    elseif ($global:levels[$global:currentLevel].objects[0].xPosition -ge $global:displayWidth - $global:levels[$global:currentLevel].objects[0].objectWidth) {
        $global:levels[$global:currentLevel].objects[0].xPosition = $global:displayWidth - $global:levels[$global:currentLevel].objects[0].objectWidth - 1
    }

    if ($global:levels[$global:currentLevel].objects[0].yPosition -le 5) {
        $global:levels[$global:currentLevel].objects[0].yPosition = 5
    }
    elseif ($global:levels[$global:currentLevel].objects[0].yPosition -ge ($global:displayHeight - $global:levels[$global:currentLevel].objects[0].objectHeight) - 2) {
        $global:levels[$global:currentLevel].objects[0].yPosition = ($global:displayHeight - $global:levels[$global:currentLevel].objects[0].objectHeight - 2)
    }
}

function Remove-DeadObjects() {
    $totalDead = 0
    for ($i = 0; $i -lt $global:levels[$global:currentLevel].objects.Count; $i++) {
        if ($global:levels[$global:currentLevel].objects[$i].IsDead()) {
            $totalDead++
        }
    }

    if ($totalDead -eq 0) {
        return
    }

    for ($i = 0; $i -lt $global:levels[$global:currentLevel].objects.Count; $i++) {
        if ($global:levels[$global:currentLevel].objects[$i].IsDead()) {
            $global:levels[$global:currentLevel].objects.RemoveAt($i)
        }
    }

    Remove-DeadObjects
}

function Collide($objectA, $objectB) {
    if ($objectA.IsDead() -or $objectB.IsDead()) {
        return $false
    }

    [bool]$collide = $false


    #speed increase#########
    if (($objectA.xPosition + $objectA.objectWidth) -lt $objectB.xPosition) {
        return $collide
    }

    if ($objectA.xPosition -gt ($objectB.xPosition + $objectB.objectWidth)) {
        return $collide
    }

    if (($objectA.yPosition + $objectA.objectHeight) -lt $objectB.yPosition) {
        return $collide
    }

    if ($objectA.yPosition -gt ($objectB.yPosition + $objectB.object.Height)) {
        return $collide
    }
    ########################

    
    if ($objectA.xPosition -lt ($objectB.xPosition + $objectB.objectWidth) -and ($objectA.xPosition + $objectA.objectWidth) -gt $objectB.xPosition -and $objectA.yPosition -lt ($objectB.yPosition + $objectB.objectHeight) -and ($objectA.objectHeight + $objectA.yPosition) -gt $objectB.yPosition) {
        $collide = $true
    }
       
    return $false #$collide
}

function CheckForCollisions() {
    $cLevel = $global:levels[$global:currentLevel]
    
    #check for object collisions (treat all collisions as deaths)
    for ($i = 0; $i -lt $cLevel.objects.Count; $i++) {
        $iObject = $cLevel.objects[$i]

        for ($j = ($i + 1); $j -lt $cLevel.objects.Count; $j++) {
            $jObject = $cLevel.objects[$j]
            
            #write-host $iObject.name $jObject.name
            
            if (($iObject.name -eq "BOMB" -and $jObject.name -eq "ENEMY") -or ($iObject.name -eq "ENEMY" -and $jObject.name -eq "BOMB")) {
                #dont cause a collision when an enemy player drops a bomb on their current location
            }
            elseif (($iObject.name -eq "BOMB" -and $jObject.name -eq "PLAYER") -or ($iObject.name -eq "PLAYER" -and $jObject.name -eq "BOMB")) {
                #dont cause a collision when a player drops a bomb on their current location
            }
            elseif (($iObject.name -eq "EXPLODE" -and $jObject.name -eq "BLOCK") -or ($iObject.name -eq "BLOCK" -and $jObject.name -eq "EXPLODE")) {
                #dont cause a collision when an explosion hits a block because they cant be destroyed
            }
            elseif (($iObject.name -eq "BLOCK" -and $jObject.name -eq "BLOCK2") -or ($iObject.name -eq "BLOCK2" -and $jObject.name -eq "BLOCK")) {
                #dont cause a collision when blocks overlap
            }
            elseif (($iObject.name -eq "EXPLODE" -and $jObject.name -eq "PORTAL") -or ($iObject.name -eq "PORTAL" -and $jObject.name -eq "EXPLODE")) {
                #dont cause a collision when blocks overlap
            }
            else {
                if ($iObject.IsDead() -or $jObject.IsDead()) {
                   
                }
                elseif ($iObject.xPosition -lt ($jObject.xPosition + $jObject.objectWidth) -and ($iObject.xPosition + $iObject.objectWidth) -gt $jObject.xPosition -and $iObject.yPosition -lt ($jObject.yPosition + $jObject.objectHeight) -and ($iObject.objectHeight + $iObject.yPosition) -gt $jObject.yPosition) {
                    #)#Collide $iObject $jObject)
                    if ($iObject.name -eq "PLAYER" -and $jObject.name -eq "BLOCK") {
                        #Player cant move into a block position so set player back to previous position
                        $cLevel.objects[0].xPosition = $cLevel.objects[0].xPositionOld;
                        $cLevel.objects[0].yPosition = $cLevel.objects[0].yPositionOld;
                    }
                    elseif ($iObject.name -eq "PLAYER" -and $jObject.name -eq "BLOCK2") {
                        #Player cant move into a block position so set player back to previous position
                        $cLevel.objects[0].xPosition = $cLevel.objects[0].xPositionOld;
                        $cLevel.objects[0].yPosition = $cLevel.objects[0].yPositionOld;
                    }
                    elseif ($iObject.name -eq "EXPLODE" -and $jObject.name -eq "BLOCK") {
                        #if an explosion hits a block do nothing
                    }
                    elseif ($iObject.name -eq "EXPLODE" -and $jObject.name -eq "BLOCK2") {
                        if ($global:levels[$global:currentLevel].objects[0].ID -eq $iObject.OriginID) {
                            $global:playerScore += 1
                        }

                        #write-host "player score" -ForegroundColor Red
                        #pause

                        $cLevel.objects[$i].DoDeath()
                        $cLevel.objects[$j].DoDeath()
                    }
                    elseif ($iObject.name -eq "BLOCK2" -and $jObject.name -eq "EXPLODE") {
                        if ($global:levels[$global:currentLevel].objects[0].ID -eq $jObject.OriginID) {
                            $global:playerScore += 1
                        }

                        $cLevel.objects[$i].DoDeath()
                        $cLevel.objects[$j].DoDeath()

                      
                    }
                    elseif ($iObject.name -eq "PLAYER" -and $jObject.name -eq "PORTAL") {
                        #Player cant move into a block position so set player back to previous position
                        $jObject.DoDeath()
                    }
                    elseif ($iObject.name -eq "PORTAL" -and $jObject.name -eq "PLAYER") {
                        #Player cant move into a block position so set player back to previous position
                        $iObject.DoDeath()
                    }
                    else {
                        $cLevel.objects[$i].DoDeath()
                        $cLevel.objects[$j].DoDeath()
                    }
                }
            }
        }
    }

    #pause
}

function CheckForCollisions2() {
    $cLevel = $global:levels[$global:currentLevel]
    
    #check for object collisions (treat all collisions as deaths)
    for ($i = 0; $i -lt $cLevel.objects.Count; $i++) {
        $iObject = $cLevel.objects[$i]

        for ($j = ($i + 1); $j -lt $cLevel.objects.Count; $j++) {
            $jObject = $cLevel.objects[$j]
            
            #write-host $iObject.name $jObject.name
            
            if (($iObject.name -eq "BOMB" -and $jObject.name -eq "ENEMY") -or ($iObject.name -eq "ENEMY" -and $jObject.name -eq "BOMB")) {
                #dont cause a collision when an enemy player drops a bomb on their current location
            }
            elseif (($iObject.name -eq "BOMB" -and $jObject.name -eq "PLAYER") -or ($iObject.name -eq "PLAYER" -and $jObject.name -eq "BOMB")) {
                #dont cause a collision when a player drops a bomb on their current location
            }
            elseif (($iObject.name -eq "EXPLODE" -and $jObject.name -eq "BLOCK") -or ($iObject.name -eq "BLOCK" -and $jObject.name -eq "EXPLODE")) {
                #dont cause a collision when an explosion hits a block because they cant be destroyed
            }
            elseif (($iObject.name -eq "BLOCK" -and $jObject.name -eq "BLOCK2") -or ($iObject.name -eq "BLOCK2" -and $jObject.name -eq "BLOCK")) {
                #dont cause a collision when blocks overlap
            }
            elseif (($iObject.name -eq "EXPLODE" -and $jObject.name -eq "PORTAL") -or ($iObject.name -eq "PORTAL" -and $jObject.name -eq "EXPLODE")) {
                #dont cause a collision when blocks overlap
            }
            else {
                if (Collide $iObject $jObject) {
                    if ($iObject.name -eq "PLAYER" -and $jObject.name -eq "BLOCK") {
                        #Player cant move into a block position so set player back to previous position
                        $cLevel.objects[0].xPosition = $cLevel.objects[0].xPositionOld;
                        $cLevel.objects[0].yPosition = $cLevel.objects[0].yPositionOld;
                    }
                    elseif ($iObject.name -eq "PLAYER" -and $jObject.name -eq "BLOCK2") {
                        #Player cant move into a block position so set player back to previous position
                        $cLevel.objects[0].xPosition = $cLevel.objects[0].xPositionOld;
                        $cLevel.objects[0].yPosition = $cLevel.objects[0].yPositionOld;
                    }
                    elseif ($iObject.name -eq "EXPLODE" -and $jObject.name -eq "BLOCK") {
                        #if an explosion hits a block do nothing
                    }
                    elseif ($iObject.name -eq "EXPLODE" -and $jObject.name -eq "BLOCK2") {
                        if ($global:levels[$global:currentLevel].objects[0].ID -eq $iObject.OriginID) {
                            $global:playerScore += 1
                        }

                        #write-host "player score" -ForegroundColor Red
                        #pause

                        $cLevel.objects[$i].dead = $true
                        $cLevel.objects[$j].dead = $true
                    }
                    elseif ($iObject.name -eq "BLOCK2" -and $jObject.name -eq "EXPLODE") {
                        if ($global:levels[$global:currentLevel].objects[0].ID -eq $jObject.OriginID) {
                            $global:playerScore += 1
                        }

                        $cLevel.objects[$i].dead = $true
                        $cLevel.objects[$j].dead = $true
                  
                    }
                    elseif ($iObject.name -eq "PLAYER" -and $jObject.name -eq "PORTAL") {
                        #Player cant move into a block position so set player back to previous position
                        $jObject.dead = $true
                    }
                    elseif ($iObject.name -eq "PORTAL" -and $jObject.name -eq "PLAYER") {
                        #Player cant move into a block position so set player back to previous position
                        $iObject.dead = $true
                    }
                    else {
                        $cLevel.objects[$i].dead = $true
                        $cLevel.objects[$j].dead = $true
                    }
                }
            }
        }
    }

    #pause
}

function RunGameLogic() {
    Read-PlayerInput
    
    #run game objects run logic
    for ($i = 1; $i -lt $global:levels[$global:currentLevel].objects.Count; $i++) {
        $global:levels[$global:currentLevel].objects[$i].RunLogic()
    }
    
    CheckForCollisions
}

function Player-Dead() {
    #Display game over screen and wait for player to confirm restart
    $global:backgroundBuffer = LoadLevel $global:gameOverScreen
    Clear-ScreenBuffer
    Move-Cursor 0 0
    DrawBackgroundtoScreenBuffer
    DrawBuffer

    Start-Sleep -s 2
    $Host.UI.RawUI.FlushInputBuffer()
    
    $global:gameLoopRunning = $false
    
    if ($global:playerScore -gt $global:highScore) {
        $global:highScore = $global:playerScore
    }
        
    $global:playerScore = 0
      
    #Wait for user to press any key
    $continue = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
}

function Detect-LevelWinOld() {
    $win = $true

    if ($global:levels[$global:currentLevel].objects[0].IsDead()) {
        $win = $false
    }

    for ($i = 0; $i -lt $global:levels[$global:currentLevel].objects.Count; $i++) {
        if ($global:levels[$global:currentLevel].objects[$i].name -eq "ENEMY") {
            # -and $global:levels[$global:currentLevel].objects[$i].isDead() -eq $true)
            $win = $false
        }
    }

    return $win
}

function Detect-LevelWin() {
    $win = $true

    if ($global:levels[$global:currentLevel].objects[0].IsDead()) {
        $win = $false
    }

    for ($i = 0; $i -lt $global:levels[$global:currentLevel].objects.Count; $i++) {
        if ($global:levels[$global:currentLevel].objects[$i].name -eq "PORTAL") {
            $win = $false
        }
    }

    return $win
}

function Load-NextLevel() {
    cls
    
    $global:currentLevel++

    if ($global:currentLevel -lt $global:gameLevelCount) {
        #Start-Sleep -s 1
        Move-Cursor 47 27
        Write-Host "Level: " ($global:currentLevel + 1)
        $global:backgroundBuffer = LoadLevel $global:levels[$global:currentLevel].background
        
        #setup path finder for level
        $global:pathFinder = New-Object PathFinder($host, $global:levels[$global:currentLevel], $global:displayWidth, ($global:displayHeight - 1), 5, 3)
        
        Start-Sleep -s 3
    }
}

function Load-GameConfig($gameConfig) {
    #Read file content into lines
    $lines = Get-Content $gameConfig
    $global:titleScreen = $lines[0].Split(':')[1]
    $global:gameOverScreen = $lines[1].Split(':')[1]
    $global:endGameScreen = $lines[2].Split(':')[1]
    $global:gameCompleteScreen = $lines[3].Split(':')[1]
    $global:levels = New-Object System.Collections.ArrayList
    $global:gameLevelCount = 0
      
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -eq "STARTLEVEL:") {
            $global:levels += New-Object Level
            $levelObjectCount = 0
            $i++
            while ($lines[$i] -ne "ENDLEVEL:") {
                if ($lines[$i].StartsWith("NAME:", "CurrentCultureIgnoreCase")) {
                    $global:levels[$global:gameLevelCount].name = $lines[$i].Split(':')[1]
                }
                elseif ($lines[$i].StartsWith("BACKGROUND:", "CurrentCultureIgnoreCase")) {
                    $global:levels[$global:gameLevelCount].background = $lines[$i].Split(':')[1]
                }
                elseif ($lines[$i].StartsWith("SPAWN:", "CurrentCultureIgnoreCase")) {
                    $index = $global:levels[$global:gameLevelCount].objects.Add((New-Object GameObject))
                    $global:levels[$global:gameLevelCount].objects[$levelObjectCount].LoadObject($lines[$i].Split(':')[1])
                    $global:levels[$global:gameLevelCount].objects[$levelObjectCount].xPosition = $lines[$i].Split(':')[3]
                    $global:levels[$global:gameLevelCount].objects[$levelObjectCount].yPosition = $lines[$i].Split(':')[4]
                    $global:levels[$global:gameLevelCount].objects[$levelObjectCount].SetupJob($global:levels[$global:gameLevelCount])

                    $levelObjectCount++
                }
                
                $i++
            }
            $global:gameLevelCount++
        }
    }
}

function DrawBackgroundtoScreenBuffer() {
    For ($i = 0; $i -lt $global:screenBuffer.Count; $i++) {
        $global:screenBuffer[$i] = $global:backgroundBuffer[$i]
    }
}

function DrawObjectstoScreenBuffer() {
    DrawBackgroundtoScreenBuffer
    
    foreach ($obj in $global:levels[$global:currentLevel].objects) {
        $obj.DrawObject($global:screenBuffer)
    }

    #update score
    Write-ScreenBuffer 3 1 "FPS: $global:fps" 
    Write-ScreenBuffer 3 2 "High Score: $global:highScore" 
    Write-ScreenBuffer 3 3 "Player Score: $global:playerScore" 
}

function Write-ScreenBuffer([int]$x, [int]$y, [string]$text) {
    $global:screenBuffer[$y] = $global:screenBuffer[$y].Remove($x, $text.Length).Insert($x, $text)
} 

function DrawBuffer() {
    $global:screenBuffer
}

function Detect-GameWin() {
    if ($global:currentLevel -eq $global:gameLevelCount) {
        $global:gameLoopRunning = $false

        #Display title screen and wait for player to confirm start
        $global:backgroundBuffer = LoadLevel $global:gameCompleteScreen
       
        Clear-ScreenBuffer
        Move-Cursor 0 0
        DrawBackgroundtoScreenBuffer
        DrawBuffer

        Start-Sleep -s 3

        $global:gameLoopRunning = $false
    
        if ($global:playerScore -gt $global:highScore) {
            $global:highScore = $global:playerScore
        }
        
        $global:playerScore = 0
    
        #Wait for user to press any key
        $Host.UI.RawUI.FlushInputBuffer()
        $continue = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
    }
}
###################################################################################################################

#Start Running Program Commands

#Clear screen
cls

#Set powershell console windowto required size
Setup-Display $global:displayWidth $global:displayHeight


while (!$global:exitGame) {
    #Clear screen and initialise global variables
    cls 
    $global:currentLevel = -1
    $global:gameLoopRunning = $True
    $global:backgroundBuffer = @()
    $global:screenBuffer = @()
    Load-GameConfig("GameConfig.txt")
    
    #Display title screen and wait for player to confirm start
    $global:backgroundBuffer = LoadLevel "TitleScreen.txt"
    Clear-ScreenBuffer
    Move-Cursor 0 0
    DrawBackgroundtoScreenBuffer
    DrawBuffer

    #Start-Sleep -s 2
    #Wait for user to press any key
    $Host.UI.RawUI.FlushInputBuffer()
    $continue = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
    
    Load-NextLevel

    $global:fpsTimer.Start()
    while ($global:gameLoopRunning) {
        Move-Cursor 0 0
        DrawObjectstoScreenBuffer
        DrawBuffer
        
        RunGameLogic
        
        #See if player got killed and restart game
        if ($global:levels[$global:currentLevel].objects[0].IsDead()) {
            Player-Dead
        }
        else {
        
            Remove-DeadObjects

            #Check to see if player has won the level
            if (Detect-LevelWin -eq $true) {
                #level up
                Load-NextLevel
                Detect-GameWin
            }

            $global:frames++
            if ($global:fpsTimer.Elapsed.Seconds -ge 1) {
                $global:fps = $global:frames
                $global:frames = 0
                $global:fpsTimer.Restart()
            }

            $global:totalFrames++
        }
    }
}

#Display close screen
$global:backgroundBuffer = LoadLevel "QuitScreen.txt"
Clear-ScreenBuffer
Move-Cursor 0 0
DrawBackgroundtoScreenBuffer
DrawBuffer

Start-Sleep -s 2

#Clear screen
cls




