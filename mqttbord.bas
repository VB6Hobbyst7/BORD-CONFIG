B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9.801
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region
#Extends: android.support.v7.app.AppCompatActivity

Sub Process_Globals
End Sub

Sub Globals
	Private fltCode As B4XFloatTextField
	Private pnlMqttBord As Panel
	Private swMqtt As B4XSwitch
	Private clvMqtt As CustomListView
	Private lblBordName As Label
	Private serializer As B4XSerializator
	Private currBaseName As String
	Private lblDeelCodeInfo As Label
	Private sftp As SFtp
	Private func As classFunc
	Private lblPanel As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	func.Initialize
	currBaseName = func.GetBaseName
	Activity.LoadLayout("mqttbord")
	fltCode.Text = currBaseName
	GetBord
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub GetBord
	Dim viewWidth As Int = clvMqtt.AsView.Width
	clvMqtt.Clear
	
	Dim curs As Cursor = gnDb.RetieveBoards
	
	If curs.RowCount = 0 Then
		Return
	End If
	
	For i = 0 To curs.RowCount - 1
		curs.Position = i
		clvMqtt.Add(genUnit(curs.GetString("description"), curs.GetString("ip_number"), curs.GetString("version"), viewWidth), "")
	Next
End Sub

Sub genUnit(description As String, ip As String, mqtt As String, width As Int) As Panel
	Dim p As Panel
	p.Initialize(Me)
	p.SetLayout(0dip, 0dip, width, 70dip)
	p.LoadLayout("clvMqttBord")
	
	lblBordName.Text = description
	p.Tag = ip
	swMqtt.Tag = "switch"
	If mqtt <> Null Then
		If mqtt = 1 Then
			swMqtt.Value = True
		Else	
			swMqtt.Value = False
		End If
	Else
		swMqtt.Value = False
	End If
	

	Return p
End Sub

Sub fltCode_EnterPressed
	Dim msg As String
	
	If fltCode.Text <> currBaseName Then
		msg = $"De deelcode is anders dan de deelcode in gebruik, reeds gedeelde borden bijwerken?"$
'		Msgbox2Async(msg, Application.LabelName, "JA", "ANNULEER", "NEE", Application.Icon, False)
'		Wait For msgBox_result(result As Int)
'		If result = DialogResponse.POSITIVE Then
'			CreateMqttBaseJson
'			'Update Shared bords
'		Else If result = DialogResponse.CANCEL Then
'			Return
'		Else If result = DialogResponse.NEGATIVE Then
'			CreateMqttBaseJson
'		End If
		CreateMqttBaseJson
	End If
	
End Sub

Sub fltCode_TextChanged (Old As String, New As String)
	
End Sub

Sub lblPanel_Click
	
End Sub

Sub pnlMqttBord_Click
	Dim index As Int = clvMqtt.GetItemFromView(Sender)
	Dim pnl As Panel = clvMqtt.GetPanel(index)
	Dim ip As String = pnl.Tag
	Dim bordName As String
	Dim sw As B4XSwitch
	Dim lbl As Label
	
	For Each v As B4XView In pnl.GetAllViewsRecursive
		If v.tag Is B4XSwitch Then
			sw = v.Tag
			If sw.Value = True Then
				sw.Value = False
			Else
				sw.Value = True
			End If
		Exit
		End If
	Next

	For Each v1 As View In pnl.GetAllViewsRecursive
		If v1.Tag = "name" Then
			lbl = v1
			bordName = lbl.Text	
			Exit
		End If
	Next

	UpdateBordMqtt(sw.Value, ip, bordName)	
End Sub

Private Sub GetBaseName
	Dim baseBytes() As Byte
	
	If File.Exists(Starter.hostPath, "base-config") Then
		baseBytes = File.ReadBytes(Starter.hostPath, "base-config")
		GetBaseNameFromBytes(serializer.ConvertBytesToObject(baseBytes))
		Log(currBaseName)
	End If
End Sub

Private Sub CreateMqttBaseJson
	Dim mqttMap As Map
	Dim baseMap As Map
	Dim baseList As List
	Dim jsonGen As JSONGenerator
		
	baseList.Initialize
	mqttMap.Initialize

	mqttMap.Put("baseName", fltCode.Text)
	baseList.Add(mqttMap)
		
	baseMap.Initialize
	baseMap.Put("base", baseList)
				
	jsonGen.Initialize(baseMap)
	
	File.WriteBytes(Starter.hostPath, "base-config", serializer.ConvertObjectToBytes(jsonGen.ToString))
End Sub

Private Sub GetBaseNameFromBytes(baseFile As String)
	If baseFile.Length = 0 Then Return
	
	Dim parser As JSONParser
	parser.Initialize(baseFile)
	Dim root As Map = parser.NextObject
	Dim baseJ As List = root.Get("base")
	For Each colbase As Map In baseJ
		currBaseName = colbase.Get("baseName")
	Next
End Sub

Sub lblDeelCodeInfo_Click
	Dim msg As String = $"De deelcode is nodig om gebruikers van de "Bord Op Droid" applicatie toegang te geven tot de borden"$
	Msgbox2Async(msg, Application.LabelName, "OKE", "", "", Application.Icon, False)
End Sub

Private Sub UpdateBordMqtt(enable As Boolean, ip As String, name As String)
	Dim mqttMap As Map
	Dim baseMap As Map
	Dim baseList As List
	Dim jsonGen As JSONGenerator
	Dim strEnable As String = "0"
	
	If enable = True Then
		strEnable = "1"	
	End If
		
	baseList.Initialize

	mqttMap.Initialize
	mqttMap.Put("base", fltCode.Text)
	mqttMap.Put("server", "0_0_0_0")
	mqttMap.Put("enabled", strEnable)
	mqttMap.Put("name", name)
	baseList.Add(mqttMap)
		
	baseMap.Initialize
	baseMap.Put("mqttClients", baseList)
				
	jsonGen.Initialize(baseMap)
'	Log(jsonGen.ToPrettyString(4))
	
	File.WriteString(Starter.hostPath, "mqtt-temp", jsonGen.ToPrettyString(4))
	SetMqttToBord(ip, name, strEnable)
	Sleep(100)
End Sub

Private Sub SetMqttToBord(ip As String, bordName As String, enable As String)
	sftp.Initialize("sftp", "pi", "0", ip, 22)
	sftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
	
	sftp.UploadFile(Starter.hostPath, "mqtt-temp", "/home/pi/44/mqtt.conf")
	
	Wait For sftp_UploadCompleted (ServerPath As String, Success As Boolean)
	If Success = False Then
		func.createCustomToast($"Bord ${bordName} niet bijgewerkt"$, Colors.Red)
		sftp.Close
	Else 
		func.createCustomToast($"Bord ${bordName} bijgewerkt"$, Colors.Blue)
		sftp.Close	
		gnDb.updateMqttStatus(bordName, enable)
		If File.Exists(Starter.hostPath, "mqtt-temp") Then
			File.Delete(Starter.hostPath, "mqtt-temp")
		End If
		Starter.bordAdded = True
	End If
	
End Sub

Sub sftp_PromptYesNo (Message As String)
	sftp.SetPromptResult(True)
End Sub



