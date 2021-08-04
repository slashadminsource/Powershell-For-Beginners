<#
    .SYNOPSIS

    An example of using Add-Content cmdlet to append new text to the end of a file.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 17
    Code listing: 17_3.ps1
    
    .EXAMPLE
    C:\PS> .\17_3.ps1
#>

#Clear the console
Clear-Host

#File content
$fileContent = @("Line 1", "Line 2", "Line 3")

#Save full file path to variable
$filePath = "c:\scripts\testfile.txt"

Add-Content -Path $filePath -Value $fileContent

Write-Host "File has been created and the new file content has been added to it."
