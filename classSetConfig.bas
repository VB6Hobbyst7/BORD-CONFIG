B4A=true
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
	Public ipNumber, bordNaam As String
	Public updateResult As Int = 1
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	clsfunc.Initialize
End Sub


Sub parseConfig(swTimeOut As B4XSwitch, edtTimeOut As EditText, swUseDigital As B4XSwitch, swUseYellow As B4XSwitch, msg As List, swSponsor As B4XSwitch, swGameTime As B4XSwitch)
		
	cnf = File.ReadString(Starter.hostPath, "cnf.44")
	
	parser.Initialize(cnf)

	Dim root As Map = parser.NextObject
	Dim showPromote As Map = root.Get("showPromote")
	Dim digitalFont As Map = root.Get("digitalFont")
	Dim fontColor As Map = root.Get("fontColor")
	Dim message As Map = root.Get("message")
	Dim sponsor As Map = root.Get("reclame")
	Dim gameTime As Map = root.Get("partijDuur")
	
	
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
	
	If swSponsor.Value = True Then
		sponsor.Put("active", "1")
	Else
		sponsor.Put("active", "0")
	End If
	
	If swGameTime.Value = True Then
		gameTime.Put("active", "1")
		Else
		gameTime.Put("active", "0")
	End If
	
	Dim JSONGenerator As JSONGenerator
	JSONGenerator.Initialize(root)
	
	File.WriteString(Starter.hostPath, "cnf.44", JSONGenerator.ToPrettyString(2))
	Sleep(50)
	#if debug
	'Return
	#End If
	pushConfig
End Sub
	
Sub pushConfig
	ftp.Initialize("ftp", "pi", "0", ipNumber, 22)
	ftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
	updateResult = 0
	
	ftp.UploadFile(Starter.hostPath, "cnf.44", "/home/pi/44/cnf.44")
	'ftp.UploadFile(Starter.hostPath, "cnf.44", "/home/pi/score/cnf.44")
	Wait For ftp_UploadCompleted (ServerPath As String, Success As Boolean)
	If Success = False Then
		Log(LastException.Message)
		ToastMessageShow($"Configuratie ${bordNaam} niet verzonden"$, False)		
'		clsfunc.createCustomToast("Configuratie niet verzonden", Colors.Red)
		updateResult = 1
	Else
		
		'clsfunc.createCustomToast("Configuratie verzonden", Colors.Blue)
		updateResult = 2
		ToastMessageShow($"Configuratie ${bordNaam} verzonden"$, False)		
		
	End If
	
	ftp.Close
	
	
	
End Sub

Sub ftp_PromptYesNo (Message As String)
	ftp.SetPromptResult(True)
End Sub

