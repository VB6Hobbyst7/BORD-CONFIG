﻿B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private parser As JSONParser
	Private cnf As String
	Dim ftp As SFtp
	Private clsfunc As classFunc
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	clsfunc.Initialize
End Sub


Sub parseConfig(swTimeOut As B4XSwitch, edtTimeOut As EditText, swUseDigital As B4XSwitch, swUseYellow As B4XSwitch)
		
	cnf = File.ReadString(Starter.hostPath, "cnf.44")
	
	parser.Initialize(cnf)

	Dim root As Map = parser.NextObject
	Dim showPromote As Map = root.Get("showPromote")
	Dim digitalFont As Map = root.Get("digitalFont")
	Dim fontColor As Map = root.Get("fontColor")
	Dim colorYellow As String = fontColor.Get("colorYellow")
	
	
	If swTimeOut.Value = True Then
		showPromote.Put("active", "1")
	Else
		showPromote.Put("active", "0")
	End If
	showPromote.Put("timeOut", edtTimeOut.Text)
	
	If swUseDigital.Value = True Then
		digitalFont.put("active", "1")
	Else
		digitalFont.put("active", "0")
	End If
	
	If swUseYellow.Value = True Then
		fontColor.Put("colorYellow", "1")
		Else
		fontColor.Put("colorYellow", "0")
	End If
	
	Dim JSONGenerator As JSONGenerator
	JSONGenerator.Initialize(root)
	
	File.WriteString(Starter.hostPath, "cnf.44", JSONGenerator.ToPrettyString(2))
	Sleep(50)
	pushConfig
End Sub
	
Sub pushConfig
	ftp.Initialize("ftp", "pi", "0", "192.168.1.27", 22)
	ftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
	
	ftp.UploadFile(Starter.hostPath, "cnf.44", "/home/pi/44/cnf.44")
	Wait For ftp_UploadCompleted (ServerPath As String, Success As Boolean)
	If Success = False Then
		clsfunc.createCustomToast("Configuratie niet verzonden")
	Else
		clsfunc.createCustomToast("Configuratie verzonden")
	End If
	
	ftp.Close
End Sub