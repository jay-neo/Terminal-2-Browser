<div align="center"><h1>Terminal-2-Browser</h1></div>



### Prerequisite 
1. PowerShell Core - [`pwsh`](https://apps.microsoft.com/detail/9MZ1SNWT0N5D)

```pwsh
winget install --id Microsoft.Powershell --source winget --silent
```

2. Set the PowerShell execution policy "RemoteSigned"

Run PowerShell as Admin

```pwsh
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Installation

```pwsh
git clone https://github.com/jay-neo/Terminal-2-Browser.git $env:TEMP\Terminal-2-Browser
cd $env:TEMP\Terminal-2-Browser
pwsh install.ps1

```
