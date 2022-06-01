function FindCommand ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}

function GitAmmend {
    git add .
    git commit --amend --no-edit
    git push --force-with-lease --recurse-submodules=on-demand
}

function GitShove($Message) {
    if ( -not $Message ) {
        $Message  = Read-Host "Message for the commit/push"
    }
    $Command = "git add . ; git commit -m '$Message' ; git push --force-with-lease"
    Write-Host $Command
    git submodule foreach  $Command
    git add .
    git commit -m '$Message'
    git push --force-with-lease --recurse-submodules=on-demand
}

function GitShoveWorkspace( $Message ) {
    Write-Host "Shoving All"
    $OriginalPath = Get-Location    
    Write-Host "$OriginalPath"
    $Workspaces = Get-ChildItem -Path $OriginalPath -Filter "*.code-workspace" 
    
    if ( -not $Workspaces){
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

Set-Alias -Name vim -Value nvim
Set-Alias -Name grep -Value findstr
Set-Alias -Name tig -Value 'C:\Program Files\Git\usr\bin\tig.exe'
Set-Alias -Name less -Value 'C:\Program Files\Git\usr\bin\less.exe'
Set-Alias -Name sublime -Value "C:\Program Files\Sublime Text\sublime_text.exe"
Set-Alias -Name which -Value FindCommand


Set-Alias -Name gammend -Value GitAmmend
Set-Alias -Name gshove -Value GitShove
Set-Alias -Name gshoveall -Value GitShoveWorkspace
Set-Alias -Name gunmod -Value GitRemoveSubmodule
Set-Alias -Name gflush -Value GitFlush
Set-Alias -Name gundo -Value GitUndo


 