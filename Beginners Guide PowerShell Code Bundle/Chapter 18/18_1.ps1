<#
    .SYNOPSIS

    Using the console beep to create sounds.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 18
    Code listing: 18_1.ps1
    
    .EXAMPLE
    C:\PS> .\18_1.ps1
#>

[console]::beep(440, 200) 
[console]::beep(340, 200) 
[console]::beep(240, 200) 
[console]::beep(149, 200)
