$ErrorActionPreference= 'silentlycontinue';Get-ChildItem -Name = "C:\Users\*\AppData\Roaming\Mozilla\Firefox\Profiles\*\extensions\*"; Get-ChildItem -Name = "C:\Users\*\AppData\Roaming\Mozilla\Firefox\Profiles\*\extensions\staged\*";
# Delete this line and the comment hashes to have this export the contents to the host.
# | Out-File -Encoding ASCII -Append -FilePath "C:\$env:COMPUTERNAME-FireFoxExtension.txt"
