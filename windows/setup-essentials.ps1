$Threading = Join-Path $PSScriptRoot "/lib/threading.ps1"
. $Threading

function Add-FrillsJob {
    $DiagFile = Join-Path $PSScriptRoot "/blob/frills.diag"

    $JobOptions = New-ScheduledJobOption -RunElevated
    $StartupTrigger = New-JobTrigger -AtStartup
    $FrillsPath = Join-Path $PSScriptRoot "setup-frills.ps1"
    
    $Script = { param( $Script , $Log )

        Remove-Item -Path $log -Force
        Invoke-Expression "$Script -Verbose -Debug *> $log"
        Unregister-ScheduledJob -Name "setup-frills"
        Get-ScheduledJob  
    }

    Unregister-ScheduledJob -Name "setup-frills"
    Register-ScheduledJob -Name "setup-frills" -Trigger $StartupTrigger  -ScheduledJobOption  $JobOptions -ScriptBlock $Script -ArgumentList @($FrillsPath , $DiagFile )

}

function Add-Looks {
    
    $Script = { param( 
            $FontsModule ,
            $KeyBoardModule , 
            $AppearanceModule ,
            $ColemakArchive
        )
    

        . $FontsModule
        . $KeyBoardModule
        . $AppearanceModule
        
        
        $Wallpaper = Resolve-Path $PSScriptRoot /blob/Wallpaper.jpg
        Set-AppearanceWallpaper -Image  $Wallpaper
        
        displayswitch.exe /extend 
        Set-AppearanceExplorer
        Set-AppearanceTaskbar
        Set-AppearanceSystem
        Add-NerdFonts     


        Set-KeyboardLayouts $ColemakArchive
        Set-TimeZone -Name 'E. South America Standard Time'
        
        
        
        # $EnglishLang = New-WinUserLanguageList -Language $LangSelect -ErrorAction SilentlyContinue
        # Set-WinUserLanguageList -LanguageList $EnglishLang


    }  
    
    $Parameters = @{ 
        FontsModule      = Join-Path $PSScriptRoot "/lib/fonts.ps1"
        KeyBoardModule   = Join-Path $PSScriptRoot "/lib/keyboard.ps1"
        AppearanceModule = Join-Path $PSScriptRoot "/lib/appearance.ps1"
        ColemakArchive   = Join-Path $PSScriptRoot "/blob/Colemak.zip"
    }

    
    return Start-Background $Script $Parameters
    
    
    
}

function Add-Choco {

    $Script = { 

        
        $ChocoUrl = 'https://community.chocolatey.org/install.ps1'
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
        Invoke-RestMethod -Uri $ChocoUrl | Invoke-Expression    

        $Installs = @(  
            "7zip"
            "autohotkey"
            "git"
            "sublimetext4"
            "win-vind"
            "vscode"
            "fzf"
            "oh-my-posh"
            "firefox"
            "wget"
        )
        
        choco install $Installs -y 
        

    } 

    $Parameter = @{ }

    return Start-Background $Script $Parameter
}
function Add-WSL1 {
    

    
    $Script = { param( $WSLModule )
        . $WSLModule
        InstallWSL
    }
    $Parameter = @{ 
        WSLModule = Join-Path $PSScriptRoot "/lib/wsl.ps1"
    }

    return Start-Background $Script $Parameter 
    
}
function Add-Links {

    $LinksModule = Join-Path $PSScriptRoot "/lib/linking.ps1"
    .$LinksModule


    
    $Root = Split-Path $PSScriptRoot -Parent
    
    $MappingFile = "/windows/blob/mapping.json"
    Set-Mappings $Root $MappingFile
        

}

function Optimize-Bloat {

    $ServicesModule = Join-Path $PSScriptRoot "/lib/services.ps1"
    . $ServicesModule
    
    Optimize-Services
    Optimize-WindowsDefender

    $PackagesModule = Join-Path $PSScriptRoot "/lib/packages.ps1"
    . $PackagesModule

    Optimize-AppxPackages
    
    

    $TasksModule = Join-Path $PSScriptRoot "/lib/tasks.ps1"
    . $TasksModule

    Optimize-BackgroundTasks

    $NetworkModule = Join-Path $PSScriptRoot "/lib/network.ps1"
    . $NetworkModule
    Optimize-Privacy
    Optimize-NetworkTraffic
    
    #Optimize-Others    
    #$Reg = Join-Path $PSScriptRoot "lib/ram.reg"
    #reg import $Reg 
    
    
}

function todo {

    #
    #
    #

    $RegistryModule = Join-Path $PSScriptRoot "/lib/registry.ps1"
    . $RegistryModule
    
    # $Changes = @(
    #     @{
    #         Path  = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\PowerShell.exe"
    #         Key   = ""
    #         Value = '%ProgramFiles%\Alacritty\a.bat'
    #         Kind  = "ExpandString"
    #     }
    # )
    # Add-Registry $Changes
    


}
#
#
#
#
#

$LooksJob = Add-Looks
$Installations = Add-Choco
$WSL = Add-WSL1

Add-Looks Add-FrillsJob Optimize-Bloat

Wait-Background @( 
    $Installations  
    $LooksJob
    $WSL
)
Add-Links



Restart-Computer;
