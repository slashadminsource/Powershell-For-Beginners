<#
    .SYNOPSIS

    Example of using a function to display a menu and return the users menu selection.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 7
    Code listing: 7_4.ps1
    
    .EXAMPLE
    C:\PS> .\7_4.ps1
#>


function Show-Menu {
    #Display menu options
    Write-Host "------------"
    Write-Host "Menu Options"
    Write-Host "------------"
    Write-Host "Press P to play"
    Write-Host "Press Q to Quit"

    #Capture response from user
    $userResponse = Read-Host -Prompt 'Please select an option'
    
    #Return the users response variable back out of the function
    return $userResponse
}

#Start of script

#Clear console
Clear-Host

#Call function and capture the returned value into a variable
$userResponse = Show-Menu

#Use and if else statement to check what key the user pressed
if ($userResponse -eq 'P') {
    Write-Host "You pressed P to play"
}
elseif ($userResponse -eq 'Q') {
    Write-Host "You pressed Q to quit"
}
else {
    Write-Host "You pressed a key not in the menu"
} 
