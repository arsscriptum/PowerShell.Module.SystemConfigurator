<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜 
#̷𝓍   SystemConfig
#̷𝓍   
#̷𝓍   <guillaumeplante.qc@gmail.com>
#̷𝓍   https://arsscriptum.github.io/
#>


function New-PowerShellDirectoryStructure {

    [CmdletBinding(SupportsShouldProcess)]
    param
    ()

    Write-Title "CreatePowerShellDirectoryStructure"

    $Script:POWERSHELL_PATH         = Join-Path "$Script:MYDOCUMENTS_PATH" "PowerShell"
    $Script:PS_MODULES_PATH         = Join-Path "$Script:POWERSHELL_PATH" "Modules"
    $Script:PS_MODDEV_PATH          = Join-Path "$Script:POWERSHELL_PATH" "Module-Development"
    $Script:PS_PROFILE_PATH         = Join-Path "$Script:POWERSHELL_PATH" "Profile"
    $Script:PS_PROJECTS_PATH        = Join-Path "$Script:POWERSHELL_PATH" "Projects"

    write-smsg "MY DOCUMENTS:      $Script:MYDOCUMENTS_PATH"
    write-smsg "PowerShell Home:   $Script:POWERSHELL_PATH"
    write-smsg "Modules:           $Script:PS_MODULES_PATH"
    write-smsg "Modules Dev:       $Script:PS_MODDEV_PATH"
    write-smsg "Projects:          $Script:PS_PROJECTS_PATH"
    write-smsg "Profile:           $Script:PS_PROFILE_PATH"

    $Text = "These are the current paths:<LineBreak />
    <Bold>MY DOCUMENTS.......: $Script:MYDOCUMENTS_PATH </Bold> <LineBreak />
    PowerShell Home....: $Script:POWERSHELL_PATH <LineBreak />
    Modules............: $Script:PS_MODULES_PATH <LineBreak />
    Modules Dev........: $Script:PS_MODDEV_PATH <LineBreak />
    Projects...........: $Script:PS_PROJECTS_PATH <LineBreak />
    Profile............: $Script:PS_PROFILE_PATH <LineBreak />
    <LineBreak />
    They will be created if non existant...
"


    Show-MessageBox @MessageBoxParams -Content $Text
    $Prompt = Get-Variable -Name PWSHMessageBoxOutput -ValueOnly 
    if($Prompt -ne 'Yes') {
        return
    }
                
    New-Item -Path "$Script:POWERSHELL_PATH" -ItemType Directory -Force -ErrorAction Ignore  -WhatIf:$Script:TEST_MODE| Out-Null ; Write-MOk "Created: $Script:POWERSHELL_PATH" ; 
    New-Item -Path "$Script:PS_MODULES_PATH" -ItemType Directory -Force -ErrorAction Ignore  -WhatIf:$Script:TEST_MODE| Out-Null ; Write-MOk "Created: $Script:PS_MODULES_PATH" ; 
    New-Item -Path "$Script:PS_MODDEV_PATH" -ItemType Directory -Force -ErrorAction Ignore  -WhatIf:$Script:TEST_MODE| Out-Null ; Write-MOk "Created: $Script:PS_MODDEV_PATH" ; 
    New-Item -Path "$Script:PS_PROJECTS_PATH" -ItemType Directory -Force -ErrorAction Ignore  -WhatIf:$Script:TEST_MODE| Out-Null ; Write-MOk "Created: $Script:PS_PROJECTS_PATH" ; 
    New-Item -Path "$Script:PS_PROFILE_PATH" -ItemType Directory -Force -ErrorAction Ignore  -WhatIf:$Script:TEST_MODE| Out-Null ; Write-MOk "Created: $Script:PS_PROFILE_PATH" ; 


}


function Set-RegistryOrganizationHKCU {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Position=0,Mandatory=$true)]
        [string]$Identifier
    ) 
  

    Write-Host -n -f DarkRed "[SetRegistryOrganizationHKCU] "
    Write-Host -f DarkYellow " Identifier : $Identifier , current ENV:OrganizationHKCU is $Script:OrganizationHKCU"
    $Script:OrganizationHKCU = "HKCU:\Software\" + "$Identifier"
    $Script:PowerShellConfiguration = "$OrganizationHKCU\PowerShell.Configuration"

    $Exists = Test-Path -Path "$Script:OrganizationHKCU"
    if($Exists -eq $False){
       $Null = New-Item -Path "$Script:OrganizationHKCU" -ItemType Directory -Force -ErrorAction Ignore -WhatIf:$Script:TEST_MODE    
    }
    
    $Exists = Test-Path -Path "$Script:PowerShellConfiguration"
    if($Exists -eq $False){
       $Null = New-Item -Path "$Script:PowerShellConfiguration" -ItemType Directory -Force -ErrorAction Ignore -WhatIf:$Script:TEST_MODE    
    }
    
    if($Script:TEST_MODE -eq $False){
        $ENV:OrganizationHKCU = "$Script:OrganizationHKCU"
        [Environment]::SetEnvironmentVariable('OrganizationHKCU',$Script:OrganizationHKCU,"Process")
        [Environment]::SetEnvironmentVariable('PowerShellConfiguration',$Script:PowerShellConfiguration,"Process")
        [Environment]::SetEnvironmentVariable('OrganizationHKCU',$Script:OrganizationHKCU,"User")
        [Environment]::SetEnvironmentVariable('PowerShellConfiguration',$Script:PowerShellConfiguration,"User")
    }else{
        Write-Host -n -f DarkRed "[WhatIf] "
        Write-Host -f DarkYellow "ENV:OrganizationHKCU = `"$Script:OrganizationHKCU`""
        Write-Host -n -f DarkRed "[WhatIf] "
        Write-Host -f DarkYellow "SetEnvironmentVariable(`"OrganizationHKCU`",$Script:OrganizationHKCU,`"User`")"
    }

    $Script:POWERSHELL_PATH         = Join-Path "$Script:MYDOCUMENTS_PATH" "PowerShell"
    $Script:PS_MODULES_PATH         = Join-Path "$Script:POWERSHELL_PATH" "Modules"
    $Script:PS_MODDEV_PATH          = Join-Path "$Script:POWERSHELL_PATH" "Module-Development"
    $Script:PS_PROFILE_PATH         = Join-Path "$Script:POWERSHELL_PATH" "Profile"
    $Script:PS_PROJECTS_PATH        = Join-Path "$Script:POWERSHELL_PATH" "Projects"    

    write-smsg "$Script:PowerShellConfiguration PowerShellPath $Script:POWERSHELL_PATH"
    New-ItemProperty -Path "$Script:PowerShellConfiguration" -Name 'PowerShellPath' -Value "$Script:POWERSHELL_PATH" -Type ExpandString -Force -WhatIf:$Script:TEST_MODE  | Out-Null

    write-smsg "$Script:PowerShellConfiguration ModulePath $Script:PS_MODULES_PATH"
    New-ItemProperty -Path "$Script:PowerShellConfiguration" -Name 'ModulePath' -Value "$Script:PS_MODULES_PATH" -Type ExpandString -Force -WhatIf:$Script:TEST_MODE  | Out-Null

    write-smsg "$Script:PowerShellConfiguration ModuleDevelopmentPath $Script:PS_MODDEV_PATH"
    New-ItemProperty -Path "$Script:PowerShellConfiguration" -Name 'ModuleDevelopmentPath' -Value "$Script:PS_MODDEV_PATH" -Type ExpandString -Force -WhatIf:$Script:TEST_MODE  | Out-Null

    write-smsg "$Script:PowerShellConfiguration ProjectsPath $Script:PS_PROJECTS_PATH"
    New-ItemProperty -Path "$Script:PowerShellConfiguration" -Name 'ProjectsPath' -Value "$Script:PS_PROJECTS_PATH" -Type ExpandString -Force -WhatIf:$Script:TEST_MODE  | Out-Null

    write-smsg "$Script:PowerShellConfiguration ProfilePath $Script:PS_PROFILE_PATH"
    New-ItemProperty -Path "$Script:PowerShellConfiguration" -Name 'ProfilePath' -Value "$Script:PS_PROFILE_PATH" -Type ExpandString -Force -WhatIf:$Script:TEST_MODE  | Out-Null

}


function Check-ValidateBeforeStart {

    [CmdletBinding(SupportsShouldProcess)]
    param
    ()
    if(-not(Test-Path -Path $Script:DEV_ROOT))              { write-serr "NOT EXISTING: $Script:DEVDRIVE" ; return $false;}
    if(-not(Test-Path -Path $Script:REG_USER_ENV))          { write-serr "NOT EXISTING: $Script:REG_USER_ENV"; return $false; }
    if(-not(Test-Path -Path $Script:REG_GLOBAL_ENV))        { write-serr "NOT EXISTING: $Script:REG_GLOBAL_ENV" ; return $false;}
    if(-not(Test-Path -Path $Script:OrganizationHKCUScript)){ write-serr "NOT EXISTING: $Script:OrganizationHKCUScript" ; return $false;}

    if(-not(Test-Path -Path $Script:WINGIT_SCRIPT_PATH))    { write-serr "NOT EXISTING: $Script:WINGIT_SCRIPT_PATH" ; return $false;}
    if(-not(Test-Path -Path $Script:CONFIGURE_SCRIPT_PATH)) { write-serr "NOT EXISTING: $Script:CONFIGURE_SCRIPT_PATH" ; return $false;}

    return $true;

}


function Import-SystemEnvironmentValues {

    [CmdletBinding(SupportsShouldProcess)]
    param
    ()

    $RegExe = (get-command 'reg.exe').Source

    if($Script:TEST_MODE -eq $False){
        &"$RegExe" "import" "$Script:REG_GLOBAL_ENV"
        write-smsg "Registry Import $Script:REG_GLOBAL_ENV"
        
        &"$RegExe" "import" "$Script:REG_USER_ENV"
        write-smsg "Registry Import $Script:REG_USER_ENV"
    }else{
        write-smsg "WhatIf : Registry Import $Script:REG_GLOBAL_ENV"
        write-smsg "WhatIf : Registry Import $Script:REG_USER_ENV"
    }
}

function Set-WellKnownPaths {

    [CmdletBinding(SupportsShouldProcess)]
    param()
    Write-Title "WELL KNOWN PATHS (DOCUMENTS, PICTURES, ETC)" 


    $Script:DATA_DRIVE  = $Script:ListBox01.SelectedItem
    write-smsg "Selected Root Drive is $Script:DATA_DRIVE"
    $Script:PROGRAMS_PATH           = Join-Path "$Script:DATA_DRIVE" "Programs"
    $Script:MYDOCUMENTS_PATH        = Join-Path "$Script:DATA_DRIVE" "DOCUMENTS"
    $Script:MYPICTURES_PATH         = Join-Path "$Script:DATA_DRIVE" "Data\Pictures"
    $Script:MYVIDEOS_PATH           = Join-Path "$Script:DATA_DRIVE" "Data\Videos"
    $Script:SCREENSHOTS_PATH        = Join-Path "$Script:DATA_DRIVE" "Data\Pictures\Screenshots"
    $Script:DOWNLOAD_PATH           = Join-Path "$Script:DATA_DRIVE" "Data\Downloads"
    $Script:DESKTOP_PATH            = Join-Path "$Script:DATA_DRIVE" "Data\Windows\Desktop"

    write-smsg "Desktop:         $Script:DESKTOP_PATH"
    write-smsg "Pictures:        $Script:MYPICTURES_PATH"
    write-smsg "Screenshots:     $Script:SCREENSHOTS_PATH"
    write-smsg "Download:        $Script:DOWNLOAD_PATH"
    write-smsg "Documents:       $Script:MYDOCUMENTS_PATH"
    write-smsg "Videos:          $Script:MYVIDEOS_PATH"
 

    $Text = "These are the current paths:<LineBreak /><LineBreak />
    <Bold>* My Documents..: $Script:MYDOCUMENTS_PATH </Bold> <LineBreak /> (PowerShell Paths are based on this) <LineBreak />
     Desktop........: $Script:DESKTOP_PATH<LineBreak />
     Pictures.......: $Script:MYPICTURES_PATH <LineBreak />
     Screenshots....: $Script:SCREENSHOTS_PATH <LineBreak />
     Download.......: $Script:DOWNLOAD_PATH <LineBreak />
     Videos.........: $Script:MYVIDEOS_PATH <LineBreak />
    <LineBreak />
    They will be created if non existant...
"

    Show-MessageBox @MessageBoxParams -Content $Text
    $Prompt = Get-Variable -Name PWSHMessageBoxOutput -ValueOnly 
    if($Prompt -ne 'Yes') {
        return
    }
     
    New-Item -Path "$Script:DESKTOP_PATH" -ItemType Directory -Force -ErrorAction Ignore -WhatIf:$Script:TEST_MODE | Out-Null
    New-Item -Path "$Script:MYPICTURES_PATH" -ItemType Directory -Force -ErrorAction Ignore  -WhatIf:$Script:TEST_MODE | Out-Null
    New-Item -Path "$Script:SCREENSHOTS_PATH" -ItemType Directory -Force -ErrorAction Ignore  -WhatIf:$Script:TEST_MODE | Out-Null
    New-Item -Path "$Script:DOWNLOAD_PATH" -ItemType Directory -Force -ErrorAction Ignore  -WhatIf:$Script:TEST_MODE | Out-Null
    New-Item -Path "$Script:MYDOCUMENTS_PATH" -ItemType Directory -Force -ErrorAction Ignore -WhatIf:$Script:TEST_MODE  | Out-Null
    New-Item -Path "$Script:MYVIDEOS_PATH" -ItemType Directory -Force -ErrorAction Ignore -WhatIf:$Script:TEST_MODE  | Out-Null
    New-Item -Path "$Script:POWERSHELL_PATH" -ItemType Directory -Force -ErrorAction Ignore -WhatIf:$Script:TEST_MODE  | Out-Null
    $RegPathShellFolders = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders'
        
    New-ItemProperty "$RegPathShellFolders" Personal -Value "$Script:MYDOCUMENTS_PATH" -Type ExpandString -Force -WhatIf:$Script:TEST_MODE  | Out-Null
    Set-ItemProperty "$RegPathShellFolders" Desktop -Value "$Script:DESKTOP_PATH" -Type ExpandString -Force -WhatIf:$Script:TEST_MODE  | Out-Null
    Set-ItemProperty "$RegPathShellFolders" 'My Pictures' -Value "$Script:MYPICTURES_PATH" -Type ExpandString -Force -WhatIf:$Script:TEST_MODE  | Out-Null
    Set-ItemProperty "$RegPathShellFolders" 'My Video' -Value "$Script:MYVIDEOS_PATH" -Type ExpandString -Force -WhatIf:$Script:TEST_MODE  | Out-Null
         
    $RegPathShellFolders = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
        
    New-ItemProperty "$RegPathShellFolders" Personal -Value "$Script:MYDOCUMENTS_PATH" -Type ExpandString -Force  -WhatIf:$Script:TEST_MODE | Out-Null
    Set-ItemProperty "$RegPathShellFolders" Desktop -Value "$Script:DESKTOP_PATH" -Type ExpandString -Force -WhatIf:$Script:TEST_MODE  | Out-Null
    Set-ItemProperty "$RegPathShellFolders" 'My Pictures' -Value "$Script:MYPICTURES_PATH" -Type ExpandString -Force -WhatIf:$Script:TEST_MODE  | Out-Null
    Set-ItemProperty "$RegPathShellFolders" 'My Video' -Value "$Script:MYVIDEOS_PATH" -Type ExpandString -Force  -WhatIf:$Script:TEST_MODE | Out-Null

    New-Item -Path "$Script:POWERSHELL_PATH" -ItemType Directory -Force -ErrorAction Ignore  -WhatIf:$Script:TEST_MODE| Out-Null ; Write-MOk "Created: $Script:POWERSHELL_PATH" ; 
    New-Item -Path "$Script:PS_MODULES_PATH" -ItemType Directory -Force -ErrorAction Ignore  -WhatIf:$Script:TEST_MODE| Out-Null ; Write-MOk "Created: $Script:PS_MODULES_PATH" ; 
    New-Item -Path "$Script:PS_MODDEV_PATH" -ItemType Directory -Force -ErrorAction Ignore  -WhatIf:$Script:TEST_MODE| Out-Null ; Write-MOk "Created: $Script:PS_MODDEV_PATH" ; 
    New-Item -Path "$Script:PS_PROJECTS_PATH" -ItemType Directory -Force -ErrorAction Ignore  -WhatIf:$Script:TEST_MODE| Out-Null ; Write-MOk "Created: $Script:PS_PROJECTS_PATH" ; 
    New-Item -Path "$Script:PS_PROFILE_PATH" -ItemType Directory -Force -ErrorAction Ignore  -WhatIf:$Script:TEST_MODE| Out-Null ; Write-MOk "Created: $Script:PS_PROFILE_PATH" ; 

    Set-EnvironmentVariable -Name 'MyPictures' -Value "$Script:MYPICTURES_PATH" -Scope 'User'
    Set-EnvironmentVariable -Name 'MyVideos' -Value "$Script:MYVIDEOS_PATH" -Scope 'User'
    Set-EnvironmentVariable -Name 'DESKTOP' -Value "$Script:DESKTOP_PATH" -Scope 'User'
    Set-EnvironmentVariable -Name 'MyDocuments' -Value "$Script:MYDOCUMENTS_PATH" -Scope 'User'
    Set-EnvironmentVariable -Name 'MyDocuments' -Value "$Script:MYDOCUMENTS_PATH" -Scope 'User'
    Set-EnvironmentVariable -Name 'SCREENSHOTS' -Value "$Script:SCREENSHOTS_PATH" -Scope 'User'
    Set-EnvironmentVariable -Name 'POWERSHELL' -Value "$Script:POWERSHELL_PATH" -Scope 'User'
}

function Get-RepoUrl {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )

    $Url = "git@github.com:arsscriptum/$Name" + ".git" 
    return $Url
}

function Save-PowerShellModuleBuilder {

    [CmdletBinding(SupportsShouldProcess)]
    param
    ()

    pushd "$Script:PS_MODDEV_PATH"
    $CmdData = Get-Command "git.exe"
    if($CmdData){$GitExe = $CmdData.Source}

    $BuilderUrl = Script:GetRepoUrl -Name 'PowerShell.ModuleBuilder'
    
    pushd "$Script:PS_PROJECTS_PATH"
    write-smsg "clone: $BuilderUrl"
    &"$GitExe" "clone" "$BuilderUrl"
    pushd 'PowerShell.ModuleBuilder\setup'
    $stp = Join-Path ($PWD).Path 'Setup.ps1'
    . "$stp"
    popd
}


function Save-PowerShellDevelopmentModules {

    [CmdletBinding(SupportsShouldProcess)]
    param
    ()

    pushd "$Script:PS_MODDEV_PATH"
    $CmdData = Get-Command "git.exe"
    if($CmdData){$GitExe = $CmdData.Source}

    $BuilderUrl = Script:GetRepoUrl -Name 'PowerShell.ModuleBuilder'
    
    $Modules = @('PowerShell.Module.Core','PowerShell.Module.WindowsHost','PowerShell.Module.TakeOwnership','PowerShell.Module.Github','PowerShell.Module.Reddit','PowerShell.Module.Credentials','PowerShell.Module.Cryptography','PowerShell.Module.Shim','PowerShell.Module.NtRights','PowerShell.Module.Downloader','PowerShell.Module.SetAcl','PowerShell.Module.FedEx','PowerShell.Module.Compiler','PowerShell.Module.Terminal','PowerShell.Module.AttackSuite','PowerShell.Module.HtmlReport','PowerShell.Module.Certificate')
    ForEach($mod in $Modules){
        $RepoUrl = Script:GetRepoUrl -Name $mod
        write-smsg "clone: $RepoUrl"
        &"$GitExe" "clone" "$RepoUrl"    
    }

    popd

    pushd "$Script:PS_PROJECTS_PATH"
    write-smsg "clone: $BuilderUrl"
    &"$GitExe" "clone" "$BuilderUrl"
    pushd 'PowerShell.ModuleBuilder\setup'
    $stp = Join-Path ($PWD).Path 'Setup.ps1'
    . "$stp"
    popd
    popd
}

function Save-PowerShellProfile {

    [CmdletBinding(SupportsShouldProcess)]
    param
    ()

    if($Script:TEST_MODE -eq $True){
        return
    }

    $CmdData = Get-Command "git.exe"
    if($CmdData){$GitExe = $CmdData.Source}
    $NewDir = ((New-TemporaryDirectory).Fullname)
    pushd $NewDir
    
    write-smsg "Cloning PowerShell.Profile"
    
    $ProfileUrl = Script:GetRepoUrl -Name 'PowerShell.Profile'
    &"$GitExe" "clone" "$ProfileUrl"

    $ok = Test-Path -Path 'PowerShell.Profile'
    
    if($ok){
        pushd 'PowerShell.Profile'
        write-smsg "COPY Microsoft.PowerShell_profile.ps1 --> to $Script:POWERSHELL_PATH"
        Copy-Item "Microsoft.PowerShell_profile.ps1" "$Script:POWERSHELL_PATH" -WhatIf:$Script:TEST_MODE 
        popd
        $Null=Remove-Item -Path "$Script:POWERSHELL_PATH\Profile" -Recurse -Force -ErrorAction Ignore -WhatIf:$Script:TEST_MODE 
        Copy-Item "PowerShell.Profile" "$Script:POWERSHELL_PATH\Profile" -Recurse -WhatIf:$Script:TEST_MODE 
    }
}


function Invoke-RefreshEnvironmentVariables {

    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    $Cmds = @('RefreshEnv.cmd','RefreshEnvironment.exe')
    ForEach($cmd in $Cmds){
        $CmdData = Get-Command "$cmd"
        if($CmdData){
            $RefreshEnv = $CmdData.Source
            Write-Title "Refreshing Environment Variables using $RefreshEnv"
            $Text = "Refresh Environment Variables using:<LineBreak /><LineBreak />
        <Bold>$RefreshEnv</Bold><LineBreak />
        <LineBreak />
"
            Show-MessageBox @MessageBoxParams -Content $Text
            &"$RefreshEnv"
        }
    } 
}


function Invoke-ModuleBuilderSetup{
    [CmdletBinding(SupportsShouldProcess)]
    param()

    $ProfilePath = (Get-Item $Profile).DirectoryName
    $ProjectsPath = Join-Path $ProfilePath "Projects"
    $SetupPath = Join-Path $ProjectsPath "PowerShell.ModuleBuilder\setup"
    Push-Location $SetupPath
    . "./Setup.ps1"
    Pop-Location

    $RegEdExe = (Get-Command "regedit.exe").Source ; 
    Invoke-Command -ScriptBlock { &"$RegEdExe" } ;
}

function Invoke-ModuleDownloaderSetup{
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    $ProfilePath = (Get-Item $Profile).DirectoryName
    $ProjectsPath = Join-Path $ProfilePath "Module-Development"
    $SetupPath = Join-Path $ProjectsPath "PowerShell.Module.Downloader\setup"
    Push-Location $SetupPath
    . "./Setup.ps1" -Quiet
    Pop-Location
}


function Invoke-ModuleShimInit{
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    $ProfilePath = (Get-Item $Profile).DirectoryName
    $ProjectsPath = Join-Path $ProfilePath "Module-Development"
    $SetupPath = Join-Path $ProjectsPath "PowerShell.Module.Shim"
    Push-Location $SetupPath
    "make -i -d"
    Pop-Location
}


function Invoke-ModuleShimMenuSetup{
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    $ProfilePath = (Get-Item $Profile).DirectoryName
    $ProjectsPath = Join-Path $ProfilePath "Module-Development"
    $SetupPath = Join-Path $ProjectsPath "PowerShell.Module.Shim\setup"
    Push-Location $SetupPath
    . "./Install-Menu.ps1" -Quiet
    Pop-Location

    Initialize-ShimModule -Path 'C:\Programs\Shims\' -ShimGenPath 'C:\ProgramData\chocolatey\tools\shimgen.exe' -AddToPath
}

