<#
.SYNOPSIS
  CrowdStrike Full Triage collects a number of hard artifacts from the endpoint and wraps them into a single payload to be gathered later.
.DESCRIPTION
  CrowdStrike Full Triage collects a number of hard artifacts from the endpoint and wraps them into a single payload to be gathered 
  from "$Env:SystemDrive\Collections\FullCollection.zip".
  The full collection of artifacts is:
  * WebHistory from Firfox, Chromem, and IE
  * Jumplist
  * AmCache
  * SYSTEM Registry Hive
  * SOFTWARE Registry Hive
  * NTUSER.dat Registry Hive
  * UsrClass.dat Registry Hive
  * Windows Event logs
  * Master File Table (MFT)
.INPUTS
    None
.OUTPUTS
    None
.NOTES
  Version:        1.1
  Author:         Ryan Jafarkhani
  Creation Date:  2020.07.04
  Modified By:    Bryan Bowie
  Modified Date:  2021.08.09
  Purpose/Change: 
    Removed short hand notations. 
    Updated variables to follow proper verb usage. 
    Updated $null to the left side of equality comparisons. 
    Added header.
.EXAMPLE
  runscript -CloudFile="Get-FullTriage" -CommandLine=""
#>
function Get-FullTriage {

    <# Create Collections Directory if not exist - Change this to what you want #>
    New-Item -Force $Env:SystemDrive\Collections\WebHistory -ItemType Directory
    New-Item -Force $Env:SystemDrive\Collections\RegistryandRecentAccess -ItemType Directory
    New-Item -Force $Env:SystemDrive\Collections\RegistryandRecentAccess\JumpList -ItemType Directory
    New-Item -Force $Env:SystemDrive\Collections\EventLogs -ItemType Directory
    
    <# Create shadow copy link, and if the link already exists, remove it, and then try again #>
    $temp_shadow_link = "C:\shadowcopy1234123"
    $s1 = (Get-WmiObject -List Win32_ShadowCopy).Create("C:\", "ClientAccessible")
    $s2 = Get-WmiObject Win32_ShadowCopy | Where-Object { $_.ID -eq $s1.ShadowID }
    $d = $s2.DeviceObject + "\"
    
    if (Test-Path $temp_shadow_link) {
        Write-Output "SHADOW COPY LINK ALREADY EXISTS, DELETING"
        cmd /c rmdir $temp_shadow_link
    }
    
    Write-Output "CREATING SHADOW LINK TO COPY FILES FROM"
    cmd /c mklink /d $temp_shadow_link $d
    
    <# Find current logged in user. Default is systemprofile #>
    $User = tasklist /v /FI "IMAGENAME eq explorer.exe" /FO list | find "User Name:"
    $User = $User.Substring(14)
    $pos = $User.IndexOf("\")
    $leftPart = $User.Substring(0, $pos)
    $userextract = $User.Substring($pos + 1)
    Write-Output "$userextract is the currently logged in user"
    
    <# Collect the things. Edit as you like. This is collecting Firfox, Chrome, and IE #>
    Write-Output "Copying Webhistory"
    $webdestination = "$Env:systemdrive\Collections\WebHistory"
    
    <# Collect the things. Edit as you like. This is collecting Firfox, Chromem, and IE #>
    Get-ChildItem -Path "$temp_shadow_link\Users\$userextract\AppData\Local\Microsoft\Windows\Webcache\*\WebCacheV01.dat" -Force -Recurse -EA SilentlyContinue | ForEach-Object { Copy-Item -Path $_.FullName -Destination $webdestination }
    Get-ChildItem -Path "$temp_shadow_link\Users\$userextract\AppData\Local\Google\Chrome\User Data\*\History"-Force  -Recurse -EA SilentlyContinue | ForEach-Object { Copy-Item -Path $_.FullName -Destination $webdestination }
    Get-ChildItem -Path "$temp_shadow_link\Users\$userextract\AppData\Local\Google\Chrome\User Data\*\History-journal" -Force -Recurse -EA SilentlyContinue | ForEach-Object { Copy-Item -Path $_.FullName -Destination $webdestination }
    Get-ChildItem -Path "$temp_shadow_link\Users\$userextract\AppData\Roaming\Mozilla\Firefox\Profiles\*\places.sqlite" -Force -Recurse -EA SilentlyContinue | ForEach-Object { Copy-Item -Path $_.FullName -Destination $webestination }
    Get-ChildItem -Path "$temp_shadow_link\Users\$userextract\AppData\Roaming\Mozilla\Firefox\Profiles\*\places.sqlite-shm" -Force -Recurse -EA SilentlyContinue | ForEach-Object { Copy-Item -Path $_.FullName -Destination $webdestination }
    Get-ChildItem -Path "$temp_shadow_link\Users\$userextract\AppData\Roaming\Mozilla\Firefox\Profiles\*\places.sqlite-wal" -Force -Recurse -EA SilentlyContinue | ForEach-Object { Copy-Item -Path $_.FullName -Destination $webdestination }
    
    
    <# Collect the things. edit as you like. This is collecting Jumplist, Registry, AmCache, etc#>
    Write-Output "Copying Registry Hives, Useraccess, and JumpList"
    $regdestination = "$Env:systemdrive\Collections\RegistryandRecentAccess"
    
    <# Collect the things. edit as you like. This is collecting Jumplist, Registry, AmCache, etc#>
    Get-ChildItem -Path "$temp_shadow_link\Windows\System32\config\SYSTEM" -Force -Recurse -EA SilentlyContinue | ForEach-Object { Copy-Item -Path $_.FullName -Destination $regdestination }
    Get-ChildItem -Path "$temp_shadow_link\Windows\System32\config\SOFTWARE" -Force -Recurse -EA SilentlyContinue | ForEach-Object { Copy-Item -Path $_.FullName -Destination $regdestination }
    Get-ChildItem -Path "$temp_shadow_link\Users\$userextract\AppData\Local\Microsoft\Windows\UsrClass.dat" -Force -Recurse -EA SilentlyContinue | ForEach-Object { Copy-Item -Path $_.FullName -Destination $regdestination }
    Get-ChildItem -Path "$temp_shadow_link\Windows\appcompat\Programs\Amcache.hve" -Force -Recurse -EA SilentlyContinue | ForEach-Object { Copy-Item -Path $_.FullName -Destination $regdestination }
    Get-ChildItem -Path "$temp_shadow_link\Users\$userextract\NTUSER.DAT" -Force -Recurse -EA SilentlyContinue | ForEach-Object { Copy-Item -Path $_.FullName -Destination $regdestination }
    Get-ChildItem -Path "$temp_shadow_link\Users\$userextract\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations" -Force -Recurse -EA SilentlyContinue | ForEach-Object { Copy-Item -Path $_.FullName -Destination "$regdestination\JumpList" }
    Get-ChildItem -Path "$temp_shadow_link\Users\$userextract\AppData\Roaming\Microsoft\Windows\Recent\CustomDestinations" -Force -Recurse -EA SilentlyContinue  | ForEach-Object { Copy-Item -Path $_.FullName -Destination "$regdestination\JumpList" }
    
    <# Clean up and remove the VSS link #>
    Write-Output "DELETING SNAPSHOT AND THE LINK TO IT (#CLEANUP), LOOKS LIKE Registry and WebHistory Finished Fine"
    $s2.Delete()
    cmd /c rmdir $temp_shadow_link
    
    Write-Output "Collecting and Compressing Windows Event logs"
    <#Iterate through All Windows Event Logs where record count is not zero or null, replace a string and
    use wevutil.exe to export those event logs #>
    Get-winevent  -Listlog  * |  Where-Object { $_.RecordCount } | Select-Object  Logname, Logfilepath | ForEach-Object -Process { 
        $name = $_.Logname
        $newname = $name.Replace("/", "-")
        wevtutil.exe EPL $name  $Env:SystemDrive\Collections\EventLogs\$newname.evtx
    }
    
    
    <# Compress Event Logs #>
    Get-ChildItem -Path $Env:SystemDrive\Collections\EventLogs | Compress-Archive -DestinationPath $Env:SystemDrive\Collections\EventLogs\Archived_WinLogs
    
    <# Change all file properties to Archive. Powershell compress has bug that won't compress hidden files#>
    $FolderPath = "$Env:SystemDrive\Collections\"
    Get-ChildItem -Path $FolderPath -Force -Recurse | ForEach-Object {
        Set-ItemProperty -Path $_.FullName -Name Attributes -Value Archive
    }
    
    Write-Output "Removing Temp Event Logs"
    <# Remove Event Logs to save space and cleanup #>
    Get-ChildItem -Path $Env:SystemDrive\Collections\EventLogs *.evtx | ForEach-Object { Remove-Item -Path $_.FullName }
    
    <# Compress all the things #>
    Get-ChildItem -Path $Env:SystemDrive\Collections | Compress-Archive -DestinationPath $Env:SystemDrive\Collections\FullCollection.zip -Update
    
    Write-Output "Cleaning up"
    Get-ChildItem -Path $Env:SystemDrive\Collections -Exclude FullCollection.zip | ForEach-Object { Remove-Item -Path $_.FullName -Recurse -Force }
    Write-Output "All done now"
}
    
function Export-MFT {
    <#
    
    Extracts MFT and saves to C:\Collections\mftout.bin 
    To run: 
    ```
    runscript -CloudFile="ExtractMFT" -CommandLine="ExtractMFT ; Export-MFT"
    ```
    .SYNOPSIS
    Extracts master file table from volume.
    
    Version: 0.1
    Author : Jesse Davis (@secabstraction)
    License: BSD 3-Clause
    
    .DESCRIPTION
    This module exports the master file table (MFT) and writes it to C:\MFTout.bin
    The object(s) output by this module specify the path of the written MFT file for retrieval via Copy-Item -Path \\NetworkPath\C$
    
    .PARAMETER ComputerName 
    Specify host(s) to retrieve data from.
    
    .PARAMETER ThrottleLimit 
    Specify maximum number of simultaneous connections.
    
    .PARAMETER Volume 
    Specify a volume to retrieve its master file table.
    
    .PARAMETER CSV 
    Specify path to output file, output is formatted as comma separated values.
    
    .EXAMPLE
    The following example extracts the master file table from the local system volume and writes it to TEMP.
    
    PS C:\> Export-MFT
    
    .EXAMPLE
    The following example extracts the master file table from the system volume of Server01 and writes it to TEMP.
    
    PS C:\> Export-MFT -ComputerName Server01
    
    .EXAMPLE
    The following example extracts the master file table from the F volume on Server01 and writes it to TEMP.
    
    PS C:\> Export-MFT -ComputerName Server01 -Volume F
    
    #>
    [CmdLetBinding()]
    Param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ComputerName,
    
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Int]$ThrottleLimit = 10,
    
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Char]$Volume = 0,
    
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$CSV
    ) #End Param
         
    #Enable verbosity by default
    $VerbosePreference = 'Continue'
           
    $ScriptTime = [Diagnostics.Stopwatch]::StartNew()
    
    $RemoteScriptBlock = {
        Param($Volume)
    
        if ($Volume -ne 0) { 
            $Win32_Volume = Get-WmiObject -Class Win32_Volume -Filter "DriveLetter LIKE '$($Volume):'"
            if ($Win32_Volume.FileSystem -ne "NTFS") { 
                Write-Error "$Volume is not an NTFS filesystem."
                break
            }
        }
        else {
            $Win32_Volume = Get-WmiObject -Class Win32_Volume -Filter "DriveLetter LIKE '$($env:SystemDrive)'"
            if ($Win32_Volume.FileSystem -ne "NTFS") { 
                Write-Error "$env:SystemDrive is not an NTFS filesystem."
                break
            }
        }
    
        New-Item -Force $Env:SystemDrive\Collections -ItemType Directory
        $OutputFilePath = $Env:SystemDrive + "\Collections" + "\MFTOUT.bin"
    
        #region WinAPI
    
        $GENERIC_READWRITE = 0x80000000
        $FILE_SHARE_READWRITE = 0x02 -bor 0x01
        $OPEN_EXISTING = 0x03
    
        $DynAssembly = New-Object System.Reflection.AssemblyName('MFT')
        $AssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly($DynAssembly, [Reflection.Emit.AssemblyBuilderAccess]::Run)
        $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('InMemory', $false)
    
        $TypeBuilder = $ModuleBuilder.DefineType('kernel32', 'Public, Class')
        $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
        $SetLastError = [Runtime.InteropServices.DllImportAttribute].GetField('SetLastError')
        $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder($DllImportConstructor,
            @('kernel32.dll'),
            [Reflection.FieldInfo[]]@($SetLastError),
            @($True))
    
        #CreateFile
        $PInvokeMethodBuilder = $TypeBuilder.DefinePInvokeMethod('CreateFile', 'kernel32.dll',
            ([Reflection.MethodAttributes]::Public -bor [Reflection.MethodAttributes]::Static),
            [Reflection.CallingConventions]::Standard,
            [IntPtr],
            [Type[]]@([String], [Int32], [UInt32], [IntPtr], [UInt32], [UInt32], [IntPtr]),
            [Runtime.InteropServices.CallingConvention]::Winapi,
            [Runtime.InteropServices.CharSet]::Ansi)
        $PInvokeMethodBuilder.SetCustomAttribute($SetLastErrorCustomAttribute)
    
        #CloseHandle
        $PInvokeMethodBuilder = $TypeBuilder.DefinePInvokeMethod('CloseHandle', 'kernel32.dll',
            ([Reflection.MethodAttributes]::Public -bor [Reflection.MethodAttributes]::Static),
            [Reflection.CallingConventions]::Standard,
            [Bool],
            [Type[]]@([IntPtr]),
            [Runtime.InteropServices.CallingConvention]::Winapi,
            [Runtime.InteropServices.CharSet]::Auto)
        $PInvokeMethodBuilder.SetCustomAttribute($SetLastErrorCustomAttribute)
    
        $Kernel32 = $TypeBuilder.CreateType()
    
        #endregion WinAPI
    
        # Get handle to volume
        if ($Volume -ne 0) { $VolumeHandle = $Kernel32::CreateFile(('\\.\' + $Volume + ':'), $GENERIC_READWRITE, $FILE_SHARE_READWRITE, [IntPtr]::Zero, $OPEN_EXISTING, 0, [IntPtr]::Zero) }
        else { 
            $VolumeHandle = $Kernel32::CreateFile(('\\.\' + $env:SystemDrive), $GENERIC_READWRITE, $FILE_SHARE_READWRITE, [IntPtr]::Zero, $OPEN_EXISTING, 0, [IntPtr]::Zero) 
            $Volume = ($env:SystemDrive).TrimEnd(':')
        }
            
        if ($VolumeHandle -eq -1) { 
            Write-Error "Unable to obtain read handle for volume."
            break 
        }         
            
        # Create a FileStream to read from the volume handle
        $FileStream = New-Object IO.FileStream($VolumeHandle, [IO.FileAccess]::Read)                   
    
        # Read VBR from volume
        $VolumeBootRecord = New-Object Byte[](512)                                                     
        if ($FileStream.Read($VolumeBootRecord, 0, $VolumeBootRecord.Length) -ne 512) { Write-Error "Error reading volume boot record." }
    
        # Parse MFT offset from VBR and set stream to its location
        $MftOffset = [Bitconverter]::ToInt32($VolumeBootRecord[0x30..0x37], 0) * 0x1000
        $FileStream.Position = $MftOffset
    
        # Read MFT's file record header
        $MftFileRecordHeader = New-Object byte[](48)
        if ($FileStream.Read($MftFileRecordHeader, 0, $MftFileRecordHeader.Length) -ne $MftFileRecordHeader.Length) { Write-Error "Error reading MFT file record header." }
    
        # Parse values from MFT's file record header
        $OffsetToAttributes = [Bitconverter]::ToInt16($MftFileRecordHeader[0x14..0x15], 0)
        $AttributesRealSize = [Bitconverter]::ToInt32($MftFileRecordHeader[0x18..0x21], 0)
    
        # Read MFT's full file record
        $MftFileRecord = New-Object byte[]($AttributesRealSize)
        $FileStream.Position = $MftOffset
        if ($FileStream.Read($MftFileRecord, 0, $MftFileRecord.Length) -ne $AttributesRealSize) { Write-Error "Error reading MFT file record." }
            
        # Parse MFT's attributes from file record
        $Attributes = New-object byte[]($AttributesRealSize - $OffsetToAttributes)
        [Array]::Copy($MftFileRecord, $OffsetToAttributes, $Attributes, 0, $Attributes.Length)
            
        # Find Data attribute
        $CurrentOffset = 0
        do {
            $AttributeType = [Bitconverter]::ToInt32($Attributes[$CurrentOffset..$($CurrentOffset + 3)], 0)
            $AttributeSize = [Bitconverter]::ToInt32($Attributes[$($CurrentOffset + 4)..$($CurrentOffset + 7)], 0)
            $CurrentOffset += $AttributeSize
        } until ($AttributeType -eq 128)
            
        # Parse data attribute from all attributes
        $DataAttribute = $Attributes[$($CurrentOffset - $AttributeSize)..$($CurrentOffset - 1)]
    
        # Parse MFT size from data attribute
        $MftSize = [Bitconverter]::ToUInt64($DataAttribute[0x30..0x37], 0)
            
        # Parse data runs from data attribute
        $OffsetToDataRuns = [Bitconverter]::ToInt16($DataAttribute[0x20..0x21], 0)        
        $DataRuns = $DataAttribute[$OffsetToDataRuns..$($DataAttribute.Length - 1)]
            
        # Convert data run info to string[] for calculations
        $DataRunStrings = ([Bitconverter]::ToString($DataRuns)).Split('-')
            
        # Setup to read MFT
        $FileStreamOffset = 0
        $DataRunStringsOffset = 0        
        $TotalBytesWritten = 0
        $MftData = New-Object byte[](0x1000)
        $OutputFileStream = [IO.File]::OpenWrite($OutputFilePath)
    
        do {
            $StartBytes = [int]($DataRunStrings[$DataRunStringsOffset][0]).ToString()
            $LengthBytes = [int]($DataRunStrings[$DataRunStringsOffset][1]).ToString()
                
            $DataRunStart = "0x"
            for ($i = $StartBytes; $i -gt 0; $i--) { $DataRunStart += $DataRunStrings[($DataRunStringsOffset + $LengthBytes + $i)] }
    
            $DataRunLength = "0x"
            for ($i = $LengthBytes; $i -gt 0; $i--) { $DataRunLength += $DataRunStrings[($DataRunStringsOffset + $i)] }
    
            $FileStreamOffset += ([int]$DataRunStart * 0x1000)
            $FileStream.Position = $FileStreamOffset           
    
            for ($i = 0; $i -lt [int]$DataRunLength; $i++) {
                if ($FileStream.Read($MftData, 0, $MftData.Length) -ne $MftData.Length) { 
                    Write-Warning "Possible error reading MFT data on $env:COMPUTERNAME." 
                }
                $OutputFileStream.Write($MftData, 0, $MftData.Length)
                $TotalBytesWritten += $MftData.Length
            }
            $DataRunStringsOffset += $StartBytes + $LengthBytes + 1
        } until ($TotalBytesWritten -eq $MftSize)
            
        $FileStream.Dispose()
        $OutputFileStream.Dispose()
    
        $Properties = @{
            NetworkPath  = "\\$($env:COMPUTERNAME)\C$\$($OutputFilePath.TrimStart('C:\'))"
            ComputerName = $env:COMPUTERNAME
            'MFT Size'   = "$($MftSize / 1024 / 1024) MB"
            'MFT Volume' = $Volume
            'MFT File'   = $OutputFilePath
        }
        New-Object -TypeName PSObject -Property $Properties
    }
    
    if ($PSBoundParameters['ComputerName']) {   
        $ReturnedObjects = Invoke-Command -ComputerName $ComputerName -ScriptBlock $RemoteScriptBlock -ArgumentList @($Volume) -SessionOption (New-PSSessionOption -NoMachineProfile) -ThrottleLimit $ThrottleLimit
    }
    else { $ReturnedObjects = Invoke-Command -ScriptBlock $RemoteScriptBlock -ArgumentList @($Volume) }
    
    if ($null -ne $ReturnedObjects) {
        if ($PSBoundParameters['CSV']) { $ReturnedObjects | Export-Csv -Path $OutputFilePath -Append -NoTypeInformation -ErrorAction SilentlyContinue }
        else { Write-Output $ReturnedObjects }
    }
    
    [GC]::Collect()
    $ScriptTime.Stop()
    Write-Verbose "Done, execution time: $($ScriptTime.Elapsed)"
    
     
    <# Compress all the things #>
    Write-Output "Adding MFT to Full Collection Archive"
    Get-ChildItem -Path $Env:SystemDrive\Collections\MFTOUT.bin | Compress-Archive -Update -DestinationPath $Env:SystemDrive\Collections\FullCollection.zip
    
    <# Clean up MFT #>
    Write-Output "Cleaning up"
    Get-ChildItem -Path $Env:SystemDrive\Collections -Exclude FullCollection.zip | ForEach-Object { Remove-Item -Path $_.FullName -Recurse -Force }
    Write-Output "All done now"
}
