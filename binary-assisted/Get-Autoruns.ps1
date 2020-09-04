# Experimental. 
# Binary may not download or switches may not input correctly. Need to troubleshoot.
$client=new-object System.Net.WebClient; $client.DownloadFile("https://live.sysinternals.com/autorunsc.exe","c:\windows\temp\autoruns.exe"); (New-Object -com Shell.Application).ShellExecute("powershell.exe", "-windowstyle hidden -Command", 'c:\windows\temp\autoruns.exe -a * -c -h -s -t -nobanner >', "C:\windows\temp\$env:ComputerName-autoruns.csv");
