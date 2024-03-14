
function Terminal2BrowserErrorType1 {
    Write-Host "$(relativePosition 73)" -n
    Write-Host "To fix, use '" -NoNewline -ForegroundColor Yellow
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
                if (($itr2 -lt $args.Count) -and (($args[$itr2] -ne "-s") -and ($args[$itr2] -ne "-p") -and ($args[$itr2] -ne "-config"))) {
                    $browserName = $args[$itr2]
                    $itr++
                }
            }
            "-s" {
                $s = $true
                $itr2 = $itr + 1
                if (($itr2 -lt $args.Count) -and (($args[$itr2] -ne "-b") -and ($args[$itr2] -ne "-p") -and ($args[$itr2] -ne "-config"))) {
                    $searchEngineName = $args[$itr2]
                    $itr++
                }
            }
            "-p" {
                $p = $true
                $itr2 = $itr + 1
                if (($itr2 -lt $args.Count) -and (($args[$itr2] -ne "-s") -and ($args[$itr2] -ne "-b") -and ($args[$itr2] -ne "-config"))) {
                    $profileName = $args[$itr2]
                    $itr++
                }
            }
            "-config" {
                Import-Module (Join-Path $PSScriptRoot "SetupConfig.psm1") -Force
                Terminal2BrowserConfigurationOfBrowserList
            }
        }
    }

    $neoPath = Join-Path $PSScriptRoot "neoLibrary.psm1"
    if (-not(Test-Path $neoPath)) {
        Write-Host "`n`t'" -n -f Red
        Write-Host "$neoPath" -n -f Yellow
        Write-Host "' file not found! 😲`n" -f Red
        return
    }
    Import-Module $neoPath -Force


    ########################################## Debug
    # Write-Host "Args: $($args -join ', ')"
    # Write-Host "Search String  = '$searchString'"
    # if($b) { Write-Host "b = true = '$browserName'"}
    # if($s) { Write-Host "s = true = '$searchEngineName'" }
    # if($p) { Write-Host "p = true = '$profileName'" }
    # return


    ################################ Browser Selection #########################################

    $jsonFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'User/BrowserList.json'
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
            $errMsg = "💀 Default browser not found!!"
            Write-Host "`n$(relativePosition $($errMsg.Length))$errMsg" -f Red
            Terminal2BrowserErrorType1
            return
        }
        $foundBrowser = $jsonObject.DefaultBrowser[0]
    } elseif ($b -and ($browserName -eq "")) {
        $browserChoice = neoChoice $browserList "Browser Preference"

        $foundBrowser = $jsonObject.UserBrowserList | Where-Object { $_.Name -eq $browserChoice }
        if ($foundBrowser -eq $null) {
            $errMsg = "💀 Browser is not recognized!!"
            Write-Host "`n$(relativePosition $($errMsg.Length))$errMsg" -f Red
            Terminal2BrowserErrorType1
            return
        }
    } elseif ($browserName -ne "") {
        $foundBrowser = $jsonObject.UserBrowserList | Where-Object { $_.WindowsName -eq $browserName }
        if ($foundBrowser -eq $null) {
            $errMsg = "💀 Invalid browser name cannot be recognized!!"
            Write-Host "`n$(relativePosition $($errMsg.Length))$errMsg`n" -f Red
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
        $t = $($foundBrowser.Name).Length + $searchString.Length + 6
        Write-Host "`n$(relativePosition $t)$($foundBrowser.Name)" -n -ForegroundColor Green
        Write-Host " > " -n -ForegroundColor Yellow
        Write-Host "$searchString`n" -ForegroundColor Cyan
        Start-Process $browserPath $searchString
        return
    }








    ##################################### Search Engine Selection ###################################

    $jsonFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'User/SearchEngineList.json'
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
            $errMsg = "💀 Default search engine not found!!"
            Write-Host "`n$(relativePosition $($errMsg.Length))$errMsg" -f Red
            Terminal2BrowserErrorType1
            # Write-Host "    $_`n" -ForegroundColor Yellow
            return
        }
    } elseif ($s -and ($searchEngineName -eq "")) {
        $searchEngineChoice = neoChoice $searchEngineList "Search Engine Preference"

        $foundSearchEngine = $jsonObject.UserSearchEngineList | Where-Object { $_.Name -eq $searchEngineChoice }

        if ($foundSearchEngine -eq $null) {
            $errMsg = "💀 Error: Search engine is not recognized!!"
            Write-Host "`n$(relativePosition $($errMsg.Length))$errMsg" -f Red
            Terminal2BrowserErrorType1
            return
        }

    } elseif ($searchEngineName -ne "") {
        $foundSearchEngine = $jsonObject.UserSearchEngineList | Where-Object { $_.cmdName -eq $searchEngineName }
        if ($foundSearchEngine -eq $null) {
            $errMsg = "💀 Invalid search engine name cannot be recognized!!"
            Write-Host "`n$(relativePosition $($errMsg.Length))$errMsg`n" -f Red
            return
        }
    }

    $searchURL = $foundSearchEngine.url -f [uri]::EscapeDataString($searchString)




    ############################### Final Execution ############################################### 

    $t = $($foundBrowser.Name).Length + ($foundSearchEngine.Name).Length + $searchString.Length + 6
    Write-Host "`n$(relativePosition $t)$($foundBrowser.Name)" -n -ForegroundColor Green
    Write-Host " > " -n -ForegroundColor Yellow
    Write-Host "$($foundSearchEngine.Name)" -n -ForegroundColor Blue
    Write-Host " > " -n -ForegroundColor Yellow
    Write-Host "$searchString`n" -ForegroundColor Cyan
    
    Start-Process $browserPath -ArgumentList "$argus$searchURL"
}