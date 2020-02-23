Set WshShell = CreateObject("WScript.Shell") 
WshShell.Run chr(34) & ".\Launch.bat" & Chr(34), 0
Set WshShell = Nothing