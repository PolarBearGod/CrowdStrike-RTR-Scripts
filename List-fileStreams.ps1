Get-ChildItem -Path "C:\" -recurse –force -ErrorAction SilentlyContinue | ForEach-Object { Get-Item $_.FullName -stream * } | Where-Object stream -ne ':$Data';
# Delete this line and the comment hashes to have this export the contents to the host.
# | Export-CSV -NoClobber -NoTypeInformation -Path "C:\streams.csv";
