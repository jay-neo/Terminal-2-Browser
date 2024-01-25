function Terminal2BrowserConfigurationOfBrowserList {

    $jsonFilePath = Join-Path -Path $PSScriptRoot -ChildPath '.\User\BrowserList.json'
    $jsonContent = Get-Content -Path $jsonFilePath -Raw

    $jsonObject = $jsonContent | ConvertFrom-Json

    # if ($IsWindows) {
    if ($env:OS -like '*Windows*') {
        foreach ($browser in $jsonObject.UserBrowserList) {
            $registryPath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$($browser.WindowsName).exe"
            if (Test-Path $registryPath) {
                $browser.Path = (Get-ItemProperty -Path $registryPath).'(default)'
            }
        }

        $browserKeyPath = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
        
        try {
            $progId = (Get-ItemProperty -LiteralPath $browserKeyPath -ErrorAction Stop).Progid
            $browserCommand = (Get-ItemProperty -LiteralPath "Registry::HKEY_CLASSES_ROOT\$progId\shell\open\command" -ErrorAction Stop).'(default)'
            $browserPath = $browserCommand -replace '^(?:"([^"]*)"|([^ ]*)) .*$', '$1$2'
            $jsonObject.DefaultBrowser[0].Path = $browserCommand -replace '^(?:"([^"]*)"|([^ ]*)) .*$', '$1$2'
        } catch {
            Write-Host "`n 💀 Error: Unable to find the default browser path!!`n    $_" -ForegroundColor Red
        }

    }
    #elseif ($env:OS -like '*Unix*') { }


    foreach ($browser in $jsonObject.UserBrowserList) {
        if($browser.Path -eq $jsonObject.DefaultBrowser[0].Path) {
            $jsonObject.DefaultBrowser[0] = $browser
            break
        }
    }

    $updatedJsonContent = $jsonObject | ConvertTo-Json -Depth 10

    $updatedJsonContent | Set-Content -Path $jsonFilePath
}

