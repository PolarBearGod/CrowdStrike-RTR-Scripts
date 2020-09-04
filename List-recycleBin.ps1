  (New-Object -ComObject Shell.Application).NameSpace(0x0a).Items() | select @{n="OriginalLocation"; e={$_.ExtendedProperty("{9B174B33-40FF-11D2-A27E-00C04FC30871} 2")}},Name;
