using module '.\GameObject.psm1'
#using module '.\PathFinder.psm1'

Class Level
{
    [String]$name
    [String]$background
    [System.Collections.ArrayList]$objects
    [int]$width
    [int]$height
   
    Level()
    {
        $this.name = ""
        $this.background = ""
        $this.objects = New-Object System.Collections.ArrayList
 
    }
        
    [bool] Collide($objectA, $objectB)
    {
        if($objectA.IsDead() -or $objectB.IsDead())
        {
            return $false
        }

        [bool]$collide = $false
        
        #check that we are not colliding with yourself.
        if($objectA.ID -eq $objectB.ID)
        {
            return $false
        }
        
        #Dont collide against bombs
        if($objectB.Name -eq "BOMB")
        {
            return $false
        }
        
        if ($objectA.xPosition -lt ($objectB.xPosition + $objectB.objectWidth) -and ($objectA.xPosition + $objectA.objectWidth) -gt $objectB.xPosition -and $objectA.yPosition -lt ($objectB.yPosition + $objectB.objectHeight) -and ($objectA.objectHeight + $objectA.yPosition) -gt $objectB.yPosition) 
        {
            $collide = $true
        }
       
        return $collide
    }

    [bool] CheckForCollisions($object)
    {
        #check for object collisions (treat all collisions as deaths)
        for($i = 1;$i -lt $this.objects.Count;$i++)
        {
            $iObject = $this.objects[$i]
            
            if($this.Collide($object, $iObject))
            {
               return $true
            }    
        }

        return $false
    }
}