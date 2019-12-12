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


Sub parseConfig(swTimeOut As B4XSwitch, edtTimeOut As EditText, swUseDigital As B4XSwitch, swUseYellow As B4XSwitch, msg As List)
		
	cnf = File.ReadString(Starter.hostPath, "cnf.44")
	
	parser.Initialize(cnf)

	Dim root As Map = parser.NextObject
	Dim showPromote As Map = root.Get("showPromote")
	Dim digitalFont As Map = root.Get("digitalFont")
	Dim fontColor As Map = root.Get("fontColor")
'	Dim colorYellow As String = fontColor.Get("colorYellow")
	
	Dim message As Map = root.Get("message")
'	Dim line_1 As String = message.Get("line_1")
'	Dim line_2 As String = message.Get("line_2")
'	Dim line_5 As String = message.Get("line_5")
'	Dim line_3 As String = message.Get("line_3")
'	Dim line_4 As String = message.Get("line_4")
	
	
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
	
	message.Put("line_1", msg.Get(0))
	message.Put("line_2", msg.Get(1))
	message.Put("line_3", msg.Get(2))
	message.Put("line_4", msg.Get(3))
	message.Put("line_5", msg.Get(4))
	
	Dim JSONGenerator As JSONGenerator
	JSONGenerator.Initialize(root)
	
	File.WriteString(Starter.hostPath, "cnf.44", JSONGenerator.ToPrettyString(2))
	Sleep(50)
	#if debug
		Return
	#End If
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