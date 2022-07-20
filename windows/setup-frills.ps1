 

$Threading = Join-Path $PSScriptRoot "/lib/threading.ps1"
. $Threading

function Add-EnvPath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Session')]
        [string] $Container = 'Session'
    )

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
function Install-Frills {
    
    

    
        $Script = { param($name) 
        $Installs = @(  
        "alacritty"
        "python"
        
        "discord"
        "neovim"  
        "obsidian"

        "docker-desktop"
        "intellijidea-ultimate"
        "spotify" 

        "insomnia-rest-api-client"
        "krita"
        "sumatrapdf"
        )
            choco install $Installs -y  
        } 

        $Parameter = @{ }

        return Start-Background $Script $Parameter 
    
    return $Installs
    
}

function Set-Code {
    
    $Script = {
    
        function Join-Prefix($List , $Prefix ) {
            $Result = ''
            $List | ForEach-Object {        
                $Result = $Result + $Prefix + $_ 
            }

            return $Result

        }

        function Convert-Install($List) {
            return "code " + (Join-Prefix $List  " --install-extension ")
        }
        
    
        $Priority = @(
            "alefragnani.project-manager",
            "canelhasmateus.jewel",
            "canelhasmateus.partial",
            "mark-wiemer.vscode-autohotkey-plus-plus",
            "percygrunwald.vscode-intellij-recent-files",
            "ryuta46.multi-command",
            "usernamehw.errorlens",
            "wmaurer.vscode-jumpy",
            "ms-vscode.powershell"
        
        ) 
        $Zettel = @(
    
            "bierner.markdown-mermaid",
            "bpruitt-goddard.mermaid-markdown-syntax-highlighting",
            "foam.foam-vscode",
            "mushan.vscode-paste-image",        
            "tht13.html-preview-vscode",
            "yzhang.markdown-all-in-one",
            "brokenprogrammer.paragraphjump"
            "DavidAnson.vscode-markdownlint",
            "znck.grammarly"

        )
    
        $BaseSupport = @(

            "ms-python.python",
            "ms-vscode.anycode-typescript",
            "ms-vscode.anycode",
            "rbbit.typescript-hero",
            "VisualStudioExptTeam.vscodeintellicode",
            "eamodio.gitlens",
            "formulahendry.code-runner"


        )
        $Others = @( 
    
            "GitHub.copilot",
            "coolchyni.beyond-debug",
            "ms-vscode-remote.remote-containers",
            "ms-vscode-remote.remote-ssh-edit",
            "ms-vscode-remote.remote-ssh",
            "ms-vscode-remote.remote-wsl",
            "tintinweb.vscode-inline-bookmarks",        
            "vadimcn.vscode-lldb",
            "webfreak.debug",
            "ms-python.vscode-pylance",
            "ms-vscode.anycode-python",
            "svelte.svelte-vscode",
            "ardenivanov.svelte-intellisense",
            "cschlosser.doxdocgen",
            "evgeniypeshkov.syntax-highlighter",
            "jeff-hykin.better-cpp-syntax",
            "julialang.language-julia",
            "kakumei.ts-debug",
            "ms-azuretools.vscode-docker",
            "ms-toolsai.jupyter-renderers",
            "ms-toolsai.jupyter",
            "ms-vscode.anycode-c-sharp",
            "ms-vscode.anycode-cpp",
            "ms-vscode.anycode-go",
            "ms-vscode.anycode-java",
            "ms-vscode.anycode-php",
            "ms-vscode.anycode-rust",
            "ms-vscode.cmake-tools",
            "ms-vscode.cpptools-extension-pack",
            "ms-vscode.cpptools-themes"
            "ms-vscode.cpptools",
            "ms-vscode.vscode-typescript-next",
            "nadako.vshaxe",
            "nimsaem.nimvscode",
            "redhat.vscode-yaml",
            "rust-lang.rust",
            "tomoki1207.pdf",
            "twxs.cmake",
            "zero-plusplus.vscode-autohotkey-debug"
        ) 



        choco install nodejs yarn  -y 
        Convert-Install $Priority | Invoke-Expression
        Convert-Install $Zettel | Invoke-Expression

        
        Convert-Install $BaseSupport | Invoke-Expression
        Convert-Install $Others | Invoke-Expression

        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
        Install-Module -Name PackageManagement -Force -MinimumVersion 1.4.6 -Scope CurrentUser -AllowClobber -Repository PSGallery    
        npm install -g vsce

    }

    $Parameter = @{}
    return Start-Background $Script  $Parameter
}

function Set-Workspace {
    
    $DesktopPath = [Environment]::GetFolderPath("Desktop")
    $Workspace = Join-Path $DesktopPath "Workspace"
    New-Item $Workspace 
    Set-Location $Workspace
    git config --global user.email "mateus.canelhas@gmail.com"
    git config --global user.name "Mateus Canelhas"
    git config --global merge.conflictstyle diff3
    
    
    git clone https://github.com/canelhasmateus/canalhaclub.git
    git clone https://github.com/canelhasmateus/canelhasio.git
    git clone https://github.com/canelhasmateus/leet.git
    git clone https://github.com/canelhasmateus/nimskull.git
    
    
    
    $NimskullBin = Join-Path (Get-Location) "nimskull\bin"
    Add-EnvPath $NimskullBin "User"
    # todo Git profiles https://deepsource.io/blog/managing-different-git-profiles/

}


function Set-Wsl {

    $Script = { param( $WslModule )
        
        . $WslModule
        Install-Wsl2
        
    }
    $Parameter = @{ 
        WslModule = Join-Path $PSScriptRoot "/lib/wsl.ps1"    
    }
        
    return Start-Background  $Script $Parameter
    
    
}
#
#
#
#
function Set-Browser {

    $Script = { param( )
        
        $XPIS = @(
            "https://addons.mozilla.org/firefox/downloads/file/3898202/vimium_ff-1.67.1.xpi"
            "https://addons.mozilla.org/firefox/downloads/file/3782413/new_tab_override-15.1.1.xpi"
            "https://addons.mozilla.org/firefox/downloads/file/3911043/markdownload-3.1.0.xpi"
            "https://addons.mozilla.org/firefox/downloads/file/3955386/copy_all_tab_urls_we-2.1.0.xpi"
            "https://addons.mozilla.org/firefox/downloads/file/3961087/ublock_origin-1.43.0.xpi"
            "https://addons.mozilla.org/firefox/downloads/file/3812704/umatrix-1.4.4.xpi"
        )
        


        $XPIS | ForEach-Object { 
            wget $_ -o 
            firefox ./current.xpi
        }
        
        
    }
    $Parameter = @{ 

    }
        
    return Start-Background  $Script $Parameter
    
    
}





$ChocoJob = Install-Frills
$WslJob = Set-Wsl
$CodeJob = Set-Code


Set-Workspace
displayswitch.exe /extend
Wait-Background @( $ChocoJob , $WslJob , $CodeJob )


