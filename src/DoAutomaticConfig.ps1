<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   𝔭𝔬𝔴𝔢𝔯𝔰𝔥𝔢𝔩𝔩
#>


# ============================================================================================================
# SCRIPT VARIABLES
# ============================================================================================================
$Script:CurrentPath = (Get-Location).Path
$Script:ScriptPath = ''
$Script:CurrentModule = $ExecutionContext.SessionState.Module

if(($Global:MyInvocation) -And ($Global:MyInvocation.MyCommand) -And ($Global:MyInvocation.MyCommand.Path)){
    $Script:ScriptPath  = Split-Path $Global:MyInvocation.MyCommand.Path
}
$Script:PwshPath = (Get-Item ((Get-Command pwsh.exe).Source)).DirectoryName

$Script:Edition=$PSVersionTable.PSEdition.ToString()
$Script:Version=$PSVersionTable.PSVersion.ToString()
$Script:Paths = (Get-ModulePath | where Writeable -eq $True).Path
$Script:DefaultModulePath = ''
if($Paths.Count -gt 0){
     $DefaultModulePath = $Paths[0]
}
       


$Script:GIT_WINDOWS_64_URL      = 'https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-64-bit.exe'

$Script:DATA_DRIVE             = "c:\"
$Script:TEST_MODE              = "$false"
$Script:QUIET_MODE             = "$Quiet"
$Script:DEV_ROOT               = Join-Path "$Script:DATA_DRIVE" "Development"
$Script:SYSCONFIG_SCRIPTS      = "$PSScriptRoot\Scripts"
$Script:CONFIGURE_SCRIPT_PATH  = "$SYSCONFIG_SCRIPTS\Configure.ps1"
$Script:WINGIT_SCRIPT_PATH     = "$SYSCONFIG_SCRIPTS\WindowsGit.ps1"
$Script:REG_USER_ENV           = "$SYSCONFIG_SCRIPTS\UserEnv.reg"
$Script:REG_GLOBAL_ENV         = "$SYSCONFIG_SCRIPTS\GlobalEnv.reg"
$Script:OrganizationHKCUScript = "$SYSCONFIG_SCRIPTS\OrganizationHKCU.reg"

$Script:PROGRAMS_PATH           = Join-Path "$Script:DATA_DRIVE" "Programs"
$Script:MYDOCUMENTS_PATH        = Join-Path "$Script:DATA_DRIVE" "DOCUMENTS"
$Script:MYPICTURES_PATH         = Join-Path "$Script:DATA_DRIVE" "Data\Pictures"
$Script:MYVIDEOS_PATH           = Join-Path "$Script:DATA_DRIVE" "Data\Videos"
$Script:SCREENSHOTS_PATH        = Join-Path "$Script:DATA_DRIVE" "Data\Pictures\Screenshots"
$Script:DOWNLOAD_PATH           = Join-Path "$Script:DATA_DRIVE" "Data\Downloads"
$Script:DESKTOP_PATH            = Join-Path "$Script:DATA_DRIVE" "Data\Windows\Desktop"

$Script:WIN_GIT_INSTALL_PATH    = Join-Path "$Script:PROGRAMS_PATH" "Git"
$Script:POWERSHELL_PATH         = Join-Path "$Script:MYDOCUMENTS_PATH" "PowerShell"
$Script:PS_MODULES_PATH         = Join-Path "$Script:POWERSHELL_PATH" "Modules"
$Script:PS_MODDEV_PATH          = Join-Path "$Script:POWERSHELL_PATH" "Module-Development"
$Script:PS_PROFILE_PATH         = Join-Path "$Script:POWERSHELL_PATH" "Profile"
$Script:PS_PROJECTS_PATH        = Join-Path "$Script:POWERSHELL_PATH" "Projects"

$Script:PwshExe                 = (Get-Command 'pwsh.exe').Source

Write-Host "===============================================================================" -f DarkRed
Write-Host "Configuration" -f DarkYellow;
Write-Host "===============================================================================" -f DarkRed    
Write-Host "Current Path       `t" -NoNewLine -f DarkYellow ; Write-Host "$Script:CurrentPath" -f Gray 
Write-Host "Script Path        `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:TermScript" -f Gray 
Write-Host "Pwsh Install Path  `t" -NoNewLine -f DarkYellow;  Write-Host "$PwshPath" -f Gray 
Write-Host "Pwsh Version       `t" -NoNewLine -f DarkYellow;  Write-Host "$Version" -f Gray 
Write-Host "Pwsh Edition       `t" -NoNewLine -f DarkYellow;  Write-Host "$Edition" -f Gray 
Write-Host "Default Module Path`t" -NoNewLine -f DarkYellow;  Write-Host "$DefaultModulePath" -f Gray 


# ============================================================================================================
# SCRIPT LOGS
# ============================================================================================================

function write-serr([string]$msg,[switch]$fatal){    
    Write-Host -n "❗❗❗ "; Write-Host -f DarkYellow "$msg"
    if($fatal){ exit; }
}

function write-smsg([string]$msg,[switch]$ok=$false){
    if($ok){Write-Host -n "✅ "; }else{ Write-Host -n "⚡ "; }
    Write-Host " $msg"
}

function Write-Title{

    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory=$true,Position=0)]    
        [string]$Title
    )

    Write-Host -f DarkYellow "`n======================================================"
    Write-Host -n -f DarkRed "$Title"
    if($Script:TEST_MODE -eq $False){
        Write-Host -n -f DarkRed "`n"
    }else{
        Write-Host -f Red "  ** TEST MODE"
    }
    Write-Host -f DarkYellow "======================================================`n"

}


# ============================================================================================================
# SCRIPT Dependencies
# ============================================================================================================

$Script:MessageBoxParams = @{
    Title = "Confirmation"
    TitleBackground = "Gray"
    TitleTextForeground = "MidnightBlue"
    TitleFontWeight = "UltraBold"
    TitleFontSize = 16
    ButtonType = "Yes-No"
}



# ============================================================================================================
# SCRIPT FUNCTIONS
# ============================================================================================================


function Initialize-CoreModule {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    try {
        $DefaultErrorAction = $ErrorActionPreference
        $ErrorActionPreference = "SilentlyContinue"


        $null=New-Item -Path $RegistryPath -Force | Out-Null
        $null=New-RegistryValue $RegistryPath "Version" "$Version" String
        $null=New-RegistryValue $RegistryPath "Edition" "$Edition" String
        $null=New-RegistryValue $RegistryPath "InstallPath" "$PwshPath" String
        $null=New-RegistryValue $RegistryPath "DefaultModulePath" "$DefaultModulePath" String
        $ErrorActionPreference = $DefaultErrorAction 
    }catch [Exception]{
        Write-Host '[ERROR] ' -f DarkRed -NoNewLine
        Write-Host "Powershell Registry Configuration $_" -f DarkYellow
        Show-ExceptionDetails($_) -ShowStack
    }
}



function Install-PSafe{
    $Url = 'https://github.com/pwsafe/pwsafe/releases/download/3.58.0/pwsafe-3.58.0.exe'
    $Local= "$ENV:TEMP\pwsafe-3.58.0.exe"
    Get-OnlineFileNoCache -Url $Url -Path $Local
    if(Test-Path -Path $Local -PathType 'Leaf'){
        Read-Host 'Press a key to launch installer...'
        & "$Local"
    }
}


function Initialize-Configurator{
    Register-Assemblies
     Show-MessageBox @MessageBoxParams -Content $Text
}




function Invoke-RestartWithAdminPriv{

    $Text = "
    Some operations will require elevated privilege
    <LineBreak />
            Do you want to run this script as an Administrator?<LineBreak />
            <LineBreak />
             - Select `"Yes`" to Run as an Administrator<LineBreak />
             - Select `"No`" to not run this as an Administrator<LineBreak />
             - Select `"Cancel`" to stop the script.<LineBreak />
"


    $ErrorMsgParams = @{
        Title = "Error"
        TitleBackground = "Yellow"
        TitleTextForeground = "Red"
        TitleFontWeight = "UltraBold"
        TitleFontSize = 20
        ButtonType = "Yes-No-Cancel"
    }



    if($Script:TEST_MODE -eq $False){
        If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
            Show-MessageBox @ErrorMsgParams -Content $Text
            $Prompt = Get-Variable -Name PWSHMessageBoxOutput -ValueOnly 
            Switch ($Prompt) {
                #This will debloat Windows 10
                Yes {
                    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
                    Start-Process "$Script:PwshExe" -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
                    Exit
                }
                No {
                    Break
                }
            }
        }
    }    
}



function Invoke-AutomaticConfig{

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Set-WellKnownPaths"
    Set-WellKnownPaths

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "New-PowerShellDirectoryStructure"
    New-PowerShellDirectoryStructure

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Set-RegistryOrganizationHKCU"
    Set-RegistryOrganizationHKCU

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Save-PowerShellModuleBuilder"
    Save-PowerShellModuleBuilder

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Save-PowerShellDevelopmentModules"
    Save-PowerShellDevelopmentModules

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Set-ModulesEnvironmwntVariables"
    Set-ModulesEnvironmwntVariables
    Show-ModuleVariablesInfo

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Save-PowerShellDevelopmentModules"
    Save-PowerShellProfile

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Invoke-RefreshEnvironmentVariables"
    Invoke-RefreshEnvironmentVariables

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Invoke-ModuleShimInit"
    Invoke-ModuleShimInit

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Invoke-ModuleShimMenuSetup"
    Invoke-ModuleShimMenuSetup

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Invoke-ModuleDownloaderSetup"
    Invoke-ModuleDownloaderSetup

    Write-Host -n -f DarkRed "[SysConfig] " ; Write-Host -f DarkYellow "Invoke-RefreshEnvironmentVariables"
    Invoke-RefreshEnvironmentVariables
}

