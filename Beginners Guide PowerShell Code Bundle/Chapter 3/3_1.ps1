
<#
    .SYNOPSIS

    Example code from Chapter 3

    Highlight sections of code and right click then select 'run selection' while following along in the chapter

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 3
    Code listing: 3_1.ps1
    
    .EXAMPLE
    C:\PS> .\3_1.ps1
#>


# Common Variable Types
[string]$name       = "Peter"                                   # strings are a 'string of' characters making a word or sentance.
[char]$letter       = 'A'                                       # char type are single characters.
[bool]$isEnabled    = $false                                    # bool type can be $true or $false.
[int]$age           = 37                                        # int type is a whole number.
[decimal]$height    = 12345.23                                  # decimal type allows large numbers with decimals.
[double]$var        = 54321.21                                  # similar to decimal but is a 8 byte decimal floating point number.
[single]$var        = 76549.11                                  # similar to decimal but is a 32 bit floating point number.
[long]$var          = 2382.22                                   # similar to decimal bus is a 64 bit integer.
[DateTime]$birthday = "Feburary 12, 1982"                       # Date and time value.
[array]$var         = "itemone", "itemtwo"                      # Indexed list of objects, in this case an array of string values but they can be any other object type.
[hashtable]$var     = @{Name = "Ian"; Age = 37; Height = 5.9 }  # Name and Value pairs. You can mix variable types.

# If you dont specify the variable type PowerShell will determine the best fit.
$myVariable = "hello this is a string variable" 

# It's best practice to always specify the variable type 
[string]$myVariable = "hello this is a string variable" 

# Assigning the number 5 to the int variable $numberVariable
[int]$numberVariable = 5 

# Assigning $true value to the $booleanVariable 
[bool]$booleanVariable = $true 

# If you create a variable of a specific type then try assigning an incompatiable value it will result in an error.
[int]$age = 3 
$age = "old" 

# You can overwrite existing values by assigning a new one at any time.
$age = 38
$age = 83
$age = 23

# You can display the value of a variable to the console buy simply typeing the variable name.
[int]$age = 37
$age

# If you want to write text to the console in a flexiable way use the Write-Host cmdlet.
Write-Host "It’s my birthday and i’m " $age 

#Global variables can be used to allow access to them across your script
#Player position
[int]$global:xPosition = 4
[int]$global:yPosition = 3
$global:xPosition 

