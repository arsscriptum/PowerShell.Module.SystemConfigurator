<#
    .SYNOPSIS
        Get Windows Special Folders. (Not as easy as it sounds)

        This function leverages work from:

        Ray Koopa - https://www.codeproject.com/articles/878605/getting-all-special-folders-in-net
        Lee Dailey - https://www.reddit.com/r/PowerShell/comments/7rnt31/looking_for_a_critique_on_function/

    .DESCRIPTION
        Give the function the name (or part of a name) of a Special Folder and this function will tell you
        where the actual path is on the given Windows OS.

    .PARAMETER SpecialFolderName
        This parameter is MANDATORY.
        
        This parameter takes a string that represents the name of the Special Folder you are searching for.

    .EXAMPLE
        Get-SpecialFolder -SpecialFolderName MyDocuments    

    .EXAMPLE
        Get-SpecialFolder Documents

    .OUTPUTS
        One or more Syroot.Windows.IO.KnownFolder objects that look like:

            Type         : Documents
            Identity     : System.Security.Principal.WindowsIdentity
            DefaultPath  : C:\Users\zeroadmin\Documents
            Path         : C:\Users\zeroadmin\Documents
            ExpandedPath : C:\Users\zeroadmin\Documents
#>

function Get-SpecialFolder {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True)]
        [string]$SpecialFolderName
    )

    $CurrentlyLoadedAssemblies = [System.AppDomain]::CurrentDomain.GetAssemblies()
    if (![bool]$($CurrentlyLoadedAssemblies.FullName -match "Syroot")) {
        $PathHelper = "$HOME\Downloads\Syroot.Windows.IO.KnownFolders.1.0.2" 
        Invoke-WebRequest -Uri "https://www.nuget.org/api/v2/package/Syroot.Windows.IO.KnownFolders/1.0.2" -OutFile "$PathHelper.zip"
        Expand-Archive -Path "$PathHelper.zip" -DestinationPath $PathHelper -Force
        $Syroot = Add-Type -Path "$PathHelper\lib\net40\Syroot.Windows.IO.KnownFolders.dll" -Passthru
    }
    else {
        $Syroot = $($CurrentlyLoadedAssemblies -match "Syroot").ExportedTypes
    }
    $SyrootKnownFolders = $Syroot | Where-Object {$_.Name -eq "KnownFolders"}
    $AllSpecialFolders = $($SyrootKnownFolders.GetMembers() | Where-Object {$_.MemberType -eq "Property"}).Name
    [System.Collections.ArrayList]$AllSpecialFolderObjects = foreach ($FolderName in $AllSpecialFolders) {
        [Syroot.Windows.IO.KnownFolders]::$FolderName
    }

    $Full_SFN_List = [enum]::GetNames('System.Environment+SpecialFolder')
    # The ACTUAL paths ARE accounted for in $RealSpecialFolderObjects.Path, but SOME of the Special Names used in $Full_SFN_List
    # are not mapped to the 'Type' property of $RealSpecialFolderObjects
    $SpecialNamesNotAccountedFor = $(Compare-Object $AllSpecialFolders $Full_SFN_List | Where-Object {$_.SideIndicator -eq "=>"}).InputObject

    if ([bool]$($AllSpecialFolderObjects.Type -match $SpecialFolderName)) {
        $AllSpecialFolderObjects | Where-Object {$_.Type -match $SpecialFolderName}
    }
    elseif ([bool]$($SpecialNamesNotAccountedFor -match $SpecialFolderName)) {
        $AllPossibleMatches = $SpecialNamesNotAccountedFor -match $SpecialFolderName

        foreach ($PossibleMatch in $AllPossibleMatches) {
            $AllSpecialFolderObjects | Where-Object {$_.ExpandedPath -eq [environment]::GetFolderPath($PossibleMatch)}
        }
    }
    else {
        Write-Error "Unable to find a Special Folder with the name $SpecialFolderName! Halting!"
        $global:FunctionResult = "1"
        return
    }
}





