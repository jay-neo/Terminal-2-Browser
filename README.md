<div align="center"><h1>Terminal-2-Browser</h1></div>

**`t2`** is a PowerShell command tool that allows users to quickly search for any string or URL from the terminal and open it directly in the available browser in the local machine. This tool simplifies the process of accessing web content, making it easy to navigate from the command line.

## Usage

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

Copy & Paste this code in `pwsh`

```pwsh
git clone https://github.com/jay-neo/Terminal-2-Browser.git $env:TEMP\Terminal-2-Browser
cd $env:TEMP\Terminal-2-Browser
pwsh install.ps1

```

![1](https://github.com/jay-neo/Terminal-2-Browser/assets/118971315/5fc6580c-1df8-4317-859a-19362ce51203)
![2](https://github.com/jay-neo/Terminal-2-Browser/assets/118971315/49796409-6563-40c7-a512-9741d72ffa54)


## Demo

![3](https://github.com/jay-neo/Terminal-2-Browser/assets/118971315/abb062fa-1578-4618-bb1e-9e8988e9adf1)

