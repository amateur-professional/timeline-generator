# To ensure this script runs correctly, please ensure you have done the following:
# 1. Installed the appropriate version (2.x) of python onto your machine
# 2. Added both plaso and analyzeMFT scripts, as well as your Python interpreter, to your PATH environment variable

param (
    [Parameter(Mandatory=$true)][string]$evidencePath,
    [string]$outputType="l2tcsv"
)
if(!$evidencePath) {
    Write-Output "No evidence folder given! Exiting..."
    Exit-PSSession
} elseif (!(Test-Path -path $evidencePath)) {
    Write-Output "Evidence folder does not exist! Exiting..."
    Exit-PSSession
}
# identify location of analyzeMFT.py
$paths = $env:path.split(";") 
$items = ($paths | ForEach-Object -Process {"$_\$(Get-ChildItem -Path $_ -Name -Include analyzeMFT.py)"})
$aMFTLocation = ($items | Where-Object {$_ -Match "C:\\.*analyzeMFT.py$"})
# move $MFT to temp directory for parsing
Move-Item -Path "$evidencePath\`$MFT" -Destination $env:temp
# process $MFT
Start-Process python -ArgumentList "`"$aMFTLocation`" -b `"$evidencePath\mft.body`" -f $env:temp\`$MFT --bodyfull" -NoNewWindow -Wait
# process evidence folder with psteal
Start-Process psteal.exe -ArgumentList "--source $evidencePath -o $outputType -z UTC -w $evidencePath\timeline.csv" -NoNewWindow -Wait
# move $MFT back to evidence directory to avoid losing evidence
Move-Item -Path "$env:temp\`$MFT" -Destination $evidencePath
