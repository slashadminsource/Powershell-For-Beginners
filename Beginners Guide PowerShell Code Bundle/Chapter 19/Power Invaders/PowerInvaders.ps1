
<#
    .SYNOPSIS

    PowerInvaders a text based game based on Space Invaders.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 19
    Code listing: PowerInvaders.ps1
    
    .EXAMPLE
    C:\PS> .\PowerInvaders.ps1
#>

#Variables###########################
$global:gameLoopRunning = $True
$global:exitGame = $false
$global:displayWidth = 110
$global:displayHeight = 56
$global:playerScore = 0
$global:highScore = 0
$global:currentLevel = -1
$global:gameLevelCount = 0

$global:titleScreen = ""
$global:gameOverScreen = ""
$global:endGameScreen = ""
$global:gameCompeteScreen = ""

[Array]$global:screenBuffer = @()
[Array]$global:backgroundBuffer = @()
[System.Collections.ArrayList]$global:levels = New-Object System.Collections.ArrayList
#####################################

#Clases####################

Class Level {
    [String]$name
    [String]$background
    [System.Collections.ArrayList]$objects

    Level() {
        $this.name = ""
        $this.background = ""
        $this.objects = New-Object System.Collections.ArrayList
    }
}

Class GameObject {
    [int]$xPosition = 0
    [int]$yPosition = 0
    [int]$objectHeight = 0
    [int]$objectWidth = 0
    [int]$objectFrames = 0
    [String]$name = ""
    [String]$direction = "right"
    [String]$moveScript = ""
    [Array]$character = @()
    [bool]$kill = $false
    [bool]$dead = $false
    [int]$speed = 0 #Lower the number the faster the object
    [int]$sTimer = 0

    [bool]IsDead() {
        return $this.dead
    }
        
    LoadObject([string]$file) {
        #read file and get number of lines
        $lines = Get-Content $file
        $this.name = $lines[0].Split(':')[1]
        $this.speed = $lines[1].Split(':')[1]
        $this.objectHeight = $lines[2].Split(':')[1]
        $this.objectWidth = $lines[3].Split(':')[1]
        $this.objectFrames = $lines[4].Split(':')[1]

        for ($i = 5; $i -le $this.objectHeight + 4; $i++) {
            $this.character += $lines[$i]
        }

        #load move script
        for ($i = 0; $i -lt $lines.Length; $i++) {
            if ($lines[$i] -eq "MOVESCRIPTSTART:") {
                for ($j = $i + 1; $j -lt $lines.Length; $j++) {
                    if ($lines[$j] -ne "MOVESCRIPTEND:") {
                        $this.moveScript += $lines[$j] + "`n`r"
                    }
                }
            }
        }
    }

    MoveLeft() {
        $this.xPosition--
    }

    RunLogic() {
        if (!$this.dead) {
            if ($this.moveScript -ne $null -and $this.moveScript -ne "") {
                Invoke-Expression $this.moveScript
            }
        }
    }
    
    [Array]DrawObject([Array]$buffer) {
        if (!$this.dead) {
            For ($i = 0; $i -lt $this.character.Length; $i++) {
                $buffer[$this.yPosition + $i] = $buffer[$this.yPosition + $i].Remove($this.xPosition, $this.objectWidth).Insert($this.xPosition, $this.character[$i])
            }
        }
           
        return $buffer
    }
}
#####################

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
    $global:screenBuffer.Clear()

    for ($i = 0; $i -lt 110; $i++) { 
        $global:screenBuffer += @("") 
    }
}

function Move-Cursor([int]$x, [int] $y) {
    $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $x , $y
} 

function Spawn-Rocket([int]$x, [int] $y) {
    $rocket = New-Object GameObject
    $rocket.LoadObject("Rocket.txt")
    $rocket.xPosition = $x
    $rocket.yPosition = $y
    $global:levels[$global:currentLevel].objects += $rocket
} 

function Read-PlayerInput() {
    #See what keys the player is pressing
    $char = Read-Character
  
    if ($char -eq 'q') {
        $global:exitGame = $True
        $global:gameLoopRunning = $False
    }
    elseif ($char -eq 'a') {
        $global:levels[$global:currentLevel].objects[0].xPosition--
    }
    elseif ($char -eq 'd') {
        $global:levels[$global:currentLevel].objects[0].xPosition++
    }
    elseif ($char -eq ' ') {
        Spawn-Rocket ($global:levels[$global:currentLevel].objects[0].xPosition + 3) ($global:levels[$global:currentLevel].objects[0].yPosition - 2)
    }
    elseif ($char -eq 't') {
        #Show-ObjectsStatus
        $global:levels[$global:currentLevel].objects[0].dead = $true
    }
   
    #Keep player inside the display
    if ($global:levels[$global:currentLevel].objects[0].xPosition -le 0) {
        $global:levels[$global:currentLevel].objects[0].xPosition = 1
    }
    elseif ($global:levels[$global:currentLevel].objects[0].xPosition -ge $global:displayWidth - $global:levels[$global:currentLevel].objects[0].objectWidth) {
        $global:levels[$global:currentLevel].objects[0].xPosition = $global:displayWidth - $global:levels[$global:currentLevel].objects[0].objectWidth - 1
    }

    if ($global:levels[$global:currentLevel].objects[0].yPosition -le 0) {
        $global:levels[$global:currentLevel].objects[0].yPosition = 0
    }
    elseif ($global:levels[$global:currentLevel].objects[0].yPosition -ge $global:displayHeight - $global:levels[$global:currentLevel].objects[0].objectHeight) {
        $global:levels[$global:currentLevel].objects[0].yPosition = $global:displayHeight - $global:levels[$global:currentLevel].objects[0].objectHeight
    }
}

function Collide($objectA, $objectB) {
    if ($objectA.IsDead() -or $objectB.IsDead()) {
        return $false
    }

    [bool]$collide = $false
    
    if ($objectA.xPosition -lt ($objectB.xPosition + $objectB.objectWidth) -and ($objectA.xPosition + $objectA.objectWidth) -gt $objectB.xPosition -and $objectA.yPosition -lt ($objectB.yPosition + $objectB.objectHeight) -and ($objectA.objectHeight + $objectA.yPosition) -gt $objectB.yPosition) {
        $collide = $true
    }
       
    return $collide
}

function Show-ObjectsStatus() {
    Clear-Host 
    for ($i = 0; $i -lt $global:levels[$global:currentLevel].objects.Count; $i++) {
        Write-Host "Object" $i ":" $global:levels[$global:currentLevel].objects[$i].IsDead()
    }

    Pause
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

function RunGameLogic() {
    Read-PlayerInput
        
    #run game objects run logic
    for ($i = 0; $i -lt $global:levels[$global:currentLevel].objects.Count; $i++) {
        $global:levels[$global:currentLevel].objects[$i].RunLogic()        
    }

    #check for object collisions (treat all collisions as deaths)
    for ($i = 0; $i -lt $global:levels[$global:currentLevel].objects.Count; $i++) {
        for ($j = ($i + 1); $j -lt $global:levels[$global:currentLevel].objects.Count; $j++) {
            if (Collide $global:levels[$global:currentLevel].objects[$i] $global:levels[$global:currentLevel].objects[$j]) {
                if (($global:levels[$global:currentLevel].objects[$i].name -eq "BOMB" -and $global:levels[$global:currentLevel].objects[$j].name -eq "ENEMY") -or ($global:levels[$global:currentLevel].objects[$i].name -eq "ENEMY" -and $global:levels[$global:currentLevel].objects[$j].name -eq "BOMB")) {
                }
                else {
                    $global:levels[$global:currentLevel].objects[$i].dead = $true
                    $global:levels[$global:currentLevel].objects[$j].dead = $true
                }

                #Check if player receives points
                if (($global:levels[$global:currentLevel].objects[$i].name -eq "PLAYERROCKET" -and $global:levels[$global:currentLevel].objects[$j].name -eq "ENEMY") -or ($global:levels[$global:currentLevel].objects[$i].name -eq "ENEMY" -and $global:levels[$global:currentLevel].objects[$j].name -eq "PLAYERROCKET")) {
                    #A player rocket just hit an enemy so assign some points to the player
                    $global:playerScore += 100
                }
            }
        }
    }
}

function Player-Dead() {
    #Display title screen and wait for player to confirm start
    $global:backgroundBuffer = LoadLevel $global:gameOverScreen
    Clear-ScreenBuffer
    Move-Cursor 0 0
    DrawBackgroundtoScreenBuffer
    DrawBuffer

    Start-Sleep -s 2

    $global:gameLoopRunning = $false
    
    if ($global:playerScore -gt $global:highScore) {
        $global:highScore = $global:playerScore
    }
        
    $global:playerScore = 0
    
    #Wait for user to press any key
    $continue = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
}

function Detect-LevelWin() {
    $win = $true

    for ($i = 0; $i -lt $global:levels[$global:currentLevel].objects.Count; $i++) {
        if ($global:levels[$global:currentLevel].objects[$i].name -eq "ENEMY") {
            $win = $false
        }
    }

    return $win
}

function Load-NextLevel() {
    Clear-Host
    
    $global:currentLevel++

    if ($global:currentLevel -lt $global:gameLevelCount) {
        Start-Sleep -s 2
        Move-Cursor 47 27
        Write-Host "Level: " ($global:currentLevel + 1)
        $global:backgroundBuffer = LoadLevel $global:levels[$global:currentLevel].background
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
    
    #draw game objects
    For ($i = 0; $i -lt $global:levels[$global:currentLevel].objects.Count; $i++) {
        #$global:screenBuffer = $global:levels[$global:currentLevel].objects[$i].DrawObject($global:screenBuffer)
         
        $tmp = $global:levels[$global:currentLevel].objects[$i].DrawObject($global:screenBuffer)
    }

    #update score
    Write-ScreenBuffer 3 2 "High Score: $global:highScore" 
    Write-ScreenBuffer 3 3 "Player Score: $global:playerScore" 
}

function Write-ScreenBuffer([int]$x, [int]$y, [string]$text) {
    $global:screenBuffer[$y] = $global:screenBuffer[$y].Remove($x, $text.Length).Insert($x, $text)
} 

function DrawBuffer() {
    for ($i = 0; $i -lt $global:screenBuffer.Count; $i++) {
        $global:screenBuffer[$i]
    }
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

        Start-Sleep -s 5

        $global:gameLoopRunning = $false
    
        if ($global:playerScore -gt $global:highScore) {
            $global:highScore = $global:playerScore
        }
        
        $global:playerScore = 0
    
        #Wait for user to press any key
        $continue = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
    }
}
###################################################################################################################

#Start Running Program Commands

#Clear screen
Clear-Host

#Set powershell console windowto required size
Setup-Display $global:displayWidth $global:displayHeight

while (!$global:exitGame) {
    #Clear screen and initialise global variables
    Clear-Host 
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

    #Wait for user to press any key
    $continue = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
    
    Load-NextLevel

    while ($global:gameLoopRunning) {
        Move-Cursor 0 0
        DrawObjectstoScreenBuffer
        DrawBuffer
        
        RunGameLogic

        #See if player got killed and restart game
        if ($global:levels[$global:currentLevel].objects[0].IsDead()) {
            Player-Dead
        }

        Remove-DeadObjects

        #Check to see if player has won the level
        if (Detect-LevelWin) {
            #level up
            Load-NextLevel

            Detect-GameWin
        }
    }
}

#Display close screen
$global:backgroundBuffer = LoadLevel "QuitScreen.txt"
Clear-ScreenBuffer
Move-Cursor 0 0
DrawBackgroundtoScreenBuffer
DrawBuffer

Start-Sleep -s 7

#Clear screen
Clear-Host




