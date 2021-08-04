
using module '.\Sound.psm1'

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")


Class Target
{
    [int]$distance
    [GameObject]$object
        
    Target()
    {
        $this.distance = 999
    }
}

Class GameObject
{
    [Guid]$ID          #Used to uniquely identify each object in the game
    [Guid]$OriginID    #Used to identify the spawning object. Used with charaters which fire weapons so kills can be credited back to the spawning object.
    [int]$xPosition = 0
    [int]$yPosition = 0
    [int]$xPositionOld = 0
    [int]$yPositionOld = 0
    [int]$objectHeight = 0
    [int]$objectWidth  = 0
    [int]$objectFrames = 0
    [String]$name = ""
    [String]$direction = "right"
    [String]$moveScript = ""
    [System.Collections.ArrayList]$character = $null
    [bool]$kill = $false
    [bool]$hidden = $false
    [bool]$dead = $false
    [int]$speed = 0  #Lower the number the faster the object
    [System.Diagnostics.Stopwatch]$timer = $null  #used to calculate bomb explosion speed
    [int]$sTimer = 0 #used to calculate movement speed
    [int]$wTimer = 0 #used to wait after performing certain actions


    [int]$bombDelay = 50 #used to calculate time between bomb drops
    [int]$currentAnimationFrame = 0

    [String]$objective = "NONE"
    [String]$subObjective = "NONE"
    [System.Collections.ArrayList]$path = $null # used for path finding during moves (mainly used in scripts)

    [bool]$inAction = $false
    
    [System.Collections.ArrayList]$sounds = $null
 
   
    #testing
    $pShell = $null
    $job = $null
    $level = $null
  
    
    GameObject()
    {
        #Every object gets a unique ID to prevent things like colliding with yourself.
        $this.ID = New-Guid
        $this.OriginID = New-Guid
        $this.timer= New-Object -TypeName System.Diagnostics.Stopwatch 
        $this.timer.Start()
        $this.character = New-Object System.Collections.ArrayList

        $this.sounds = New-Object System.Collections.ArrayList
    }

    [void]SetupJob($level)
    {
        $this.level = $level

        # live object to be passed in a job and changed there  

        # job script
        $script = {
            param($p1)
    
            $p1.RunSubLogic()
        } 

        $this.pShell = [PowerShell]::Create()
        $null = $this.pShell.AddScript($script).AddArgument($this)
    }

    [void]PlaySound($name)
    {
        foreach($sound in $this.sounds)
        {
            if($sound.name -eq $name)
            {
                $sound.PlaySound()
            }
        }
    }

    RunLogic()
    {
        #write-host "movescript:["$this.moveScript"]"
        
        if($this.moveScript -eq "")
        {
            return
        }

        if($this.inAction -eq $false)
        {
            $this.inAction = $true
            $this.job = $this.pShell.BeginInvoke()
        }
        else
        {
            $this.pShell.EndInvoke($this.job)  
        }
    }

    RunLogic2()
    {
        if(!$this.dead)
        {
            if($this.moveScript -ne $null)# -and $this.moveScript -ne "")
            {
                Invoke-Expression $this.moveScript
            }
        }
    }

    RunSubLogic()
    {
        $this.inAction = $true
        
        if(!$this.dead)
        {
            if($this.moveScript -ne $null)# -and $this.moveScript -ne "")
            {
                Invoke-Expression $this.moveScript
            }
        }

        $this.inAction = $false
        #$this.pShell.EndInvoke($this.job)  
    }

    [bool]IsDead()
    {
        return $this.dead
    }

    [double]DistanceBetweenPoints([int]$p1x, [int]$p1y, [int]$p2x, [int]$p2y)
    {
        $distance = 0

        $distance = [math]::sqrt( [math]::pow(($p2x - $p1x), 2) + [math]::pow(($p2y - $p1y), 2))
    
        return $distance
    }

    [double]AngleBetweenPoints([int]$p1x, [int]$p1y, [int]$p2x, [int]$p2y)
    {
        [double]$angleDeg = 0
    
        $angleDeg = [math]::atan2($p2y - $p1y, $p2x - $p1x) * 180 / [math]::pi;
        
        $angleDeg = $angleDeg - 90
        
        if($angleDeg -lt 0)
        {
	        $angleDeg = $angleDeg + 360
        }

        return $angleDeg
    }
        
    LoadObject([string]$file)
    {
        #read file and get number of lines
        $lines = Get-Content $file
        $this.name         = $lines[0].Split(':')[1]
        $this.speed        = $lines[1].Split(':')[1]
        $this.objectHeight = $lines[2].Split(':')[1]
        $this.objectWidth  = $lines[3].Split(':')[1]
        $this.objectFrames = $lines[4].Split(':')[1]
        
        for($i = 5;$i -le $this.objectHeight+4;$i++)
        {
            $this.character += $lines[$i]
        }
               
        #load move / sound scripts
        for($i = 0;$i -lt $lines.Length;$i++)
        {
            if($lines[$i] -eq "MOVESCRIPTSTART:")
            {
                for($j = $i+1;$j -lt $lines.Length -and $lines[$j] -ne "MOVESCRIPTEND:" ;$j++)
                {
                    $this.moveScript += $lines[$j] + "`n`r"
                }
            }
            elseif($lines[$i] -eq "SOUNDSCRIPTSTART:")
            {
                $sound = New-Object Sound 
                $soundScript = @()
               
                #write-host "sound script found"

                for($j = $i+1;$j -lt $lines.Length -and $lines[$j] -ne "SOUNDSCRIPTEND:" ;$j++)
                {
                    if($lines[$j].StartsWith("NAME:") -eq $true)
                    {
                        $sound.name = $lines[$j].Split(':')[1]
                    }
                    else
                    {
                        $soundScript += $lines[$j] + "`r`n"
                    }
                }

                #write-host "sound script loaded"
                #write-host "name: " $sound.name
                #write-host "script: " $soundScript
                #pause

                $sound.LoadSound($soundScript)
                $this.sounds += $sound
            }
        }
    }

    LoadObject2([string]$file)
    {
        #read file and get number of lines
        $lines = Get-Content $file
        $this.name         = $lines[0].Split(':')[1]
        $this.speed        = $lines[1].Split(':')[1]
        $this.objectHeight = $lines[2].Split(':')[1]
        $this.objectWidth  = $lines[3].Split(':')[1]
        $this.objectFrames = $lines[4].Split(':')[1]
        
        for($i = 5;$i -le $this.objectHeight+4;$i++)
        {
            $this.character += $lines[$i]
        }

        #load move/sound scripts
        for($i = 0;$i -lt $lines.Length;$i++)
        {
            if($lines[$i] -eq "MOVESCRIPTSTART:")
            {
                for($j = $i+1;$j -lt $lines.Length;$j++)
                {
                    if($lines[$j] -ne "MOVESCRIPTEND:")
                    {
                        $this.moveScript += $lines[$j] + "`n`r"
                    }
                }
            }
            
        }
    }

    MoveLeft()
    {
        $this.xPosition--
    }
    
    [Array]DrawObject2([Array]$buffer)
    {
        if(!$this.dead -and !$this.hidden)
        {
            For($i = 0;$i -lt $this.character.Length;$i++)
            {
                $buffer[$this.yPosition+$i] = $buffer[$this.yPosition+$i].Remove($this.xPosition,$this.objectWidth).Insert($this.xPosition, $this.character[$i])
            }
        }
           
        return $buffer
    }

    DrawObject([System.Collections.ArrayList]$buffer)
    {
        if(!$this.dead -and !$this.hidden)
        {
            For($i = 0;$i -lt $this.character.Count;$i++)
            {
                $buffer[$this.yPosition+$i] = $buffer[$this.yPosition+$i].Remove($this.xPosition,$this.objectWidth).Insert($this.xPosition, $this.character[$i])
            }
        }
    }
    
    DropBomb()
    {
        #prevent a bomb being constantly dropped
        $this.bombDelay--

        if($this.bombDelay -le 0)
        {
	        $bomb = New-Object GameObject
	        $bomb.LoadObject("Bomb.txt")
	        $bomb.xPosition = $this.xPosition
	        $bomb.yPosition = $this.yPosition
	        $global:levels[$global:currentLevel].objects.Add($bomb)
            $this.bombDelay = 50
        }
    }

    [int]DistanceTo([string]$type)
    {
        $cLevel = $global:levels[$global:currentLevel]
	    $distanceTo = 999

	    for($i = 0;$i -lt $cLevel.objects.Count;$i++)
	    {
	        $obj = $cLevel.objects[$i]

		    if($obj.Name.StartsWith($type))
		    {
                if(-not $obj.IsDead())
                {
			        $dist = $this.DistanceBetweenPoints(($this.xPosition + ($this.objectWidth/2)), ($this.yPosition + ($this.objectHeight/2)), ($obj.xPosition + ($obj.objectWidth/2)), ($obj.yPosition + ($obj.objectHeight/2)))
			        if($dist -lt $distanceTo)
			        {
				        $distanceTo = $dist
			        }		
                }
		    }
	    }	

	    return $distanceTo
    }

    [Target]DistanceToTarget([string]$type)
    {
        $cLevel = $global:levels[$global:currentLevel]
	    $target = New-Object Target
        $target.distance = 999
        $target.object = New-Object GameObject
        $found = $false

	    for($i = 0;$i -lt $cLevel.objects.Count;$i++)
	    {
	        $obj = $cLevel.objects[$i]
            
            #write-host $obj.Name

		    if($obj.Name.StartsWith($type))
		    {
                if(-not $obj.IsDead())
                {
                    $found = $true
			        [double]$dist = $this.DistanceBetweenPoints(($this.xPosition + ($this.objectWidth/2)), ($this.yPosition + ($this.objectHeight/2)), ($obj.xPosition + ($obj.objectWidth/2)), ($obj.yPosition + ($obj.objectHeight/2)))
		   

                    if($dist -lt $target.distance)
			        {
				        $target.object = $obj
                        $target.distance = $dist
			        }		
                }
		    }
	    }	

        return $target
    }

    [void] MoveCursor([int]$x, [int] $y) 
    {
        $host = Get-Host
        $host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $x , $y
    } 

    [Target]PositionNextToTarget([GameObject]$object)
    {
        $cLevel = $global:levels[$global:currentLevel]
	    $found = $false

        $targetPosition = new-object Target
        $targetPosition.distance = 0
        $targetPosition.object = New-Object GameObject

        #get position next to target based on angle
        [double]$angle = $this.AngleBetweenPoints($this.xPosition, $this.yPosition, $object.xPosition, $object.yPosition)
                
        if($angle -gt 314 -or $angle -lt 45)
        {
            #top
            $targetPosition.object.xPosition = $object.xPosition
            $targetPosition.object.yPosition = $object.yPosition - $this.objectHeight
        }
        elseif($angle -gt 44 -and $angle -lt 135)
        {
            #right
            $targetPosition.object.xPosition = $object.xPosition + $object.objectWidth
            $targetPosition.object.yPosition = $object.yPosition
        }
        elseif($angle -gt 134 -and $angle -lt 225)
        {
            #bottom
            $targetPosition.object.xPosition = $object.xPosition
            $targetPosition.object.yPosition = $object.yPosition + $object.objectHeight
        }
        elseif($angle -gt 224 -and $angle -lt 315)
        {
            #left
            $targetPosition.object.xPosition = $object.xPosition - $this.objectWidth
            $targetPosition.object.yPosition = $object.yPosition
        }
        
        return $targetPosition
    }

    [System.Collections.ArrayList]FindPath([GameObject]$obj, [int]$x,[int]$y,[int]$depth,[int]$maxDepth)
    {
        $depth++

        if($depth -gt $maxDepth)
        {
            return $null
        }

        [int]$steps = 1 #distance to move and check for collisions
        
        #check 8 possible moves
        # x x x
        # x x x
        # x x x
        [System.Collections.ArrayList]$p = New-Object System.Collections.ArrayList
                
        for($i = ($this.yPosition-$steps);$i -le ($steps * 3);$i+=$steps)
        {
            for($j = ($this.xPosition-$steps);$j -le ($steps * 3);$j+=$steps)
            {
                [System.Collections.ArrayList]$steps = FindPath($obj, $i, $j, $depth, $maxDepth)

                if($steps -ne $null -or $steps.Count -gt 0)
                {
                    #add new steps to the path
                    $p.Add($steps)
                }
            }
        }
                
        return $p
        
    }

    [bool]BoundryCheck([int]$x, [int]$y, [int]$height, [int]$width)
    {
        #check in bounds of game area
        if($x -le 1 -or $x -gt ($global:displayWidth-$width) -or $y -lt 4 -or $y -ge ($global:displayHeight-$height-1))
        {
           #Write-host "OUT OF BOUNDS" -ForegroundColor Red
           #pause

           return $false
        }

        return $true
    }

    [void]DoDeath()
    {
        $this.dead = $true
        $this.PlaySound("DEATH")
    }

    [bool]DoesCollide([int]$x, [int]$y, [int]$height, [int]$width)
    {
        $cLevel = $global:levels[$global:currentLevel]

        #check for object collisions
        $obj1 = New-Object GameObject
        $obj1.xPosition = $x
        $obj1.yPosition = $y
        $obj1.objectHeight = $height
        $obj1.objectWidth  = $width
        $hitCount = 0

        #for($i = 0;$i -lt $cLevel.objects.Count;$i++)
        #{
        #    $obj2 = $cLevel.objects[$i]
        #       
        #    if($this.Collide($obj1, $obj2))
        #    {
        #        $hitCount++
        #    }
        #    else
        #    {
        #    }
        #}

        foreach($obj2 in $cLevel.objects)
        {
            if($this.Collide($obj1, $obj2))
            {
                $hitCount++
            }
            else
            {
            }
        }

    
        if($hitCount -ge 1)
        {
            return $true
        }

        return $false
    }

    [bool]Collide($objectA, $objectB)
    {
        if($objectA.IsDead() -or $objectB.IsDead())
        {
            return $false
        }

        [bool]$collide = $false

        #speed increase#########
        if(($objectA.xPosition + $objectA.objectWidth) -lt $objectB.xPosition)
        {
            return $collide
        }

        if($objectA.xPosition -gt ($objectB.xPosition + $objectB.objectWidth))
        {
            return $collide
        }

        if(($objectA.yPosition + $objectA.objectHeight) -lt $objectB.yPosition)
        {
            return $collide
        }

        if($objectA.yPosition -gt ($objectB.yPosition+$objectB.object.Height))
        {
            return $collide
        }
        ########################

    
        if ($objectA.xPosition -lt ($objectB.xPosition + $objectB.objectWidth) -and ($objectA.xPosition + $objectA.objectWidth) -gt $objectB.xPosition -and $objectA.yPosition -lt ($objectB.yPosition + $objectB.objectHeight) -and ($objectA.objectHeight + $objectA.yPosition) -gt $objectB.yPosition) 
        {
            $collide = $true
        }
       
        return $collide
    }

    MoveTo([int]$x, [int]$y, [bool]$ignoreCollide)
    {
	    #240 309 - left
	    #310 57 - up
	    #58 - 115 - right
	    #116 - 239 - down 

	    $angle = $this.AngleBetweenPoints($this.xPosition, $this.yPosition, $x, $y)

	    if($angle -gt 239 -and $angle -lt 310)
	    {
		    #move left
		    $collide = $this.DoesCollide(($this.xPosition-1), $this.yPosition, $this.objectHeight, $this.objectWidth)

		    if($collide -eq $false -or $ignoreCollide -eq $true)
		    {
                $this.xPosition--
		    }
		    else
		    {
			    
		    }
	    }
	    elseif($angle -gt 309 -or $angle -lt 57)
	    {
		    #move up
		    $collide = $this.DoesCollide($this.xPosition, ($this.yPosition-1), $this.objectHeight, $this.objectWidth)
		    
            if($collide -eq $false -or $ignoreCollide -eq $true)
		    {
                $this.yPosition--
		    }
		    else
		    {
			   
		    }
	    }
	    elseif($angle -gt 56 -and $angle -lt 116)
	    {
		    #move right
		    $collide = $this.DoesCollide(($this.xPosition + 1), $this.yPosition, $this.objectHeight, $this.objectWidth)
		    
            if($collide -eq $false -or $ignoreCollide -eq $true)
		    {
                $this.xPosition++
		    }
		    else
		    {
			    
		    }
	    }
	    elseif($angle -gt 115 -and $angle -lt 240)
	    {
		    #move down
		    $collide = $this.DoesCollide($this.xPosition, ($this.yPosition + 1), $this.objectHeight, $this.objectWidth)
		    
            if($collide -eq $true -xor $ignoreCollide -eq $true)
		    {
                $this.yPosition++
		    }
		    else
		    {
			    
		    }
	    }
    }
}