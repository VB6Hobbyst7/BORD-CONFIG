B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Dim ftp As FTP
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

public Sub retrieveVersion
	ftp.PassiveMode = True
	ftp.Initialize("FTP", "ftp.pdeg.nl", 21, Starter.doy, Starter.moy)
	
	getFiles
	ftp.Close
	
	
End Sub


Sub getFiles
	Dim version As String
	
	ftp.List("/")
	Wait For FTP_ListCompleted (ServerPath As String, Success As Boolean, Folders() As FTPEntry, Files() As FTPEntry)
	
	For i = 0 To Files.Length -1
	'	Log(Files(i).Name)
		If Files(i).Name.IndexOf("bordupdate") > -1 Then
			version = getVer(Files(i).Name)
			Starter.updateFile = Files(i).Name
			Starter.fileSize = Files(i).Size
			If version <> Starter.bordVersion Then
				CallSub(config, "updateAvailable")
			End If
			Exit
		End If
		
	Next
	
	
	
End Sub

Sub getVer(str As String) As String
	Dim ver As String
	Dim lst As List
	
	lst.Initialize
	
	str = str.Replace(".jar", "")
	lst = Regex.Split("_", str)
	ver = $"${lst.Get(1)}.${lst.Get(2)}.${lst.Get(3)}"$
	Starter.upDateVersion = ver
	Return ver
	
End Sub