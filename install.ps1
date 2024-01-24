if (-not (Get-Command pwsh.exe -ErrorAction SilentlyContinue)) {
    winget install --id Microsoft.Powershell --source winget --silent
}




# Issue : Terminal2Browser not supported powershell.exe
if (-not ($PSVersionTable.PSEdition -eq 'Core')) {
    Write-Host "`n`n`tThis module not supported in -PSEdition Desktop"  -ForegroundColor Red
    Write-Host "`tType 'pwsh install.ps1' and press <Enter>`n" -ForegroundColor Yellow
    pwsh -nolog
    return
}


$repoName = "Terminal2Browser"
$filePath = $PROFILE.CurrentUserCurrentHost
$AppendLine = "`nImport-Module -Name '$repoName'`n"

$destinationPath = [System.IO.Path]::GetDirectoryName($filePath)


if (-not (Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
}


if (Test-Path $filePath -PathType Leaf) {
    $existingContent = Get-Content $filePath
    $existingContent += $AppendLine
    $AppendLine | Out-File -FilePath $filePath -Encoding UTF8 -Append
} else {
    $AppendLine | Out-File -FilePath $filePath -Encoding UTF8
}

$destinationPath = $($destinationPath + "\Modules\" + $repoName)
 
if (Test-Path $destinationPath -PathType Container) {
    $currentDateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $backupPath = $destinationPath + "_Backup@" + $currentDateTime
    mv $destinationPath $backupPath
}

$sourcePath = $(Join-Path (Get-Location) $repoName)
mv $sourcePath $destinationPath -ErrorAction Stop | Out-Null

cls
echo "`n`n"
echo "`t`t#######\   ######\  ##\   ##\ ########\ "
echo "`t`t##  __##\ ##  __##\ ###\  ## |##  _____|"
echo "`t`t## |  ## |## /  ## |####\ ## |## |      "
echo "`t`t## |  ## |## |  ## |## ##\## |#####\    "
echo "`t`t## |  ## |## |  ## |## \#### |##  __|   "
echo "`t`t## |  ## |## |  ## |## |\### |## |      "
echo "`t`t#######  | ######  |## | \## |########\ "
echo "`t`t\_______/  \______/ \__|  \__|\________|"
echo "`n"


if ($PSVersionTable.PSEdition -eq 'Desktop') {
    powershell -nolog
} elseif ($PSVersionTable.PSEdition -eq 'Core') {
    pwsh -nolog
}
