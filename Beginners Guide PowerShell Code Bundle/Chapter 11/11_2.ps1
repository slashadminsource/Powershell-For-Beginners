<#
    .SYNOPSIS

    Building a text based adventure game.

    Displaying the game title screen.

    .DESCRIPTION
    
    Book: PowerShell for Beginners
    Author: Ian Waters
    Chapter: 11
    Code listing: 11_2.ps1
    
    .EXAMPLE
    C:\PS> .\11_2.ps1
#>
function Title-Screen() {
    #Clear any pre existing key presses
    $host.ui.RawUI.FlushInputBuffer()
    
    Clear-Host 

    Write-Host "                                                               "
    Write-Host " @@@@`                            @@@@ @@                      "
    Write-Host " @@ @@                            @,   @@                      "
    Write-Host " @@ :@',@@@ @@@@@ @@@@  @@  @@@@  @@@` @@ @@@@.@@ @@: @@@ ,@@@ "
    Write-Host " @@ `@@ @@@   '@@ @  @ @ @@ @'@@   @@@ @@    @ @@ @@ @  @@:@@@ "  
    Write-Host " @@ #@, @   @:@@@ @  @ @ +@ @ :@  ;;@@ @@ @@:@ @@ @@,@@@@@ @   " 
    Write-Host " @@@@@ ,@# ;@ '@@ @@#@ @: @ @@:@@ @'@@ @@ @@ @` @@@@ @  :,:@   "  
    Write-Host " @@@'  ,@#  @@+@@ :,@@; @@  @@:@@ @@@@ @@ @@@@`  @@: +@@@ ,@   "  
    Write-Host "                 :; @@                           @@            "  
    Write-Host "                  @@@@,                        @@'             "  
    Write-Host "                                                               "
    Write-Host "                            @                                  "
    Write-Host "                       ,#++, @                                 "
    Write-Host "                         ,;+@@@@                             .;"
    Write-Host "                      #'.'@@@@@@#                        :@@@@@"
    Write-Host "             '         @@@@@+@+@@          :          ,@@@@@@@@"
    Write-Host " @@@;        @       ,..@@@`@@@@@@+        @        +@@@@@@@@@@"
    Write-Host " :'@@@;      @        +@@@@;@@:`@@@        @      +@@@;: :@@@@ "
    Write-Host " @@@@@@@.   @,       .::@@@.:@@@ `:        @;   ;@@@@@@@@@@`;` "
    Write-Host " @@@@@@@@@@@@          @@@@:`  @; `        ,@@@@@@@@@@@@@@@@   "
    Write-Host " @@@@@@@@@@@@         :,@@@@@  @#@          @@@@@@@@@@@@@@     "
    Write-Host " @@@@@@@;@@@@@        # @@@@@@ ::          @@@@@:@@@@@@@@      "
    Write-Host " @@@@@.@@@@@@@@@         @@@@@@         `@@@@@@@@#+@@@@@:      "
    Write-Host " @@@@ @@@@@@@@@@@@`      @@@@@@       :@@@@@@@@@@@@ @@@@       "
    Write-Host " ,#@@@@@@@@@@@@@ @@@@@@@@@@@@@@@@@@@@@@@:@@@@@@@@@@@@@.+       "
    Write-Host "         `@@@@@ @@@@@@@@@@@@@@@@@@@@@@@@@,@@@@@                "
    Write-Host "           @@@@,@@@@@@@@@@@@@@@@@@@@@@@@@ @@@+                 "
    Write-Host "            @@+@@@@@@@@@@@@@@@@@@@@@@@@@@;@@+                  "
    Write-Host "             @:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                   "
    Write-Host "             ,`@@.   @@@@@@@@@@@@@@@   .@@;                    "
    Write-Host "               .      @@@@@@@@@@@@@      ',                    "
    Write-Host "                         #@@@@@@@`                             "
    Write-Host "                          :@@@@@                               "
    Write-Host "                           ;@@@@                               "
    Write-Host "                                                               "
    Write-Host "             Press Any Key to Play or Q to quit                "
    
    $continue = Read-NextKey

    if ($continue -eq 'q') {
        $global:runGame = $false
    }
}    

Clear-Host 

Title-Screen