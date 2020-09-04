(New-Object -ComObject Shell.Application).NameSpace(0x0a).Items() | select @{n="OriginalLocation"; e={$_.ExtendedProperty("{9B174B33-40FF-11D2-A27E-00C04FC30871} 2")}},Name;
# Delete this line and the comment hashes to have this export the contents to the host.
# | Export-Csv -Path "c:\$env:COMPUTERNAME-recyclebin.csv" -NoTypeInformation
