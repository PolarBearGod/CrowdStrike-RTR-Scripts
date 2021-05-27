<#
.SYNOPSIS
  Flattens all event logs on the system (including those for the kernal and system) to a single CSV
.INPUTS
  None
.OUTPUTS
.PARAMETER $OutPath
    Outputs the values to the destination specified to a file name "$env:COMPUTERNAME-scheduledtasks.csv"
    where "$env:COMPUTERNAME" is the name of the computer the command is executed on. 
    Do not put the name of the file in the path. The path cannot contain spaces and must exist.
.NOTES
  Version:        1.1
  Author:         Bryan Bowie
  Creation Date:  2021.01.27
  Purpose/Change: Added some comments and helpers
.EXAMPLE
  runscript -CloudFile="Export-allLogs" -CommandLine="-outpath C:\windows\temp"
#>
[CmdletBinding()]
param(
    
    [Parameter(Mandatory=$true, Position = 0)]
    [ValidateScript({ Test-Path $_ })]
    #The location of where the saved file will be, less a file name. Example 'C:\Windows\Temp\'
    [string] $OutPath
    )
If((test-path "$OutPath\$env:COMPUTERNAME-fulleventlogs.csv"))
{
    Remove-Item -Force -Path "$OutPath\$env:COMPUTERNAME-fulleventlogs.csv"
}
Get-WinEvent -ListLog * -ErrorAction 'silentlycontinue' | 
  where-object {$_.recordcount} | 
    Foreach-Object { 
      get-winevent -LogName $_.logname
      } | 
      Export-Csv -NoTypeInformation "$OutPath\$env:COMPUTERNAME-fulleventlogs.csv"
