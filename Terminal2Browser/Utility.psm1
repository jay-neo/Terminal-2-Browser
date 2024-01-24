function SpacePrint {
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [int]$n,
        [Parameter(Mandatory=$false, Position=1)]
        [string]$str
    )
    return $str * $n
}
function userChoice {
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

    $t = 0
    if ($maxLength -gt $theme.Length) {
        $t = $maxLength - $theme.Length
    } else {
        $maxLength = $theme.Length
    }
    $s1 = "═"
    $s2 = " "
    $spaces = SpacePrint 7 " "
    $spaces1 = SpacePrint $($maxLength + 14) "═"

    while ($true) {
        cls
        $spaces2 = SpacePrint $t $s2
        Write-Host "$spaces╔═══════$spaces1╗" -ForegroundColor Yellow
        Write-Host "$spaces║$spaces" -n -ForegroundColor Yellow
        Write-Host "Select $theme$spaces2$spaces"-n  -ForegroundColor Red
        Write-Host "║" -ForegroundColor Yellow
        Write-Host "$spaces╠═══════$spaces1╣" -ForegroundColor Yellow
        for ($i = 0; $i -lt $Options.Count; $i++) {
            $spaces2 = SpacePrint $($maxLength - $Options[$i].Length) $s2
            if ($i -eq $selectedIndex) {
                Write-Host "$spaces║" -n -ForegroundColor Yellow
                $formattedText = ("  >>>  {0}" -f $escapeUnderline) + $Options[$i] + $escapeReset
                Write-Host $formattedText -n -ForegroundColor Cyan
                Write-Host "$spaces2$spaces$spaces║" -ForegroundColor Yellow
            } else {
                $color = switch ($i % 5) {
                    0 { 'Blue' }
                    1 { 'Green' }
                    2 { 'Yellow' }
                    3 { 'Red' }
                    4 { 'Magenta' }
                }
                Write-Host "$spaces║$spaces"  -n -ForegroundColor Yellow
                Write-Host ("{0}" -f $Options[$i]) -n -ForegroundColor $color
                Write-Host "$spaces2$spaces$spaces║" -ForegroundColor Yellow
            }
        }
        Write-Host "$spaces╚═══════$spaces1╝" -ForegroundColor Yellow

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