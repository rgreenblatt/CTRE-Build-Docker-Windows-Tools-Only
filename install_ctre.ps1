Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

Unzip "C:\CTRE.zip" "C:\CTRE"

Start-Process C:\CTRE\* -wait -argumentlist '/S /D=C:\Users\Public\Documents\'
