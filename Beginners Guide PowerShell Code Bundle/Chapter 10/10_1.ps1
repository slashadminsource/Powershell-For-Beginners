<#
    .SYNOPSIS

    Example of reading key presses from the keyboard.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 10
    Code listing: 10_1.ps1
    
    .EXAMPLE
    C:\PS> .\10_1.ps1
#>

#Variables
$done = $false

function Read-Character() {
    if ($host.ui.RawUI.KeyAvailable) {
        return $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown").Character
    }
   
    return $null
}

#Clear console
Clear-Host

#Clear any pre existing key presses
$host.ui.RawUI.FlushInputBuffer()

Write-Host "Press any key or q to quit"

#Keep looping round checking for new key presses
#Loop round while done is not (!) equal to true
while (!$done) {
    #Check for new key presses
    $char = Read-Character

    if ($char -ne $null) {
        Write-Host "You pressed $char"

        #If the key press equals q then exit the loop
        if ($char -eq 'q') {
            $done = $true
        }
    } 
} 
