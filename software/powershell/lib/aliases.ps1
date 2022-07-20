function FindCommand ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function GitAmmend {
    git commit --amend --no-edit
    git push --force-with-lease --recurse-submodules=on-demand
}

function GitShove($Message) {
    if ( -not $Message ) {
        $Message = Read-Host "Message for the commit/push"
    }
    $Command = "git add . ; git commit -m '$Message' ; git push --force-with-lease"
    Write-Host $Command
    git submodule foreach  $Command
    git add .
    git commit -m "$Message"
    git push --force-with-lease --recurse-submodules=on-demand
}

function GitShoveWorkspace( $Message ) {
    Write-Host "Shoving All"
    $OriginalPath = Get-Location    
    Write-Host "$OriginalPath"
    $Workspaces = Get-ChildItem -Path $OriginalPath -Filter "*.code-workspace" 
    
    if ( -not $Workspaces) {
        Write-Host "Unable to find a workspace file."
        return
    }
    
    if (-not $Message) {
        $Message = Read-Host "Message for the commit/push"
    }

    foreach ($currentWorkspace in $Workspaces) {
        $Config = Get-Content $currentWorkspace | ConvertFrom-Json
        foreach ($currentFolder in $Config.folders) {
            
            $ResolvedFolder = Resolve-Path $currentFolder.path
            Write-Host "Saving " $ResolvedFolder
            
            Set-Location  $ResolvedFolder
            GitShove "." $Message
            Set-Location $OriginalPath
        }


    }
    

}

function GitRemoveSubmodule( $Path) {
    git submodule deinit -f $Path
    $ToRemove = Resolve-Path ".git/modules/$Path" -ErrorAction SilentlyContinue
    Remove-Item  $ToRemove -Force -Recurse -ErrorAction SilentlyContinue
    git rm -f $path
}
function GitFlush( $Path) {
    
    if (-not $Path) {
        $Path = Read-Host "Path for undoing"
        if ( -not $Path) {
            $Path = "."
        }
    }

    git rm -rf --cached $Path
    git add $Path
}
function GitUndo( $Path) {
    if (-not $Path) {
        $Path = Read-Host "Path for undoing"
    }

    git restore --staged $Path
    git restore $Path
}
function GitScrape( $Path) {
    git reset --soft head~
}

function AddUserPath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )
    
    $Container = "User"
    if ($Container -ne 'Session') {
        $containerMapping = @{
            Machine = [EnvironmentVariableTarget]::Machine
            User    = [EnvironmentVariableTarget]::User
        }
        $containerType = $containerMapping[$Container]

        $persistedPaths = [Environment]::GetEnvironmentVariable('Path', $containerType) -split ';'
        if ($persistedPaths -notcontains $Path) {
            $persistedPaths = $persistedPaths + $Path | Where-Object { $_ }
            [Environment]::SetEnvironmentVariable('Path', $persistedPaths -join ';', $containerType)
        }
    }

    $envPaths = $env:Path -split ';'
    if ($envPaths -notcontains $Path) {
        $envPaths = $envPaths + $Path | Where-Object { $_ }
        $env:Path = $envPaths -join ';'
    }
}

Set-Alias -Name vim -Value nvim
Set-Alias -Name grep -Value findstr
Set-Alias -Name tig -Value 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias -Name less -Value 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias -Name sublime -Value "C:\Program Files\Sublime Text\sublime_text.exe"
Set-Alias -Name idea -Value "C:\Program Files\JetBrains\IntelliJ IDEA 2022.1.1\bin\idea64.exe"
Set-Alias -Name which -Value FindCommand
Set-Alias -Name to -Value z

Set-Alias -Name addPath -Value AddUserPath
Set-Alias -Name gammend -Value GitAmmend
Set-Alias -Name gshove -Value GitShove
Set-Alias -Name gshovespace -Value GitShoveWorkspace
Set-Alias -Name gunmod -Value GitRemoveSubmodule
Set-Alias -Name gflush -Value GitFlush
Set-Alias -Name gundo -Value GitUndo
Set-Alias -Name gscrape -Value GitScrape
Set-Alias -Name java -Value C:\Users\Mateus\.jdks\corretto-1.8.0_332\bin\java
Set-Alias -Name firefox -Value "C:\Program Files\Mozilla Firefox\firefox.exe"
    


 