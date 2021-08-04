<#
    .SYNOPSIS

    Example code from Chapter 4

    Highlight sections of code and right click then select 'run selection' while following along in the chapter

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 4
    Code listing: 4_1.ps1
    
    .EXAMPLE
    C:\PS> .\4_1.ps1
#>


# If the values in the if statement are equal then the result of the statement results in a true condition. 
# If a statement results in a true condition then the code within the {} brackets is run.
if (4 -eq 4) {
    Write-Host "4 is equal to 4"
}

if ("hello" -eq "hello") {
    Write-Host "Both strings are equal to each other"
} 

# If you change the value of one of the variables they won't equal each other so the else clause will run.
[int]$x = 10
[int]$y = 10

if ($x -eq $y) {
    Write-Host "the x and y variables are equal to each other"
}
else {
    Write-Host "The x and y variables are NOT equal to each other"
}

# Is “Ian” equal to “Ian”? yes they are so the result is true and code within the if statement runs.
$yourName = "Ian"

if ($yourName -eq "Ian") {
    Write-Host "Hay my name is Ian too!"
}
else {
    Write-Host "Hi $yourName, nice to meet you!"
}

# An example of reading input from the console and using an if, elseif, else statements.
# Using just this code you can expand it to write your own text based adventure game in PowerShell!
#Variables
[string]$playerInput = ""

#Get input from player
$playerInput = Read-Host -Prompt "You walk into a room with two doorways. One to the left and one to the right. Type 'left' or 'Right' to walk through one of the doors."

if ($playerInput -eq "left") {
    Write-Host "Player typed left"
}
elseif ($playerInput -eq "right") {
    Write-Host "Player typed right"
}
else {
    Write-Host "Player typed something we didn't understand"
}


# Comparison Operators

# -eq	Equals.	
if (5 -eq 5) {
    #5 is equal to 5
}
   
# -ne Not equals.
if (3 -ne 4) {
    #3 is not equal to 4
}
   
# -gt Greater than.
if (4 -gt 2) {
    #4 is greater than 2
}
   
# -ge Greater than or equal.
if (2 -ge 1) {
    #2 is greater than or equal to 1
}
   
# -lt Less than.
if (1 -lt 2) {
    #1 is less than 1
}

# -le Less than or equal.
if (1 -le 2) {
    #1 is less than or equal to 2
} 

# -like	Results in a true condition when a string matches based on a wildcard character *.
#  The string "hello*" says if this string matches the other by starting with the word hello followed by any other words.
#  If we used "*hello*" it would mean result in true if hellow appears in the other string because we are using a wildcard at the start and end.	
if ("hello how are you?" -like "hello*") {
    #use a wildcard character * to match strings
}

# -notlike	Results in a true condition when two strings don't match.	
if ("HELLO" -notlike "BYE") {
    #HELLO is not like BYE
} 

# -match	Results in true when a string matches a regex pattern. In its simplest form it can be used to check if a word or character exists in a string. Its well worth reading more on regex patterns as we wont be using many of these in the exapmples in this book.	
if ("HELLO" -match "H") {
    #H exists in the 
    string "HELLO"
}
   
# -notmatch	Results in true when a string doesn't match a regex pattern.	
if ("HELLO" -notmatch "A") {
    #A does not match in the 
    string "HELLO"
}

# -contains	Results in true when a value is found within another collection.
$list = @(1, 2, 3, 4, 5)
if ($list -contains 3) {
    #the list does contain a 3
}

# -notcontains	Results in true when a value is not found within a collection.	
$list = @(1, 2, 3, 4, 5)
if ($list -notcontains 8) {
    #$list does not contain 8
}

# -in	Results in true when a value is found in a collection.	
$list = @(1, 2, 3, 4, 5)
if (3 -in $list) {
    #the list does contain a 3
} 

# -notin	Results in true when a value is not found in a collection.	
$list = @(1, 2, 3, 4, 5)
if (6 -notin $list) {
    #6 is not in the list
}

# -is	Results in true when a variable or value matches the specified type.	
$var = "This is a string"
if ($var -is [string]) {
    #The variable is a string
}

# -isnot	Results in true when a variable or value is not equal to the specified type.	
$var = "This is a string"
if ($var -isnot [bool]) {
    #The variable is a string and not a Boolean value so results in true.
} 
   

# Switch Statements

# In this example we set up a number variables and pass it into the switch. 
# On each line we place the value to compare against. 
# In this case the numbers 1 and 2 and after each value we use {} brackets to define the code to run when that value matches.
[int]$number = 2
switch ($number) {
    1 { "The number is one" }
    2 { "The number is two" }
    default { "I dont know what the number is" }
}

# This is to show within each clause you can run multiple lines of code not just one. 
# The final clause is default which will run if none of the values match.
[string]$favouriteColour = "Blue"
switch ($favouriteColour) {
    "Red" {
        "Your favourite colour is Red"
        "I like red too."
    }
 
    "Blue" {
        "Your favourite colour is Blue"
        "I like Blue too."
    }
 
    default { "I dont recognise that colour" }
}





