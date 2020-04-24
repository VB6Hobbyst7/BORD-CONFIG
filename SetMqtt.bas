B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.801
@EndOfDesignText@
Sub Class_Globals
	Private ftp As SFtp
	Private parser As JSONParser
	Private JSONGenerator As JSONGenerator
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

Sub GenMqttFile(ip As String, clientIp As String)
	Dim strMqtt As String = File.ReadString(File.DirAssets, "mqtt.conf")
	Dim pushTo As String
	
	If clientIp = "0.0.0.0" Then
		pushTo = ip
		ip = clientIp
	Else
		pushTo = clientIp	
	End If
	
	parser.Initialize(strMqtt)
	Dim root As Map = parser.NextObject
	Dim mqttClients As Map = root.Get("mqttClients")
	'Dim server As String = mqttClients.Get("server")
	'Dim enabled As String = mqttClients.Get("enabled")
	
	
	mqttClients.Put("server", ip.Replace(".", "_"))
	mqttClients.Put("enabled", "1")
	JSONGenerator.Initialize(root)
	
	File.WriteString(Starter.hostPath, "mqtt.conf", JSONGenerator.ToPrettyString(2))
	Sleep(50)
	
	'PushMqttFile(pushTo)
'	Log($"start $DateTime{DateTime.Now}"$)
	wait for (PushMqttFile(pushTo)) Complete (result As Boolean)
'	Log($"end $DateTime{DateTime.Now}"$)
End Sub

Private Sub PushMqttFile(clientIp As String)As ResumableSub
	ftp.Initialize("ftp", "pi", "0", clientIp, 22)
	
	ftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
	
	
	ftp.UploadFile(Starter.hostPath, "mqtt.conf", "/home/pi/44/mqtt.conf")
	
	Wait For ftp_UploadCompleted (ServerPath As String, Success As Boolean)
	If Success = False Then
		ftp.Close
		Log(LastException.Message)
		Log($"ftp success false $DateTime{DateTime.Now}"$)
		Return Success
	Else
		ftp.Close
		Log($"ftp success true $DateTime{DateTime.Now}"$)
		Return Success
'		ToastMessageShow($"Configuratie ${bordNaam} verzonden"$, False)
	End If
	
	'ftp.Close
End Sub

Sub ftp_PromptYesNo (Message As String)
	ftp.SetPromptResult(True)
End Sub

