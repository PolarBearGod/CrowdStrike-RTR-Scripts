(New-Object -ComObject Shell.Application).NameSpace(0x0a).Items() | select @{n="OriginalLocation"; e={$_.ExtendedProperty("{9B174B33-40FF-11D2-A27E-00C04FC30871} 2")}},Name;
# Delete this line and the comment hashes to have this export the contents to the host.
# | Export-Csv -Path "c:\$env:COMPUTERNAME-recyclebin.csv" -NoTypeInformation

# Note: this command does not work 100% directly in RTR. When RTR runs, it is in SYSTEM context which likely has nothing in its trash bin.
# The above scriptblock is best used on a live system or directly into a script file and executed under a user's context (i.e. New-PSSession)
