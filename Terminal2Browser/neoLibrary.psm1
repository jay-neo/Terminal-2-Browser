function neoDesign {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [int]$i
    )
    $color = switch ($i % 5) {
        0 { 'Blue' }
        1 { 'Magenta' }
        2 { 'Green' }
        3 { 'Cyan' }
        4 { 'Yellow' }
        5 { 'Red' }
    }
    return $color
}

function multiplexChar {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [int]$n,
        [Parameter(Mandatory=$false, Position=1)]
        [string]$str
    )
    return $str * $n
}

function relativePosition {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [int]$mainContent
    )
    $console = $Host.UI.RawUI
    $n = $console.BufferSize.Width - $mainContent
    $n = [math]::Floor($n / 2)
    $s = " " * $n
    return $s
}


function neoChoice {
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [string[]]$Options,
        [Parameter(Mandatory=$false,Position=1)]
        [string]$theme = "Theme"
    )

    $selectedIndex = 0
    $escapeUnderline = [char]27 + "[4m"
    $escapeReset = [char]27 + "[0m"

    $maxLength = 0
    foreach ($str in $Options) {
        $length = $str.Length
        if ($length -gt $maxLength) {
            $maxLength = $length
        }
    }


    if ($maxLength -lt $theme.Length) {
        $maxLength = $theme.Length + 7
    }

    $maxLength = $maxLength + 14

    $startSpace = relativePosition $maxLength 
    $middleSpace = multiplexChar 7 " "
    $borderSpace1 = multiplexChar $($maxLength - 7) "▃"
    $borderSpace2 = multiplexChar $($maxLength - 7) "═"
    

    while ($true) {
        cls
        if ($selectedIndex -eq -1) {
            $selectedIndex = $Options.Count - 1
        }
        Write-Host "`n`n"
        Write-Host "$startSpace▃▃▃▃▃▃▃▃$borderSpace1▃" -ForegroundColor $(neoDesign $selectedIndex)
        Write-Host "$startSpace█$middleSpace" -n -ForegroundColor $(neoDesign $($selectedIndex + 2))
        Write-Host "Select $theme"-n  -ForegroundColor $(neoDesign $($selectedIndex + 1))
        $t = 14 + $theme.Length
        while ($t -lt $maxLength) {
            Write-Host " " -n
            $t++
        }
        Write-Host "█╗" -ForegroundColor $(neoDesign $($selectedIndex + 2))
        Write-Host "$startSpace█═══════$borderSpace2█║" -ForegroundColor $(neoDesign $($selectedIndex + 3))


        for ($i = 0; $i -lt $Options.Count; $i++) {
            Write-Host "$startSpace█" -n -ForegroundColor $(neoDesign $($selectedIndex + $i))


            if ($i -eq $selectedIndex) {
                $formattedText = ("  >>>  {0}" -f $escapeUnderline) + $Options[$i] + $escapeReset
                Write-Host $formattedText -n -ForegroundColor Gray
            } else {
                Write-Host ("$middleSpace{0}" -f $Options[$i]) -n -ForegroundColor $(neoDesign $($selectedIndex + $i))
            }

            $t = $Options[$i].Length + 7
            while ($t -lt $maxLength) {
                Write-Host " " -n
                $t++
            }
            Write-Host "█║" -ForegroundColor $(neoDesign $($selectedIndex + $i))
        }

        Write-Host "$startSpace█▃▃▃▃▃▃▃$borderSpace1█║" -ForegroundColor $(neoDesign $($selectedIndex + $i))
        Write-Host "$startSpace ╚═══════$borderSpace2╝" -ForegroundColor $(neoDesign $($selectedIndex + $i + 1))

        $key = $host.ui.RawUI.ReadKey('NoEcho,IncludeKeyDown')

        switch ($key.VirtualKeyCode) {
            38 { $selectedIndex = ($selectedIndex - 1) % $Options.Count }
            40 { $selectedIndex = ($selectedIndex + 1) % $Options.Count }
            74 { $selectedIndex = ($selectedIndex + 1) % $Options.Count }
            75 { $selectedIndex = ($selectedIndex - 1) % $Options.Count }
        }

        if (($key.VirtualKeyCode -eq 13) -or ($key.Character -eq 'q')) {
            break
        }
    }

    return $($Options[$selectedIndex])
}
