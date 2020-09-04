Get-WmiObject Win32_PnPSignedDriver | select DeviceName, Description, DeviceID, DriverDate, DriverProviderName, FriendlyName, DriverVersion, IsSigned, Signer;
# Delete this line and the comment hashes to have this export the contents to the host.
# | Export-Csv -Path "c:\$env:COMPUTERNAME-driverinfo.csv" -NoTypeInformation
