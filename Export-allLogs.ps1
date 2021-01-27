$ErrorActionPreference = 'silentlycontinue';
Get-WinEvent -ListLog * -ErrorAction 'silentlycontinue' | 
  where-object {$_.recordcount} | 
    Foreach-Object { 
      get-winevent -LogName $_.logname
      } | 
      Export-Csv -NoTypeInformation C:\Windows\Temp\$env:COMPUTERNAME-fullsystem-eventlogs.csv
