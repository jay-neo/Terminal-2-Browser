
function Terminal2BrowserErrorType1 {
    Write-Host "    To fix, use '" -NoNewline -ForegroundColor Yellow
    Write-Host "-config" -NoNewline -ForegroundColor Cyan
    Write-Host "' flag. If that doesn't work, then use '" -NoNewline -ForegroundColor Yellow
    Write-Host "-reset" -NoNewline -ForegroundColor Red
    Write-Host "' flag.`n" -ForegroundColor Yellow
}

function t2 {
    param(
        [string]$neo,
        [string[]]$args
    )

    $b = $false
    $s = $false
    $p = $false
    $browserName = ""
    $searchEngineName = ""
    $profileName = ""

    $searchString = $neo

    for ($itr = 0; $itr -lt $args.Count; $itr++) {
        switch ($args[$itr]) {
            "-b" {
                $b = $true
                $itr2 = $itr + 1
                if (($itr2 -lt $args.Count) -and (($args[$itr2] -ne "-s") -and ($args[$itr2] -ne "-p"))) {
                    $browserName = $args[$itr2]
                    $itr++
                }
            }
            "-s" {
                $s = $true
                $itr2 = $itr + 1
                if (($itr2 -lt $args.Count) -and (($args[$itr2] -ne "-b") -and ($args[$itr2] -ne "-p"))) {
                    $searchEngineName = $args[$itr2]
                    $itr++
                }
            }
            "-p" {
                $p = $true
                $itr2 = $itr + 1
                if (($itr2 -lt $args.Count) -and (($args[$itr2] -ne "-s") -and ($args[$itr2] -ne "-b"))) {
                    $profileName = $args[$itr2]
                    $itr++
                }
            }
            "-config" {
                Import-Module (Join-Path $PSScriptRoot "SetupConfig.ps1") -Force
                Terminal2BrowserConfigurationOfBrowserList
            }
        }
    }


    ########################################## Debug
    # Write-Host "Args: $($args -join ', ')"
    # Write-Host "Search String  = '$searchString'"
    # if($b) { Write-Host "b = true = '$browserName'"}
    # if($s) { Write-Host "s = true = '$searchEngineName'" }
    # if($p) { Write-Host "p = true = '$profileName'" }
    # return


    ################################ Browser Selection #########################################

    $jsonFilePath = Join-Path -Path $PSScriptRoot -ChildPath './User/BrowserList.json'
    $jsonContent = Get-Content -Path $jsonFilePath -Raw
    $jsonObject = $jsonContent | ConvertFrom-Json
    $foundBrowser = $null

    $browserList = @()
    foreach ($browser in $jsonObject.UserBrowserList) {
        if ($($browser.Path) -ne "") {
            $browserList += $browser.Name
        }
    }

    if (-not($b)) {
        if ($jsonObject.DefaultBrowser.Path -eq "") {
            Write-Host "`n 💀 Default browser not found!!`n" -ForegroundColor Red
            Terminal2BrowserErrorType1
            return
        }
        $foundBrowser = $jsonObject.DefaultBrowser[0]
    } elseif ($b -and ($browserName -eq "")) {
        Import-Module (Join-Path $PSScriptRoot "Utility.psm1") -Force
        $browserChoice = userChoice $browserList "Browser Preference"

        $foundBrowser = $jsonObject.UserBrowserList | Where-Object { $_.Name -eq $browserChoice }
        if ($foundBrowser -eq $null) {
            Write-Host "`n 💀 Error: Browser is not recognized!!`n" -ForegroundColor Red
            Terminal2BrowserErrorType1
            return
        }
    } elseif ($browserName -ne "") {
        $foundBrowser = $jsonObject.UserBrowserList | Where-Object { $_.WindowsName -eq $browserName }
        if ($foundBrowser -eq $null) {
            Write-Host "`n 💀 Invalid browser name cannot be recognized!!`n" -ForegroundColor Red
            return
        }
    }

    $browserPath = $foundBrowser.Path

    #################### Browser Arguments

    $argus = ""
    if ($i) {
        $argus += $foundBrowser.IncognitoArgument
    }
    if ($p) {
        $argus += $foundBrowser.ProfileArgument
        if ($profileName -eq "") {
            $userInput = Read-Host -Prompt "`n`tEnter your profile name"
            $argus += $userInput
        } else {
             $argus += $profileName
        }
    }

    #################### For URL

    if ($searchString -match '^(https?://|www\.).*$') {
        Write-Host "`n       $($browserList[$browserChoice])" -n -ForegroundColor DarkCyan
        Write-Host " 🔎 " -n -ForegroundColor Yellow
        Write-Host "$searchString`n" -ForegroundColor Cyan
        Start-Process $browserPath $searchString
        return
    }








    ##################################### Search Engine Selection ###################################

    $jsonFilePath = Join-Path -Path $PSScriptRoot -ChildPath './User/SearchEngineList.json'
    $jsonContent = Get-Content -Path $jsonFilePath -Raw
    $jsonObject = $jsonContent | ConvertFrom-Json
    $foundSearchEngine = $null

    $searchEngineList = @()
    foreach ($searchEngine in $jsonObject.UserSearchEngineList) {
        if ($($searchEngine.url) -ne "") {
            $searchEngineList += $searchEngine.Name
        }
    }

    if (-not($s)) {
        try {
            $foundSearchEngine = $jsonObject.DefaultSearchEngine[0]
        } catch {
             Write-Host "`n 💀 Default search engine not found!!" -ForegroundColor Red
             Terminal2BrowserErrorType1
             # Write-Host "    $_`n" -ForegroundColor Yellow
             return
        }
    } elseif ($s -and ($searchEngineName -eq "")) {
        Import-Module (Join-Path $PSScriptRoot "Utility.psm1") -Force
        $searchEngineChoice = userChoice $searchEngineList "Search Engine Preference"

        $foundSearchEngine = $jsonObject.UserSearchEngineList | Where-Object { $_.Name -eq $searchEngineChoice }

        if ($foundSearchEngine -eq $null) {
            Write-Host "`n 💀 Error: Search engine is not recognized!!" -ForegroundColor Red
            Terminal2BrowserErrorType1
            return
        }

    } elseif ($searchEngineName -ne "") {
        $foundSearchEngine = $jsonObject.UserSearchEngineList | Where-Object { $_.cmdName -eq $searchEngineName }
        if ($foundSearchEngine -eq $null) {
            Write-Host "`n 💀 Invalid search engine name cannot be recognized!!`n" -ForegroundColor Red
            return
        }
    }

    $searchURL = $foundSearchEngine.url -f [uri]::EscapeDataString($searchString)




    ############################### Final Execution ############################################### 

    Write-Host "`n       $($foundBrowser.Name)" -n -ForegroundColor DarkCyan
    Write-Host " > " -n -ForegroundColor Yellow
    Write-Host "$($foundSearchEngine.Name)" -n -ForegroundColor Magenta
    Write-Host " > " -n -ForegroundColor Yellow
    Write-Host "$searchString`n" -ForegroundColor Cyan
    
    Start-Process $browserPath -ArgumentList "$argus$searchURL"
}