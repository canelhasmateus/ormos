$Aliases = Join-Path $PSScriptRoot "/lib/aliases.ps1"
. $Aliases

$Completion = Join-Path $PSScriptRoot "/lib/completion.ps1"
. $Completion

$Terminal = Join-Path $PSScriptRoot "/lib/terminal.ps1"
. $Terminal

# set PowerShell to UTF-8
[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

$PSDefaultParameterValues = @{ '*:Encoding' = 'utf8' }

$CurrentDir = Get-Location

if ($CurrentDir.Path -eq "C:\Windows\System32") {
    $Desktop = "C:\Users\Mateus\Desktop"
    Set-Location $Desktop
}
# $env:GIT_SSH = "C:\Windows\system32\OpenSSH\ssh.exe"

# Todo: Read this.
# https://docs.microsoft.com/en-us/powershell/module/psreadline/about/about_psreadline?view=powershell-7.2