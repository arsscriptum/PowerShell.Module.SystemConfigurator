


function SanitizeFileNames {
    [CmdletBinding()]
    Param(
      [ValidateScript({
            if(-Not ($_ | Test-Path) ){
                throw "File or folder does not exist"
            }
            if(-Not ($_ | Test-Path -PathType Container) ){
                throw "The Path argument must be a Directory. Files paths are not allowed."
            }
            return $true 
        })]
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Path,
        [Parameter(Mandatory=$false)]
        [String]$DestinationPath,
        [Parameter(Mandatory=$false)]
        [String]$Filter = "*.ps1",
        [Parameter(Mandatory=$False)]
        [switch]$Recurse
    )
    $SanitizedFiles = [System.Collections.ArrayList]::new()
    $ShouldCopy = $False
    Write-Host "[SanitizeFileNames] " -f Blue -NoNewLine ; Write-Host "Path    $Path" -f Gray
    Write-Host "[SanitizeFileNames] " -f Blue -NoNewLine ; Write-Host "Filter    $Filter" -f Gray
    Write-Host "[SanitizeFileNames] " -f Blue -NoNewLine ; Write-Host "Recurse $Recurse" -f Gray
    $AllFiles = gci -Path $Path -Recurse:$Recurse -File -Filter $Filter
    if( $PSBoundParameters.ContainsKey( 'DestinationPath' ) -eq $False ) {
        $DestinationPath = $Path
    }else{
        $ShouldCopy = $True
        $Null = New-Item -Path $DestinationPath -ItemType Directory -Force -EA Ignore
    }

    ForEach($File in $AllFiles){
        $base = $File.BaseName
        $HasSpecialChar = $base.Contains('-')
        if($HasSpecialChar){
            $newbase = $base.replace('-','')
            #Write-Host "[SanitizeFileNames] " -f Blue -NoNewLine ; Write-Host "Changing $base to $newbase " -f DarkRed ; 

            $OldFile = $File.FullName
            $NewFile = Join-Path $DestinationPath ($newbase + $File.Extension)
            if($ShouldCopy){
                $Null = Copy-Item $OldFile $NewFile -Force -EA Ignore
                $Null = $SanitizedFiles.Add($NewFile)
            }else{
                $Null = Rename-Item $OldFile $NewFile -Force -EA Ignore
                $Null = $SanitizedFiles.Add($NewFile)
            }
        }
    }

    return $SanitizedFiles 
}

