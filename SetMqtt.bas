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

Sub GenMqttFile(ip As String, clientIp As String, enabled As String)
	Dim strMqtt As String = File.ReadString(File.DirAssets, "mqtt.conf")
	
	Dim pushTo As String
	Dim lst As List = gnDb.getUnit(ip)
	If clientIp = "0.0.0.0" Then
		pushTo = ip
		ip = clientIp
	Else
		pushTo = clientIp	
	End If
	
	parser.Initialize(strMqtt)
	Dim root As Map = parser.NextObject
	Dim mqttClients As Map = root.Get("mqttClients")
	
	mqttClients.Put("server", ip.Replace(".", "_"))
	mqttClients.Put("enabled", enabled)
	mqttClients.Put("name", lst.Get(0))
	JSONGenerator.Initialize(root)
	
	File.WriteString(Starter.hostPath, "mqtt.conf", JSONGenerator.ToPrettyString(2))
	Sleep(50)
	
	wait for (PushMqttFile(pushTo)) Complete (result As Boolean)
End Sub

Private Sub PushMqttFile(clientIp As String)As ResumableSub
	ftp.Initialize("ftp", "pi", "0", clientIp, 22)
	
	ftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
	
	
	ftp.UploadFile(Starter.hostPath, "mqtt.conf", "/home/pi/44/mqtt.conf")
	
	Wait For ftp_UploadCompleted (ServerPath As String, Success As Boolean)
	If Success = False Then
		ftp.Close
		Return Success
	Else
		ftp.Close
		Return Success
	End If
End Sub

Sub ftp_PromptYesNo (Message As String)
	ftp.SetPromptResult(True)
End Sub

