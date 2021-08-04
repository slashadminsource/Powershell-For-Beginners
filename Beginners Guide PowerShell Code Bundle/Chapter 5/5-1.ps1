<#
    .SYNOPSIS

    Example code from Chapter 5

    Highlight sections of code and right click then select 'run selection' while following along in the chapter

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 5
    Code listing: 5_1.ps1
    
    .EXAMPLE
    C:\PS> .\5_1.ps1
#>


# Each time around the loop the code in the brackets will run while $counter is less than than $repeat.
# Each time around the loop the ++ symbols tell the variable to increment by one each time.
[int]$repeat = 5

for ($counter = 0; $counter -lt $repeat; $counter++) {
    Write-Host "hello"
} 

#The while loop will continue until $counter is less than (-lt) the value 5 held in the $repeat variable.
[int]$repeat = 5
[int]$counter = 0

while ($counter -lt $repeat) {
    Write-Host "hello"
    $counter++
}

# Do While Loop is a variant of the while loop except the code is executed before the condition is checked to see if it repeats.
[int]$repeat = 5
[int]$counter = 0
do {
    Write-Host "hello"
    $counter++
}
while ($counter -lt $repeat) 

# ForEach Loop
# Each time around the loop the $character variable becomes the next character in the list until there are no characters left.
[string]$stringOfCharacters = "PowerShell for Beginners"

foreach ($character in $stringOfCharacters.ToCharArray()) {
    Write-Host $character
} 

# ForEach-Object loops
[string]$stringOfCharacters = "PowerShell for Beginners"
$stringOfCharacters.ToCharArray() | ForEach-Object { Write-Host "$_" }


