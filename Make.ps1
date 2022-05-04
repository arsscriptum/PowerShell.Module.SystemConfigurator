<#
#̷𝓍   𝓐𝓡𝓢 𝓢𝓒𝓡𝓘𝓟𝓣𝓤𝓜
#̷𝓍   🇵​​​​​🇴​​​​​🇼​​​​​🇪​​​​​🇷​​​​​🇸​​​​​🇭​​​​​🇪​​​​​🇱​​​​​🇱​​​​​ 🇸​​​​​🇨​​​​​🇷​​​​​🇮​​​​​🇵​​​​​🇹​​​​​ 🇧​​​​​🇾​​​​​ 🇬​​​​​🇺​​​​​🇮​​​​​🇱​​​​​🇱​​​​​🇦​​​​​🇺​​​​​🇲​​​​​🇪​​​​​🇵​​​​​🇱​​​​​🇦​​​​​🇳​​​​​🇹​​​​​🇪​​​​​.🇶​​​​​🇨​​​​​@🇬​​​​​🇲​​​​​🇦​​​​​🇮​​​​​🇱​​​​​.🇨​​​​​🇴​​​​​🇲​​​​​
#>


<#
.SYNOPSIS
    A Powershell script to make this module package.
#>


#===============================================================================
# Commandlet Binding
#===============================================================================
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$false,ValueFromPipeline=$true, 
        HelpMessage="Build from scratch, get all the files from the internet") ]
    [switch]$Clean
)


#Requires -Version 5



function Remove-CommentsFromScriptBlock {

    [CmdletBinding()] 
    param(
        [String]$ScriptBlock
    )
    $IsOneLineComment = $False
    $IsComment = $False
    $Output = ""
    $NoCommentException = $False

    $Arr=$ScriptBlock.Split("`n")
    ForEach ($Line in $Arr) 
    {
        if ($Line -match "###NCX") { ###NCX
            $NoCommentException = $True
        }

        if ($Line -like "*<#*") {   ###NCX
            $IsComment = $True
        }

        if ($Line -like "#*") {     ###NCX
            $IsOneLineComment = $True
        }

        if($NoCommentException){
            $Output += "$Line`n"
        }
        elseif (-not $IsComment -And -not $IsOneLineComment) {
            $Output += "$Line`n"
        }

        $IsOneLineComment = $False

        if ($Line -like "*#>*") {   ###NCX
            $IsComment = $False
        }
    }

    return $Output
}


function Compare-ModulePathAgainstPermission{

    $VarModPath=$env:PSModulePath
    $Paths=$VarModPath.Split(';')

    # 1 -> Retrieve my appartenance (My Groups)
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $groups = $id.Groups | foreach-object {$_.Translate([Security.Principal.NTAccount])}
    $GroupList = @() ; ForEach( $g in $groups){  $GroupList += $g ; }
    Sleep -Milliseconds 500
    # Create Filter (Modify a folder) based on those groups
    $filteracl = {$GroupList.Contains($_.IdentityReference) -and ($_.FileSystemRights.ToString() -match 'Modify')}
    $PathPermissions = @()
    ForEach($dir in $Paths){
        if(-not(Test-Path $dir)){ continue;}
        $i = (Get-Item $dir);
        $PathPermissions += (Get-Acl $i).Access | Where $filteracl  | Select `
                                 @{n="Path";e={$i.fullname}},
                                 @{n="Permission";e={$_.FileSystemRights}}
    }
    return $PathPermissions
}

function Get-UserModulesPath{
    $VarModPath=$env:PSModulePath
    $Paths=$VarModPath.Split(';')
    $PathList = @() ; ForEach( $p in $Paths){  $PathList += $p ; }
    $P1 = Join-Path (Get-Item $Profile).DirectoryName 'Modules'
    if($PathList.Contains($P1) -eq $True){
        return $P1
    }
    $PossiblePaths = Compare-ModulePathAgainstPermission
    if($PossiblePaths.Count -gt 0){
        return $PossiblePaths[0].Path
    }
    return $null
}

function Get-GitRevision {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Repository Path")]
        [Alias('p')] [string] $Path,        
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="Long revision format")]
        [Alias('l')] [switch] $Long,
        [Parameter(Mandatory=$false, ValueFromPipeline=$true, HelpMessage="No logs, clean output")]
        [Alias('r')] [switch] $Raw        
    )
    try{
        $TmpFile = (New-TemporaryFile).Fullname
        $ShowMessages = $True
        If( $PSBoundParameters.ContainsKey('Raw') -eq $True ){ $ShowMessages = $False }
        $CurrentPath = (Get-Location).Path
        If( $PSBoundParameters.ContainsKey('Path') -eq $True ){
            if(-not(Test-Path -Path $Path -PathType Container)){ throw "Could not locate Path $Path" ; return ''}
            Write-Verbose "Fetching Git Revision from $Path"
        }else{
            # Just so that I can popd at the end withou checking argument
            $Path = $CurrentPath
        }
        pushd $Path
        $Revision = ''  
        if($ShowMessages){
            Write-ChannelMessage "Retrieving git revision for $Path"
        }
        If( $PSBoundParameters.ContainsKey('Long') -eq $True ){
            $Revision = git rev-parse HEAD 2> $TmpFile
        }else{
            $Revision = git rev-parse --short HEAD 2> $TmpFile
        }
        if($?){
            if($ShowMessages){
                Write-ChannelResult " Success. Revision: $Revision"
            }          
        }else{
            $ErrorStr = Get-Content $TmpFile -Raw
            throw "ERROR WHILE FETCHING GIT REVISION in $Path ==> $ErrorStr"
            $Revision = ''
        }
        return $Revision
    } catch {
        Write-Error($_)
    }finally{
        popd
    }
}

function Convert-ToBase64CompressedScriptBlock {

    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory=$true,Position=0)]
        $ScriptBlock
    )

    # Script block as String to Byte array
    [System.Text.Encoding] $Encoding = [System.Text.Encoding]::UTF8
    [Byte[]] $ScriptBlockEncoded = $Encoding.GetBytes($ScriptBlock)

    # Compress Byte array (gzip)
    [System.IO.MemoryStream] $MemoryStream = New-Object System.IO.MemoryStream
    $GzipStream = New-Object System.IO.Compression.GzipStream $MemoryStream, ([System.IO.Compression.CompressionMode]::Compress)
    $GzipStream.Write($ScriptBlockEncoded, 0, $ScriptBlockEncoded.Length)
    $GzipStream.Close()
    $MemoryStream.Close()
    $ScriptBlockCompressed = $MemoryStream.ToArray()

    # Byte array to Base64
    [System.Convert]::ToBase64String($ScriptBlockCompressed)
}

function Get-OnlineFileNoCache{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Url,
        [Parameter(Mandatory=$false)]
        [string]$Path,
        [Parameter(Mandatory=$false)]
        [string]$ProxyAddress,
        [Parameter(Mandatory=$false)]
        [string]$ProxyUser,
        [Parameter(Mandatory=$false)]
        [string]$ProxyPassword,
        [Parameter(Mandatory=$false)]
        [string]$UserAgent=""
    )

    if( -not ($PSBoundParameters.ContainsKey('Path') )){
        $Path = (Get-Location).Path
        [Uri]$Val = $Url;
        $Name = $Val.Segments[$Val.Segments.Length-1]
        $Path = Join-Path $Path $Name
        Write-Warning ("NetGetFileNoCache using path $Path")
    }
    $ForceNoCache=$True

    $client = New-Object Net.WebClient
    if( $PSBoundParameters.ContainsKey('ProxyAddress') ){
        Write-Warning ("NetGetFileNoCache''s -ProxyAddress parameter is not tested.")
        $proxy = New-object System.Net.WebProxy "$ProxyAddress"
        $proxy.Credentials = New-Object System.Net.NetworkCredential ($ProxyUser, $ProxyPassword) 
        $client.proxy=$proxy
    }
    
    if($UserAgent -ne ""){
        $Client.Headers.Add("user-agent", "$UserAgent")     
    }else{
        $Client.Headers.Add("user-agent", "Mozilla/5.0 (iPhone; CPU iPhone OS 13_5_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Mobile/15E148 Safari/604.1") 
    }

    $RequestUrl = "$Url"

    if ($ForceNoCache) {
        # doesn’t use the cache at all
        $client.CachePolicy = New-Object Net.Cache.RequestCachePolicy([Net.Cache.RequestCacheLevel]::NoCacheNoStore)

        $RandId=(new-guid).Guid
        $RandId=$RandId -replace "-"
        $RequestUrl = "$Url" + "?id=$RandId"
    }
    Write-Host "NetGetFileNoCache: Requesting $RequestUrl"
    $client.DownloadFile($RequestUrl,$Path)
}

function Add-CodeToModule {

    [CmdletBinding(SupportsShouldProcess)]
    param
    (
        [Parameter(Mandatory=$true,Position=0)]
        $CodePath,
        [Parameter(Mandatory=$false,Position=1)]
        $Id="" 
    )
    $Script:CompilationErrorsCount = 0
    $Script:CompilationLoadTest = $True
    $Script:SourceFilesCount = (Get-ChildItem -Path "$Script:SourcePath" -File -Filter '*.ps1').Count

    [string] $ReturnString = ""
    Get-ChildItem -Path "$CodePath" -File -Filter '*.ps1' | ForEach-Object {
        $Path = $_.fullname
        $Filename = $_.Name
        $Basename = (Get-Item -Path $Path).Basename
        $ScriptName = $Basename

        $BadCharsStr = '-'
        $BadChars = $BadCharsStr.ToCharArray()
        $BadChars | % {
            if($ScriptName -match "$_"){ throw "File name '$ScriptName' contains an invalid character '$_'" }
        }


        try {
            if($Script:CompilationLoadTest){
                try{
                    . $Path
                    Write-Host -ForegroundColor DarkGreen "龱 " -NoNewline
                    Write-Host "script $Filename is OK"    
                }catch [Exception]{
                    Write-Host -ForegroundColor DarkRed "[ERROR] " -NoNewline
                    Write-Host "$_"
                    return
                }
            }


            # Read script block from module file
            [string]$ScriptBlock = Get-Content -Path $Path -Raw

            # Strip out comments
            $ScriptBlock = Remove-CommentsFromScriptBlock -ScriptBlock $ScriptBlock

            # Compress and Base64 encode script block
            $ScriptBlockBase64 = Convert-ToBase64CompressedScriptBlock -ScriptBlock $ScriptBlock

            $ScriptBlockBase64Len = $ScriptBlockBase64.Length


            if($ScriptBlockBase64Len -lt 14000){ 
                Write-Host '龱 ' -f DarkGreen -NoNewLine
                Write-Host "$Basename added to module" -f DarkCyan
                [void] $ScriptList.Add($Basename)


                $ReturnString += "# ------------------------------------`n"
                $ReturnString += "# Script file - $ScriptName -  `n"
                $ReturnString += "# ------------------------------------`n"
                $ReturnString += "`$ScriptBlock$($ScriptName)$Id = `"$($ScriptBlockBase64)`"`n"
                $ReturnString += "`$Null = `$ScriptList.Add(`$ScriptBlock$($ScriptName)$Id)`n`n"
            }else { 
                Write-Host '[WARN] ' -f DarkYellow -NoNewLine
                Write-Host "SKIPPING $Basename for length" -f DarkCyan
            }

        }catch { 
            Write-Error($_)
            $Script:CompilationErrorsCount += 1
        }
    }
    return $ReturnString
}


function Get-Script([string]$prop){
    $ThisFile = $script:MyInvocation.MyCommand.Path
    return ((Get-Item $ThisFile)|select $prop).$prop
}

$ScriptPath = split-path $script:MyInvocation.MyCommand.Path
$ScriptFullName =(Get-Item -Path $script:MyInvocation.MyCommand.Path).DirectoryName

#===============================================================================
# Root Path
#===============================================================================
$Global:ConsoleOutEnabled              = $true
$Global:CurrentRunningScript           = Get-Script basename
$Script:CurrPath                       = $ScriptPath
$Script:RootPath                       = (Get-Location).Path
If( $PSBoundParameters.ContainsKey('Path') -eq $True ){
    $Script:RootPath = $Path
}
If( $PSBoundParameters.ContainsKey('ModuleIdentifier') -eq $True ){
    $Global:ModuleIdentifier = $ModuleIdentifier
}else{
    $Global:ModuleIdentifier = (Get-Item $Script:RootPath).Name
}
#===============================================================================
# Script Variables
#===============================================================================
$Global:CurrentRunningScript           = Get-Script basename
$Script:Time                           = Get-Date
$Script:Date                           = $Time.GetDateTimeFormats()[19]
$Script:IncPath                        = Join-Path $Script:CurrPath "include"
$Script:Header                         = Join-Path $Script:IncPath  "Header.ps1"
$Script:BuilderConfig                  = Join-Path $Script:CurrPath "Config.ps1"
$Script:SourcePath                     = Join-Path $Script:RootPath "src"
$Script:BinariesPath                   = Join-Path $Script:RootPath "bin"
$Script:OutPath                        = Join-Path $Script:RootPath "out"
$Script:TmpPath                        = Join-Path $Script:RootPath "tmp"
$Script:AssembliesPath                 = Join-Path $Script:RootPath "assemblies"
$Script:DocPath                        = Join-Path $Script:RootPath "doc"
$Script:OutputSourcePath               = Join-Path $Script:OutPath  "src"
$Script:OutputBinariesPath             = Join-Path $Script:OutPath  "bin"
$Script:DebugMode                      = $False
$Script:ModuleCoreUrl                  = "https://github.com/arsscriptum/PowerShell.Module.Core/archive/refs/heads/master.zip"
$Script:ModuleGithubUrl                = "https://github.com/arsscriptum/PowerShell.Module.Github/archive/refs/heads/main.zip"
$Script:TmpModuleCore                  = Join-Path $Script:TmpPath "Core.zip"
$Script:TmpModuleGithub                = Join-Path $Script:TmpPath "Github.zip"
$Script:TmpModuleCode                = Join-Path $Script:TmpPath "Module.ps1"
$Script:FileContent                    = (Get-Content -Path $Script:Header -Encoding "windows-1251" -Raw)
$Script:FileContent                    = $FileContent -replace "___BUILDDATE___", $Script:Date
$Script:ScriptList                     = New-Object System.Collections.ArrayList
$Script:Psm1Content                    = "$FileContent`n`n"
$Script:VersionFile                    = Join-Path $Script:RootPath 'Version.nfo'

If( $PSBoundParameters.ContainsKey('RequiresVersion') -eq $True ){
    $Script:Psm1Content  += "#Requires -Version $RequiresVersion`n`n"
}

if($Strict){
    $Script:Psm1Content  += "Set-StrictMode -Version 'Latest'`n`n"
}

Write-Host "`n`n===============================================================================" -f DarkRed
Write-Host "BUILDING  MODULE     `t" -NoNewLine -f DarkYellow ; Write-Host "Systemconfigurator" -f Gray 
Write-Host "MODULE DEVELOPER     `t" -NoNewLine -f DarkYellow;  Write-Host "$ENV:Username" -f Gray 
Write-Host "CurrentRunningScript `t" -NoNewLine -f DarkYellow;  Write-Host "$Global:CurrentRunningScript" -f Gray 
Write-Host "Time                 `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:Time" -f Gray 
Write-Host "Date                 `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:Date" -f Gray 
Write-Host "IncPath              `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:IncPath" -f Gray 
Write-Host "Header               `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:Header" -f Gray 
Write-Host "BuilderConfig        `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:BuilderConfig" -f Gray 
Write-Host "Source               `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:SourcePath" -f Gray 
Write-Host "BinariesPath         `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:BinariesPath" -f Gray 
Write-Host "OutPath              `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:OutPath" -f Gray 
Write-Host "TmpPath              `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:TmpPath" -f Gray 
Write-Host "AssembliesPath       `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:AssembliesPath" -f Gray 
Write-Host "DocPath              `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:DocPath" -f Gray 
Write-Host "OutputSourcePath     `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:OutputSourcePath" -f Gray 
Write-Host "OutputBinariesPath   `t" -NoNewLine -f DarkYellow;  Write-Host "$Script:OutputBinariesPath" -f Gray 
Write-Host "===============================================================================" -f DarkRed     

Remove-Item -Path $Script:TmpPath -Force -Recurse -ErrorAction Ignore | Out-null
New-Item -Path $Script:TmpPath -Force -ItemType Directory -ErrorAction Ignore | Out-null

Write-Host -n -f DarkYellow "[WAIT] "
Write-Host "Downloading $Script:ModuleCoreUrl"
Get-OnlineFileNoCache -Url $Script:ModuleCoreUrl -Path $Script:TmpModuleCore
Expand-Archive  -Path "$Script:TmpModuleCore" -DestinationPath "$Script:TmpPath"

$Script:SourcePath = Join-Path $Script:TmpPath "PowerShell.Module.Core-master\src"
if( -not ( Test-Path $Script:SourcePath) ){
    throw "Error with Core"
}

Write-Host "`n`n===============================================================================" -f DarkRed
Write-Host "COMPILING SCRIPT FILE from $Script:SourcePath" -f DarkYellow;
Write-Host "Total of $Script:SourceFilesCount FILES" -f DarkYellow;
Write-Host "===============================================================================" -f DarkRed

$Psm1Content += "`$ScriptList = [System.Collections.ArrayList]::new() `n`n"


$ReturnString =  Add-CodeToModule $Script:SourcePath
$Psm1Content += $ReturnString



Write-Host -n -f DarkYellow "[WAIT] "
Write-Host "Downloading $Script:ModuleGithubUrl"
Get-OnlineFileNoCache -Url $Script:ModuleGithubUrl -Path $Script:TmpModuleGithub
Expand-Archive  -Path "$Script:TmpModuleGithub" -DestinationPath "$Script:TmpPath"

$Script:SourcePath = Join-Path $Script:TmpPath "PowerShell.Module.Github-main\src"
if( -not ( Test-Path $Script:SourcePath) ){
    throw "Error with Github"
}

Write-Host "`n`n===============================================================================" -f DarkRed
Write-Host "COMPILING SCRIPT FILE from $Script:SourcePath" -f DarkYellow;
Write-Host "Total of $Script:SourceFilesCount FILES" -f DarkYellow;
Write-Host "===============================================================================" -f DarkRed

$ReturnString =  Add-CodeToModule $Script:SourcePath -Id 'Git'
$Psm1Content += $ReturnString

$LoaderBlock = @"
# ------------------------------------`
# Loader
# ------------------------------------
function ConvertFrom-Base64CompressedScriptBlock {

    [CmdletBinding()] param(
        [String]
        `$ScriptBlock
    )

    # Take my B64 string and do a Base64 to Byte array conversion of compressed data
    `$ScriptBlockCompressed = [System.Convert]::FromBase64String(`$ScriptBlock)

    # Then decompress script's data
    `$InputStream = New-Object System.IO.MemoryStream(, `$ScriptBlockCompressed)
    `$GzipStream = New-Object System.IO.Compression.GzipStream `$InputStream, ([System.IO.Compression.CompressionMode]::Decompress)
    `$StreamReader = New-Object System.IO.StreamReader(`$GzipStream)
    `$ScriptBlockDecompressed = `$StreamReader.ReadToEnd()
    # And close the streams
    `$GzipStream.Close()
    `$InputStream.Close()

    `$ScriptBlockDecompressed
}

# For each scripts in the module, decompress and load it.
# Set a flag in the Script Scope so that the scripts know we are loading a module
# so he can have a specific logic
`$Script:LoadingState = `$True

`$Script:LoadingState = `$True

ForEach(`$Script in `$ScriptList){
    `$ClearScript = ConvertFrom-Base64CompressedScriptBlock -ScriptBlock `$Script
    try{
        `$ClearScript | Invoke-Expression
    }catch{
        Write-Host "===============================" -f DarkGray
        Write-Host "`$ClearScript" -f DarkGray
        Write-Host "===============================" -f DarkGray
        Write-Error "ERROR IN script `$ScriptId . Details `$_"
    }    
}
`$Script:LoadingState = `$False


"@

$Psm1Content += "`n`n$($LoaderBlock)`n`n"

# if no error, write the loader
if ($Script:CompilationErrorsCount -ne 0){
    Write-Host '[COMPILATION] ' -f DarkRed -NoNewLine
    Write-Host "$Script:CompilationErrorsCount errors" -f Yellow  
    throw "$Script:CompilationErrorsCount errors"
    return 
}

Set-Content -Path $Script:TmpModuleCode -Value $Script:Psm1Content
Write-Host '[DONE] ' -f Green -NoNewLine
Write-Host "$Script:TmpModuleCode" -f DarkCyan 