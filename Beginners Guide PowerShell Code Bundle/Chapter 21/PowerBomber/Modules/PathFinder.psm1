using module '.\Level.psm1'
using module '.\GameObject.psm1'

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

Class Node
{
    [int]$x
    [int]$y
    [int]$cost

    Node($pX, $pY, $pCost)
    {
        $this.x = $pX
        $this.y = $pY
        $this.cost = $pCost
    }
}

Class ObjNode
{
    [GameObject]$object
    [int]$cost

    Node($pObject, $pCost)
    {
        $this.object = $pObject
        $this.cost = $pCost
    }
}

Class PathFinder
{
    [int]$width = $null
    [int]$height = $null
    [Level]$level = $null
    [int]$xStepSize = 1
    [int]$yStepSize = 1
    [System.Management.Automation.Host.Rectangle]$rectangle
    [System.Management.Automation.Host.PSHost]$host

    $pathMap = $null

    PathFinder([System.Management.Automation.Host.PSHost]$host, [Level]$level, [int]$width, [int]$height, [int]$xStepSize, [int]$yStepSize)
    {
        $this.host = $host
        $this.level = $level
        $this.width = $width
        $this.height = $height
        $this.xStepSize = $xStepSize
        $this.yStepSize = $yStepSize


        $this.rectangle = New-Object System.Management.Automation.Host.Rectangle 0, 0, $this.width, $this.height

        $this.pathMap = New-Object 'object[,]' $this.width,$this.height
    }
        
    [void] MoveCursor([int]$x, [int] $y) 
    {
        $this.host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates $x , $y
    } 
    
    [bool] ProcessedSlow($todo, $done, $location)
    {
        $allNodes = $todo + $done
  
        foreach($node in $allNodes)
        {
            if($node.x -eq $location.x -and $node.y -eq $location.y)
            {
                return $true
            }
        }

        return $false
    }

    [bool] Processed($todo, $done, $location)
    {
        if($this.pathMap[$location.x,$location.y] -ne $null)
        {
            return $true
        }
              
                
        return $false
    }

    [bool] Processed($todo, $done, $x, $y)
    {
        if($this.pathMap[$x,$y] -ne $null)
        {
            return $true
        }

        #$this.pathMap[$x,$y] = 1
                
        return $false
    }

    [bool] Processedorig($todo, $done, $location)
    {
    
        foreach($node in $todo)
        {
            if($node.x -eq $location.x -and $node.y -eq $location.y)
            {
                return $true
            }
        }

        foreach($node in $done)
        {
            if($node.x -eq $location.x -and $node.y -eq $location.y)
            {
                return $true
            }
        }

        return $false
    }
    
    [bool] Collide([int]$x, [int]$y)
    {
        #write-host "cccccccccc"
        #pause

        [GameObject] $stepPosition = New-Object GameObject
        $stepPosition.xPosition = $x
        $stepPosition.yPosition = $y
        
        return $this.level.CheckForCollisions($stepPosition)
    }

    [bool] Collide([int]$x, [int]$y, [int]$width, [int]$height)
    {
        #write-host "bbbbbbbb"
        #pause

        [GameObject] $stepPosition = New-Object GameObject
        $stepPosition.xPosition = $x
        $stepPosition.yPosition = $y
        $stepPosition.objectWidth = $width
        $stepPosition.objectHeight = $height

        #write-host "$stepPosition.xPosition" $stepPosition.xPosition
        #write-host "$stepPosition.yPosition" $stepPosition.yPosition
        #write-host "$stepPosition.objectWidth" $stepPosition.objectWidth
        #write-host "$stepPosition.objectHeight" $stepPosition.objectHeight
        #pause
        
        return $this.level.CheckForCollisions($stepPosition)
    }

    [bool] Collide([Guid]$ID, [int]$x, [int]$y, [int]$width, [int]$height)
    {
        #write-host "aaaaaaaaaaaaa id: " + $ID
        #pause

        [GameObject] $stepPosition = New-Object GameObject
        $stepPosition.ID = $ID
        $stepPosition.xPosition = $x
        $stepPosition.yPosition = $y
        $stepPosition.objectWidth = $width
        $stepPosition.objectHeight = $height

        #write-host "$stepPosition.xPosition" $stepPosition.xPosition
        #write-host "$stepPosition.yPosition" $stepPosition.yPosition
        #write-host "$stepPosition.objectWidth" $stepPosition.objectWidth
        #write-host "$stepPosition.objectHeight" $stepPosition.objectHeight
        #pause
        
        return $this.level.CheckForCollisions($stepPosition)
    }

    [bool] Collide([GameObject] $object)
    {
        return $this.level.CheckForCollisions($object)
    }

    [Node] FindNearestStepj([Node]$step, [System.Collections.ArrayList]$steps)
    {
        $top    = $steps | where {$_.x -eq $step.x -and $_.y -lt $step.y -and $_.cost -eq ($step.cost-1)} | Sort-Object y -Descending
        $bottom = $steps | where {$_.x -eq $step.x -and $_.y -gt $step.y -and $_.cost -eq ($step.cost-1)} | Sort-Object y
        $left   = $steps | where {$_.x -lt $step.x -and $_.y -eq $step.y -and $_.cost -eq ($step.cost-1)} | Sort-Object x -Descending
        $right  = $steps | where {$_.x -gt $step.x -and $_.y -eq $step.y -and $_.cost -eq ($step.cost-1)} | Sort-Object x
                
        $nextSteps = New-Object System.Collections.ArrayList

        if($top.Count -gt 0 -and $top[0].y -ge ($step.y-1))
        {
            [void]$nextSteps.add($top[0])
        }

        if($bottom.Count -gt 0 -and $bottom[0].y -le ($step.y+1))
        {
            [void]$nextSteps.add($bottom[0])
        }
    
        if($left.Count -gt 0 -and $left[0].x -ge ($step.x-1))
        {
            [void]$nextSteps.add($left[0])
        }
    
        if($right.Count -gt 0 -and $right[0].x -le ($step.x+1))
        {
            [void]$nextSteps.add($right[0])
        }
    
        $nextStep = $nextSteps | where {$_.cost -lt $step.cost}
        $next = $nextStep[0]

        return $next
    }

    [Node] FindNearestStep([Node]$step, [System.Collections.ArrayList]$steps)
    {
        #$top    = $this.pathMap[$step.x,($step.y-1)] 
        #$bottom = $this.pathMap[$step.x,($step.y+1)] 
        #$left   = $this.pathMap[($step.x-1),$step.y] 
        #$right  = $this.pathMap[($step.x+1),$step.y] 


        $top    = $this.pathMap[$step.x,($step.y-$this.yStepSize)] 
        $bottom = $this.pathMap[$step.x,($step.y+$this.yStepSize)] 
        $left   = $this.pathMap[($step.x-$this.xStepSize),$step.y] 
        $right  = $this.pathMap[($step.x+$this.xStepSize),$step.y] 
                
        $nextSteps = New-Object System.Collections.ArrayList

        if($top -ne $null)
        {
            [void]$nextSteps.add($top)
        }

        if($bottom -ne $null)
        {
            [void]$nextSteps.add($bottom)
        }
    
        if($left -ne $null)
        {
            [void]$nextSteps.add($left)
        }
    
        if($right -ne $null)
        {
            [void]$nextSteps.add($right)
        }
    
        $nextStep = $nextSteps | where {$_.cost -lt $step.cost}
        $next = $nextStep[0]

        #pause

        return $next



        #return $steps[0]

        #write-host "breaking at null"
        #write-host "last step:" $steps[0].x $steps[0].y $steps[0].cost
        
        #return $steps[0]
        #pause
        
        #return $null
    }

    [System.Collections.ArrayList] FindShortestPath([Node]$target, [System.Collections.ArrayList]$steps)
    {      
        try
        {
            #Write-host "0" -ForegroundColor Red

            #$this.MoveCursor($target.x, $target.y)
            #Write-host "X" -ForegroundColor Red



            [System.Collections.ArrayList]$npath = New-Object System.Collections.ArrayList
            [void]$steps.Reverse()

            #Write-host "1" -ForegroundColor Red

            $oldStep = $steps[0]
            [void]$npath.Add((new-object Node $steps[0].x,$steps[0].y,$steps[0].cost))

            #Write-host "2" -ForegroundColor Red

            while($oldStep.x -ne $target.x -or $oldStep.y -ne $target.y)
            {
                #$this.MoveCursor($oldStep.x, $oldStep.y)
                #Write-host "X" -ForegroundColor Green

                #pause

                $newStep = $this.FindNearestStep($oldStep, $steps)
            

                $oldStep.x = $newStep.x
                $oldStep.y = $newStep.y
                $oldStep.cost = $newStep.cost

                [void]$npath.Add((new-object Node $newStep.x,$newStep.y,$newStep.cost))
            }

            #Write-host "3" -ForegroundColor Red
        
            #$this.MoveCursor($oldStep.x, $oldStep.y)
            #Write-host "X" -ForegroundColor Red

            [void]$npath.Reverse()

            #write-host "find shortest path"
            #pause

            return $npath
        }
        catch
        {
            write-host "exception message" $_.Exception.Message
            write-host "exception item" $_.Exception.ItemName
            Pause
        }

        return $null
    }

    [bool] Match([Node]$a, [Node]$b)
    {
        if($a.x -eq $b.x -and $a.y -eq $b.y)
        {
            return $true
        }   

        return $false
    }

    [System.Collections.ArrayList] FindPath([int]$sX, [int]$sY, [int]$tX, [int]$tY)
    {
        [System.Collections.ArrayList]$todo = New-Object System.Collections.ArrayList
        [System.Collections.ArrayList]$done = New-Object System.Collections.ArrayList
        
        [Node]$start = New-Object Node $sX, $sY, 0
        [Node]$end   = New-Object Node $tX, $tY, 0

        [void]$todo.Add($start)
        $this.pathMap[$start.x,$start.y] = $start
        
        do
        {
            #grab location from top of list
            $current = [Node]$todo[0]

            #$this.MoveCursor($current.x, $current.y)
            #Write-host $current.cost

            #is location goal location?
            if($this.Match($current, $end))
            {
                #Add target location to the done list
                [void]$done.Add($current)
                $this.pathMap[$current.x,$current.y] = $current
                
                #the first entry on the done list contains the end node
                #we now need to find the shortest path to the start node from the end node
                [System.Collections.ArrayList]$shortestPath = $this.FindShortestPath($start, $done)
            
                return $shortestPath
            }

            #add four neighbouring locations to bottom todo list
            #TOP
            if($current.x -ge 0 -and ($current.y-$this.yStepSize) -ge 0 -and $current.x -lt $this.width -and ($current.y-$this.yStepSize) -lt $this.height -and ($this.Collide($current.x, ($current.y-$this.yStepSize))) -eq $false)
            {    
                $newLocation = New-Object Node $current.x, ($current.y-$this.yStepSize), ($current.cost+1)

                if(($this.Processed($todo, $done, $newLocation)) -eq $false)
                {
                    [void]$todo.Add($newLocation)
                }
                
            }

            #BOTTOM
            if($current.x -ge 0 -and ($current.y+$this.yStepSize) -ge 0 -and $current.x -lt $this.width -and ($current.y+$this.yStepSize) -lt $this.height -and ($this.Collide($current.x, ($current.y+$this.yStepSize))) -eq $false)
            {      
                $newLocation = New-Object Node $current.x, ($current.y+$this.yStepSize), ($current.cost+1)
            
                if(($this.Processed($todo, $done, $newLocation)) -eq $false)
                {
                   [void]$todo.Add($newLocation)
                }
            }

            #LEFT
            if(($current.x-$this.xStepSize) -ge 0 -and $current.y -ge 0 -and ($current.x-$this.xStepSize) -lt $this.width -and $current.y -lt $this.height -and ($this.Collide(($current.x-$this.xStepSize), $current.y)) -eq $false)
            {     
                $newLocation = New-Object Node ($current.x-$this.xStepSize), $current.y, ($current.cost+1)
             
                if(($this.Processed($todo, $done, $newLocation)) -eq $false)
                {
                   [void]$todo.Add($newLocation)
                }
            }


            #RIGHT
            if(($current.x+$this.xStepSize) -ge 0 -and $current.y -ge 0 -and ($current.x+$this.xStepSize) -lt $this.width -and $current.y -lt $this.height -and ($this.Collide(($current.x+$this.xStepSize), $current.y)) -eq $false)
            {      
                $newLocation = New-Object Node ($current.x+$this.xStepSize), $current.y, ($current.cost+1)
             
                if(($this.Processed($todo, $done, $newLocation)) -eq $false)
                {
                   [void]$todo.Add($newLocation)
                }
            }
       
            #add current to done list
            [void]$done.Add($current)
            [void]$todo.RemoveAt(0)
        }
        while($todo.count -gt 0)

        return $null
    }
    
    [System.Collections.ArrayList] FindPath([GameObject]$object, [int]$tX, [int]$tY)
    {
        
        #debug timings
        #$stopwatch = New-Object System.Diagnostics.Stopwatch
        #$stopwatch.Start()

        #write-host "xxxxxxxxxxxxxxxxxx"
        #write-host "target:" $tX $tY
        #pause

        #write-host "A id:" $object.ID
        
        [System.Collections.ArrayList]$todo = New-Object System.Collections.ArrayList
        [System.Collections.ArrayList]$done = New-Object System.Collections.ArrayList
        
        [int]$sX = $object.xPosition
        [int]$sY = $object.yPosition

        [Node]$start = New-Object Node $sX, $sY, 0
        [Node]$end   = New-Object Node $tX, $tY, 0

        $this.pathMap = New-Object 'object[,]' $this.width,$this.height
        
        #$this.MoveCursor($tX, $tY)
        #Write-host "X" -ForegroundColor Red
        
        [void]$todo.Add($start)
        $this.pathMap[$start.x,$start.y] = $start

        #Write-host "STARTING"
        #pause
    
        do
        {
            #grab location from top of list
            $current = [Node]$todo[0]

            #$this.MoveCursor($current.x, $current.y)
            #Write-host $current.cost
            #Write-host "X" -ForegroundColor Blue

            #is location goal location?
            if($this.Match($current, $end))
            {
                #Add target location to the done list
                [void]$done.Add($current)
                $this.pathMap[$current.x,$current.y] = $current
                         
                

                #the first entry on the done list contains the end node
                #we now need to find the shortest path to the start node from the end node
                [System.Collections.ArrayList]$shortestPath = $this.FindShortestPath($start, $done)
            
                #$stopwatch.Stop()
                #"Total PathFind Time" + $stopwatch.Elapsed.Milliseconds >> 'Timings.txt'
                #Pause

                return $shortestPath
            }


            #$stopwatchN = New-Object System.Diagnostics.Stopwatch
            #$stopwatchN.Start()

            #add four neighbouring locations to bottom todo list
            
            #TOP
            if($current.x -ge 0 -and ($current.y-$this.yStepSize) -ge 0 -and $current.x -lt $this.width -and ($current.y-$this.yStepSize) -lt $this.height -and ($this.Collide($object.ID, $current.x, ($current.y-$this.yStepSize),$object.objectWidth, $object.objectHeight)) -eq $false)
            {      
                if(($this.Processed($todo, $done, $current.x, ($current.y-$this.yStepSize))) -eq $false)
                {
                    $newLocation = New-Object Node $current.x, ($current.y-$this.yStepSize), ($current.cost+1)
                    [void]$todo.Add($newLocation)
                    $this.pathMap[$newLocation.x,$newLocation.y] = $newLocation
                }
                
            }
            
            #BOTTOM
            if($current.x -ge 0 -and ($current.y+$this.yStepSize) -ge 0 -and $current.x -lt $this.width -and ($current.y+$this.yStepSize) -lt $this.height -and ($this.Collide($object.ID, $current.x, ($current.y+$this.yStepSize), $object.objectWidth, $object.objectHeight)) -eq $false)
            {      
                
                if(($this.Processed($todo, $done, $current.x, ($current.y+$this.yStepSize))) -eq $false)
                {
                    $newLocation = New-Object Node $current.x, ($current.y+$this.yStepSize), ($current.cost+1)
                    [void]$todo.Add($newLocation)
                    $this.pathMap[$newLocation.x,$newLocation.y] = $newLocation
                }
            }

            #LEFT
            if(($current.x-$this.xStepSize) -ge 0 -and $current.y -ge 0 -and ($current.x-$this.xStepSize) -lt $this.width -and $current.y -lt $this.height -and ($this.Collide($object.ID, ($current.x-$this.xStepSize), $current.y, $object.objectWidth, $object.objectHeight)) -eq $false)
            {     
                
             
                if(($this.Processed($todo, $done, ($current.x-$this.xStepSize), $current.y)) -eq $false)
                {
                   $newLocation = New-Object Node ($current.x-$this.xStepSize), $current.y, ($current.cost+1)
                   [void]$todo.Add($newLocation)
                   $this.pathMap[$newLocation.x,$newLocation.y] = $newLocation
                }
            }

            #RIGHT
            if(($current.x+$this.xStepSize) -ge 0 -and $current.y -ge 0 -and ($current.x+$this.xStepSize) -lt $this.width -and $current.y -lt $this.height -and ($this.Collide($object.ID, ($current.x+$this.xStepSize), $current.y, $object.objectWidth, $object.objectHeight)) -eq $false)
            {      
                
             
                if(($this.Processed($todo, $done, ($current.x+$this.xStepSize), $current.y)) -eq $false)
                {
                   $newLocation = New-Object Node ($current.x+$this.xStepSize), $current.y, ($current.cost+1)
                   [void]$todo.Add($newLocation)
                   $this.pathMap[$newLocation.x,$newLocation.y] = $newLocation
                }
            }
       
            #add current to done list
            [void]$done.Add($current)
            [void]$todo.RemoveAt(0)

            #$stopwatchN.Stop()
            #"Neighbours:" + $stopwatchN.Elapsed.Milliseconds >> 'Timings.txt'
        }
        while($todo.count -gt 0)

        #write-host "RETURNING NULL" -ForegroundColor Red

        return $null
    }

    [System.Collections.ArrayList] FindPathOrig([GameObject]$object, [int]$tX, [int]$tY)
    {
        #debug timings
        #$stopwatch = New-Object System.Diagnostics.Stopwatch
        #$stopwatch.Start()

        #write-host "xxxxxxxxxxxxxxxxxx"
        #write-host "A id:" $object.ID
        $this.pathMap = New-Object 'object[,]' $this.width,$this.height
        
        [System.Collections.ArrayList]$todo = New-Object System.Collections.ArrayList
        [System.Collections.ArrayList]$done = New-Object System.Collections.ArrayList
        
        [int]$sX = $object.xPosition
        [int]$sY = $object.yPosition

        [Node]$start = New-Object Node $sX, $sY, 0
        [Node]$end   = New-Object Node $tX, $tY, 0


        #$this.MoveCursor($tX, $tY)
        #Write-host "X" -ForegroundColor Red


        [void]$todo.Add($start)

        #Write-host "STARTING"
    
        do
        {
            #grab location from top of list
            $current = [Node]$todo[0]

            #$this.MoveCursor($current.x, $current.y)
            #Write-host $current.cost
            #Write-host "X"

            #is location goal location?
            if($this.Match($current, $end))
            {
                #write-host "sx:" $current.x
                #write-host "sy:" $current.y
                #write-host "tx:" $end.x
                #write-host "ty:" $end.y
                
               # write-host "location"
                #pause

                #Add target location to the done list
                [void]$done.Add($current)

                #the first entry on the done list contains the end node
                #we now need to find the shortest path to the start node from the end node
                [System.Collections.ArrayList]$shortestPath = $this.FindShortestPath($start, $done)
            
                #$stopwatch.Stop()
                #"Total PathFind Time" + $stopwatch.Elapsed.Milliseconds >> 'Timings.txt'
                #Pause

                return $shortestPath
            }


            #$stopwatchN = New-Object System.Diagnostics.Stopwatch
            #$stopwatchN.Start()

            #add four neighbouring locations to bottom todo list
            #TOP
            
            #this code executes around 3 seconds
            if($current.x -ge 0 -and ($current.y-$this.yStepSize) -ge 0 -and $current.x -lt $this.width -and ($current.y-$this.yStepSize) -lt $this.height -and ($this.Collide($object.ID, $current.x, ($current.y-$this.yStepSize),$object.objectWidth, $object.objectHeight)) -eq $false)
            {      
                #write-host $this.Collide($current.x, ($current.y-$this.stepSize),$object.objectWidth, $object.objectHeight)
                #pause                
                $newLocation = New-Object Node $current.x, ($current.y-$this.yStepSize), ($current.cost+1)

                if(($this.Processed($todo, $done, $newLocation)) -eq $false)
                {
                    [void]$todo.Add($newLocation)
                }
                
            }
            
            #BOTTOM
            if($current.x -ge 0 -and ($current.y+$this.yStepSize) -ge 0 -and $current.x -lt $this.width -and ($current.y+$this.yStepSize) -lt $this.height -and ($this.Collide($object.ID, $current.x, ($current.y+$this.yStepSize), $object.objectWidth, $object.objectHeight)) -eq $false)
            {      
                $newLocation = New-Object Node $current.x, ($current.y+$this.yStepSize), ($current.cost+1)
            
                if(($this.Processed($todo, $done, $newLocation)) -eq $false)
                {
                   [void]$todo.Add($newLocation)
                }
            }

            #LEFT
            if(($current.x-$this.xStepSize) -ge 0 -and $current.y -ge 0 -and ($current.x-$this.xStepSize) -lt $this.width -and $current.y -lt $this.height -and ($this.Collide($object.ID, ($current.x-$this.xStepSize), $current.y, $object.objectWidth, $object.objectHeight)) -eq $false)
            {     
                $newLocation = New-Object Node ($current.x-$this.xStepSize), $current.y, ($current.cost+1)
             
                if(($this.Processed($todo, $done, $newLocation)) -eq $false)
                {
                   [void]$todo.Add($newLocation)
                }
            }

            #RIGHT
            if(($current.x+$this.xStepSize) -ge 0 -and $current.y -ge 0 -and ($current.x+$this.xStepSize) -lt $this.width -and $current.y -lt $this.height -and ($this.Collide($object.ID, ($current.x+$this.xStepSize), $current.y, $object.objectWidth, $object.objectHeight)) -eq $false)
            {      
                $newLocation = New-Object Node ($current.x+$this.xStepSize), $current.y, ($current.cost+1)
             
                if(($this.Processed($todo, $done, $newLocation)) -eq $false)
                {
                   [void]$todo.Add($newLocation)
                }
            }
       
            #add current to done list
            [void]$done.Add($current)
            [void]$todo.RemoveAt(0)

            #$stopwatchN.Stop()
            #"Neighbours:" + $stopwatchN.Elapsed.Milliseconds >> 'Timings.txt'
        }
        while($todo.count -gt 0)

        return $null
    }

    [System.Collections.ArrayList] FindPath([int]$sX, [int]$sY, [int]$oWidth, [int]$oHeight, [int]$tX, [int]$tY)
    {
        #write-host "bbb width:" $object.objectWidth "Height:"  $object.objectHeight
        #pause

        [System.Collections.ArrayList]$todo = New-Object System.Collections.ArrayList
        [System.Collections.ArrayList]$done = New-Object System.Collections.ArrayList
        
        [Node]$start = New-Object Node $sX, $sY, 0
        [Node]$end   = New-Object Node $tX, $tY, 0

        [void]$todo.Add($start)

        #Write-host "STARTING"
    
        do
        {
            #grab location from top of list
            $current = [Node]$todo[0]

            #$this.MoveCursor($current.x, $current.y)
            #Write-host $current.cost
            #Write-host "X"

            #is location goal location?
            if($this.Match($current, $end))
            {
                #Add target location to the done list
                [void]$done.Add($current)

                #the first entry on the done list contains the end node
                #we now need to find the shortest path to the start node from the end node
                [System.Collections.ArrayList]$shortestPath = $this.FindShortestPath($start, $done)
            
                return $shortestPath
            }

            #add four neighbouring locations to bottom todo list
            #TOP
            if($current.x -ge 0 -and ($current.y-$this.yStepSize) -ge 0 -and $current.x -lt $this.width -and ($current.y-$this.yStepSize) -lt $this.height -and ($this.Collide($current.x, ($current.y-$this.yStepSize),$oWidth, $oHeight)) -eq $false)
            {      
                #write-host $this.Collide($current.x, ($current.y-$this.stepSize),$object.objectWidth, $object.objectHeight)
                #pause                
                $newLocation = New-Object Node $current.x, ($current.y-$this.yStepSize), ($current.cost+1)

                if(($this.Processed($todo, $done, $newLocation)) -eq $false)
                {
                    [void]$todo.Add($newLocation)
                }
                
            }
            
            #BOTTOM
            if($current.x -ge 0 -and ($current.y+$this.yStepSize) -ge 0 -and $current.x -lt $this.width -and ($current.y+$this.yStepSize) -lt $this.height -and ($this.Collide($current.x, ($current.y+$this.yStepSize), $oWidth, $oHeight)) -eq $false)
            {      
                $newLocation = New-Object Node $current.x, ($current.y+$this.yStepSize), ($current.cost+1)
            
                if(($this.Processed($todo, $done, $newLocation)) -eq $false)
                {
                   [void]$todo.Add($newLocation)
                }
            }

            #LEFT
            if(($current.x-$this.xStepSize) -ge 0 -and $current.y -ge 0 -and ($current.x-$this.xStepSize) -lt $this.width -and $current.y -lt $this.height -and ($this.Collide(($current.x-$this.xStepSize), $current.y, $oWidth, $oHeight)) -eq $false)
            {     
                $newLocation = New-Object Node ($current.x-$this.xStepSize), $current.y, ($current.cost+1)
             
                if(($this.Processed($todo, $done, $newLocation)) -eq $false)
                {
                   [void]$todo.Add($newLocation)
                }
            }

            #RIGHT
            if(($current.x+$this.xStepSize) -ge 0 -and $current.y -ge 0 -and ($current.x+$this.xStepSize) -lt $this.width -and $current.y -lt $this.height -and ($this.Collide(($current.x+$this.xStepSize), $current.y, $oWidth, $oHeight)) -eq $false)
            {      
                $newLocation = New-Object Node ($current.x+$this.xStepSize), $current.y, ($current.cost+1)
             
                if(($this.Processed($todo, $done, $newLocation)) -eq $false)
                {
                   [void]$todo.Add($newLocation)
                }
            }
       
            #add current to done list
            [void]$done.Add($current)
            [void]$todo.RemoveAt(0)
        }
        while($todo.count -gt 0)

        return $null
    }
}
