

function Script:Install-WindowsGit {

    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory=$true,Position=0)]    
        [string]$Url,
        [Parameter(Mandatory=$true,Position=1)]    
        [string]$InstallPath
    )
    $Installed =  Test-GitInstalled
    if($Installed) {write-slog "Windows Git already installed..." ; return ; } 
    write-slog "Installing Windows Git from $Url to $InstallPath"

    $LocalInstaller = Join-Path "$ENV:Temp" "Git.exe"
    Get-OnlineFileNoCache -Url "$Url" -Path $LocalInstaller
    if(-not(Test-Path $LocalInstaller)){
        throw "Failed to get Git installer"
    }

    write-slog "$LocalInstaller /NORESTART /SUPPRESSMSGBOXES /VERYSILENT /SP /ALLUSERS /NOCANCEL /NOCLOSEAPPLICATIONS /DIR=$InstallPath"
    
    # Args: https://jrsoftware.org/ishelp/index.php?topic=setupcmdline
    &"$LocalInstaller" "/NORESTART" "/SUPPRESSMSGBOXES" "/VERYSILENT" "/SP" "/ALLUSERS" "/NOCANCEL" "/NOCLOSEAPPLICATIONS" "/DIR=`"$InstallPath`""
}



function Script:Test-GitInstalled {
    [CmdletBinding()]
    param()

    $checkPath = 'c:\Programs\Git'

    if ($Command = Get-Command 'git.exe' -CommandType Application -ErrorAction Ignore) {
        Write-Verbose "git is on the PATH, assume it's installed"
        $true
    }
    elseif (-not (Test-Path $checkPath)) {
        Write-Verbose "Install folder doesn't exist"
        $false
    }
    elseif (-not (Get-ChildItem -Path $checkPath)) {
        Write-Verbose "Install folder exists but is empty"
        $false
    }
    else {
        Write-Verbose "Install folder exists and is not empty"

        $checkFiles = @('c:\Programs\Git\git-bash.exe', 'c:\Programs\Git\git-cmd.exe', 'c:\Programs\Git\bin\git.exe', 'c:\Programs\Git\bin\sh.exe', 'c:\Programs\Git\bin\bash.exe')
        
        ForEach($theFile in $checkFiles){
            if (-not (Test-Path $theFile)) {
                Write-Verbose "$theFile missing"
                return $false
            }
        }
        $true
    }
}

function Script:Wait-GitInstalled {

    [CmdletBinding(SupportsShouldProcess)]
    param
    ()
    
    $GitInstalled = $false

    While($GitInstalled -eq $False){
        Sleep -Seconds 5
        Write-Verbose "Checking if Git is Installed....."
        $GitInstalled = Test-GitInstalled
    }

    Write-Verbose "Git is Installed"
}



function Script:Invoke-InstallWindowsGit {

    [CmdletBinding(SupportsShouldProcess)]
    param
    ()

    Write-Host "======================================================"
    Write-Host "INSTALL WIN GIT"
    Write-Host "======================================================"

    Write-Host "GIT Install Url :   $Script:GIT_WINDOWS_64_URL"
    Write-Host "Git Install Path:   $Script:WIN_GIT_INSTALL_PATH"

    $confirm = Read-Host -Prompt 'Install Windows Git ? (y/n)'
    if ($confirm -ne 'y') {
         Write-Host -n -f DarkRed "[!] "
        Write-Host -f DarkYellow " Exit. "
        return
    }
    Install-WindowsGit -Url "$Script:GIT_WINDOWS_64_URL" -InstallPath "$Script:WIN_GIT_INSTALL_PATH"
}




function Script:Invoke-GitClone {

    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory=$true,Position=0)]     
        [string]$Repo,
        [Parameter(Mandatory=$false)]     
        [string]$Name
    )

    $GitExe = (get-command 'git.exe').Source

    if ($PSBoundParameters.ContainsKey('Name')) {
        Write-Host '[GIT] ' -f DarkRed -NoNewLine
        Write-Host "clone $Repo.git" -f Yellow            
        &"$GitExe" "clone" "https://$Script:GITHUB_AUTH_USER:$Script:GITHUB_AUTH_TOKEN@github.com/$Script:GITHUB_AUTH_USER/$Repo.git" "$Name"
    }else{
        &"$GitExe" "clone" "https://$Script:GITHUB_AUTH_USER:$Script:GITHUB_AUTH_TOKEN@github.com/$Script:GITHUB_AUTH_USER/$Repo.git"    
    }  
    
    
}


function Script:Set-GitUSerData {

    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory=$true,Position=0)]     
        [string]$Email,
        [Parameter(Mandatory=$true,Position=1)]     
        [string]$Name
    )

    $GitExe = (get-command 'git.exe').Source

    if ($Script:TEST_MODE) {
        Write-Host '[GIT WhatIf] ' -f Blue -NoNewLine ; Write-Host "git config --global user.name `"$Name`"" -f Gray            
        Write-Host '[GIT WhatIf] ' -f Blue -NoNewLine ; Write-Host "git config --global user.email `"$Email`"" -f Gray            
    }else{
        Write-Host '[GIT] ' -f DarkRed -NoNewLine ; Write-Host "config --global user.name `"$Name`"" -f Yellow            
        Write-Host '[GIT] ' -f DarkRed -NoNewLine ; Write-Host "config --global user.email `"$Email`"" -f Yellow               
        &"$GitExe" "config" "--global" "user.name" "`"$Name`""
        &"$GitExe" "config" "--global" "user.email" "`"$Email`""
    }  
    
}


function Script:Get-GithubAccessToken {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-GithubModuleRegistryPath
    $TokenPresent = Test-RegistryValue -Path "$RegPath" -Entry 'default_access_token'
    if( $TokenPresent -eq $true ) {
        $Token = Get-RegistryValue -Path "$RegPath" -Entry 'default_access_token'
        return $Token
    }
    if( $Env:REDDIT_ACCESSTOKEN -ne $null ) { return $Env:REDDIT_ACCESSTOKEN  }
    return $null
}
<#
    GithubDefaultUsername
    New-ItemProperty -Path "$ENV:OrganizationHKCU\github.com" -Name 'default_username' -Value 'codecastor'
 #>
function Script:Get-GithubDefaultUsername {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-GithubModuleRegistryPath
    $User = (Get-ItemProperty -Path "$RegPath" -Name 'default_username' -ErrorAction Ignore).default_username
    if( $User -ne $null ) { return $User  }
    if( $Env:DEFAULT_GIT_USERNAME -ne $null ) { return $Env:DEFAULT_GIT_USERNAME ; }    
    if( $Env:USERNAME -ne $null ) { return $Env:USERNAME ; }
    return $null
}

<#
    GithubDefaultUsername
    New-ItemProperty -Path "$ENV:OrganizationHKCU\github.com" -Name 'default_clone_path' -Value 'P:\Github-Repositories'
 #>
function Script:Get-GithubDefaultClonePath {
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $RegPath = Get-GithubModuleRegistryPath
    $User = (Get-ItemProperty -Path "$RegPath" -Name 'default_clone_path' -ErrorAction Ignore).default_clone_path
    if( $User -ne $null ) { return $User  }
    if( $Env:GITHUB_DEFAULT_DOWNLOAD_PATH -ne $null ) { return $Env:GITHUB_DEFAULT_CLONE_PATH ; }
    if( $Env:DefaultGithubRepositoryPath -ne $null ) { return $Env:GithubDefaultClonePath ; }
    return $null
}


function Script:Get-GitExecutablePath{
    [CmdletBinding(SupportsShouldProcess)]
    param ()
    $GitPath = (get-command "git.exe" -ErrorAction Ignore).Source
     
     if(( $GitPath -ne $null ) -And (Test-Path -Path $GitPath)){
        return $GitPath
     }
     $GitPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\GitForWindows" -Name 'InstallPath' -ErrorAction Ignore).InstallPath
     if( $GitPath -ne $null ) { $GitPath = $GitPath + '\bin\git.exe' }
     if(Test-Path -Path $GitPath){
        return $GitPath
     }
     $GitPath = (Get-ItemProperty -Path "$ENV:OrganizationHKCU\Git" -Name 'InstallPath' -ErrorAction Ignore).InstallPath
     if( $GitPath -ne $null ) { $GitPath = $GitPath + '\bin\git.exe' }
     if(( $GitPath -ne $null ) -And (Test-Path -Path $GitPath)){
        return $GitPath
     }
}
