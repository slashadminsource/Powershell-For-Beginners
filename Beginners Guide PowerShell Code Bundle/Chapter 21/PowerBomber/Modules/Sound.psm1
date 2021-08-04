Class Sound
{
    #variables
    $script = $null
    $ps     = $null
    $job    = $null
    $name   = ""

    Sound()
    {
        $this.ps = [PowerShell]::Create()
    }

    [void]LoadSound($sc)
    {
        $this.script = $sc
        $null = $this.ps.AddScript($this.script)
    }

    [void]PlaySound()
    {
        if($this.job -ne $null)
        {
            if($this.job.IsCompleted)
            {
                $this.ps.EndInvoke($this.job)
                $this.job = $null
            }
        }
        else
        {
            $this.job = $this.ps.BeginInvoke()
        }
    }
}