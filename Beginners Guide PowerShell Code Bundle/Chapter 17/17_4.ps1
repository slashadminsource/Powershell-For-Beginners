<#
    .SYNOPSIS

    Uses Set-Content to write an array of strings to a file and overwrites existing content if the file exists.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 17
    Code listing: 17_4.ps1
    
    .EXAMPLE
    C:\PS> .\17_4.ps1
#>


#Clear the console
Clear-Host

#File content
$fileContent = @("Line 1", "Line 2", "Line 3")

#Save full file path to variable
$filePath = "c:\scripts\testfile.txt"

Set-Content -Path $filePath -Value $fileContent

Write-Host "File has been created or overwritten and the new file content has been added to it."
