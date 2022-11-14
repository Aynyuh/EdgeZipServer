using namespace System.IO;
using namespace System.IO.Compression;

[CmdletBinding()]
param(
    [string]
    $SourceFolder,

    [string]
    $OutputFileName,

    [CompressionLevel]
    $CompressionLevel = [CompressionLevel]::Fastest
)

function Force-Resolve-Path {
    <#
    .SYNOPSIS
        Calls Resolve-Path but works for files that don't exist.
    .REMARKS
        From http://devhawk.net/blog/2010/1/22/fixing-powershells-busted-resolve-path-cmdlet
    #>
    param (
        [string] $Path
    )

    $Path = Resolve-Path -Path $Path -ErrorAction SilentlyContinue -ErrorVariable _frperror
    if (-not($Path)) {
        $Path = $_frperror[0].TargetObject
    }

    return $Path
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

# Construction result absolute paths
$SourcePath = Resolve-Path -Path $SourceFolder
$DestinationArchiveName = Force-Resolve-Path -Path $OutputFileName

# verbose output of result parameters
Write-Verbose -Message "Source folder: `"$SourcePath`""
Write-Verbose -Message "Destination archive: `"$DestinationArchiveName`""
Write-Verbose -Message "Compression: `"$CompressionLevel`""

if (Test-Path -Path $SourcePath -PathType Container)
{
    [ZipFile]::CreateFromDirectory($SourcePath, $DestinationArchiveName, $CompressionLevel, $false)
}
else
{
    throw "Can't access source path `"$SourcePath`""
}