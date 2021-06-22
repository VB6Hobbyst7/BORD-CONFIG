B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9.801
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: false
#End Region
#Extends: android.support.v7.app.AppCompatActivity
Sub Process_Globals
	Dim mqttTimeOut As Timer

End Sub

Sub Globals
	Private mqttClient As MqttConnector
	Private baseName As String
	Private subscribeStr As String = "pdeg/code/bord"
	'Private mqtt As mqttBase
	Private func As classFunc
	Private serializer As B4XSerializator
	Private sftp As SFtp
	Private access As Accessibility
	
	Private bordIp As String
	Private p1Make As B4XFloatTextField
	Private p1Name As B4XFloatTextField
	Private p2Make As B4XFloatTextField
	Private p2Name As B4XFloatTextField
	Private ime As IME
	Private btnP1Start As ACFlatButton
	Private btnP2Start As ACFlatButton
	Private b4xCombo As B4XComboBox
	Private pnlClearFields As Panel
	Private txtColor As Long
	Private baseName, currBordName As String
	Private pnlUpdateNames As Panel
	Private B4XLoadingIndicator1 As B4XLoadingIndicatorBiljartBall
	Private B4XLoadingIndicator2 As B4XLoadingIndicatorBiljartBall
	Private pnlNobords As Panel
End Sub

Sub Activity_Create(FirstTime As Boolean)
'	Dim x As String = func.GetBaseName
	Activity.LoadLayout("bordSetName")
'	Log(access.GetUserFontScale)
	p1Name.TextField.TextSize = p1Name.TextField.TextSize / access.GetUserFontScale
	p2Name.TextField.TextSize = p2Name.TextField.TextSize / access.GetUserFontScale
	p2Make.TextField.TextSize = p2Make.TextField.TextSize / access.GetUserFontScale
	p1Make.TextField.TextSize = p1Make.TextField.TextSize / access.GetUserFontScale
	
	ResetUserFontScale(Activity)
	func.Initialize
'	baseName = "pdeg" 'func.GetBaseName
	baseName = func.GetBaseName
	Log(baseName)
	If baseName <> "" Then
		mqttClient.Initialize("tcp://pdeg3005.mynetgear.com", 1883, baseName&"/", "", "", Me, "UpdateBordWhenClient")
	End If

	txtColor = p1Name.TextField.TextColor
	'func.Initialize
	ime.Initialize("IME")
	ime.AddHeightChangedEvent
	IME_HeightChanged(100%y, 0)
	GetBorden
	SetViewState(False)
	mqttTimeOut.Initialize("mqttTimeOut", 6000)
	'https://www.b4x.com/android/forum/threads/programmatically-open-a-b4xcombobox.117765/#post-736803
	Dim jo As JavaObject = b4xCombo.cmbBox
	jo.RunMethod("performClick", Null)
	
End Sub

Sub ResetUserFontScale(p As Panel)
	For Each v As View In p
		If v Is Panel Then
			ResetUserFontScale(v)
		Else If v Is Label Then
			Dim lbl As Label = v
			lbl.TextSize = lbl.TextSize / access.GetUserFontScale
		Else If v Is Spinner Then
			Dim s As Spinner = v
			s.TextSize = s.TextSize / access.GetUserFontScale
		'Else If v Is B4XFloatTextField Then
			'Dim ftf As B4XFloatTextField = v
			'ftf.TextField.TextSize = ftf.TextField.TextSize / access.GetUserFontScale
		End If
	Next
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Private Sub mqttTimeOut_Tick
	mqttTimeOut.Enabled = False
	mqttClient.Disconnect
	SetGetPlayerData(False)
	SetViewState(False)
	Msgbox2Async("Kan spelers namen niet ophalen", Application.LabelName, "OKE", "", "", Application.Icon, False)
End Sub

Private Sub GetBorden
	Dim lstBorden As List
	Dim bordName As String
	Dim curs As Cursor = gnDb.RetieveBoards
	
	If curs.RowCount = 0 Then
		Msgbox2Async("Geen borden gevonden", Application.LabelName, "OKE", "", "", Application.Icon, False)
		Return
	End If
	
	curs.Position = 0
	lstBorden.Initialize
	lstBorden.Add("")
	For i = 0 To curs.RowCount - 1
		curs.Position = i
		bordName = curs.GetString("description")
		If CheckBordOnline(bordName) Then
			lstBorden.Add(bordName)
		End If
	Next
	curs.Close
	
	b4xCombo.SetItems(lstBorden)
End Sub

Private Sub CheckBordOnline(name As String) As Boolean
	Dim curs As Cursor = gnDb.RetrieveBordIp(name)
	Dim ipNumber As String
	If curs.RowCount = 0 Then Return False
	
	curs.Position = 0
	ipNumber = curs.GetString("ip_number")

	If Starter.lstActiveBord.IndexOf(ipNumber) <> -1 Then
		Return True
	End If
	
	Return False
End Sub

Sub sprBorden_ItemClick (Position As Int, Value As Object)
	GetBordIp(Value)
	p1Name.TextField.RequestFocus
End Sub

Private Sub GetBordIp(value As String)
	Dim curs As Cursor = gnDb.RetrieveBordIp(value)
	If curs.RowCount = 0 Then
		'doe iets
		Return
	End If
	curs.Position = 0
	bordIp = curs.GetString("ip_number")
	curs.Close
End Sub

Sub IME_HeightChanged(NewHeight As Int, OldHeight As Int)
'	btnP1Start.Top = (NewHeight - btnP1Start.Height)' - btnP1Start.Height
'	btnP2Start.Top = (NewHeight - btnP2Start.Height)' - btnP2Start.Height
End Sub

Sub btnP2Start_Up
	Dim valid As String = ValidateFields
	If valid <> "valid" Then
		Msgbox2Async(valid, Application.LabelName, "OKE", "", "", Application.Icon, False)
		Return	
	End If
	
	CreateMqttBaseJson(2)
End Sub

Sub btnP1Start_Up
	Dim valid As String = ValidateFields
	If valid <> "valid" Then
		Msgbox2Async(valid, Application.LabelName, "OKE", "", "", Application.Icon, False)
		Return
		
	End If
	CreateMqttBaseJson(1)
End Sub

Private Sub SetViewState(state As Boolean)
	btnP1Start.Enabled = state
	btnP2Start.Enabled = state
	p1Name.TextField.Enabled = state
	p2Name.TextField.Enabled = state
	p1Make.TextField.Enabled = state
	p2Make.TextField.Enabled = state
	p1Name.TextField.RequestFocus
End Sub

Sub b4xCombo_SelectedIndexChanged (Index As Int)
	pnlClearFields_Click
	If b4xCombo.GetItem(Index) = "" Then
		currBordName = ""
		Return
	End If
	GetBordIp(b4xCombo.GetItem(Index))
	SetViewState(Index > 0)
	ime.ShowKeyboard(p1Name.TextField)
	currBordName = b4xCombo.GetItem(Index)
	If Index > 0 Then
		GetPlayerData(b4xCombo.GetItem(Index))
	End If
End Sub

Private Sub GetPlayerData(bordName As String)
	SetGetPlayerData(True)
	If currBordName = "" Then Return
	subscribeStr = $"pdeg/${baseName}/recvdata_${bordName.Replace(" ", "").ToLowerCase}"$
'	mqttClient.SetSubcribe( $"pdeg/${baseName}/recvdata_${bordName.Replace(" ", "").ToLowerCase}"$)
Log(subscribeStr)
	mqttClient.SetSubcribe(subscribeStr)
	mqttClient.Connect
	Sleep(400)
	
'	mqttClient.SendMessage("players please")
	
	
End Sub

Private Sub SetGetPlayerData(status As Boolean)
	ime.HideKeyboard
	mqttTimeOut.Enabled = status
	B4XLoadingIndicator1.Show
	B4XLoadingIndicator2.Show
	pnlNobords.SetVisibleAnimated(1000, status)
	Sleep(1750)
End Sub

Private Sub CreateMqttBaseJson(pStart As Int)
	Msgbox2Async("Namen op geselecteerde bord zetten", Application.LabelName, "JA", "", "NEE", Application.Icon, False)
	Wait For Msgbox_Result (Result As Int)
	If Result = DialogResponse.NEGATIVE Then
		Return
	End If
	
	Dim mqttMap As Map
	Dim baseMap As Map
	Dim baseList As List
	Dim jsonGen As JSONGenerator
	Dim strP1Make, strP2Make As String
		
	strP1Make = func.padString(p1Make.TextField.Text, "0", 0, 3)
	strP2Make = func.padString(p2Make.TextField.Text, "0", 0, 3)
	
	baseList.Initialize
	mqttMap.Initialize

	If pStart = 1 Then
		mqttMap.Put("p1Name", p1Name.TextField.Text)
		mqttMap.Put("p1Make", strP1Make)
		mqttMap.Put("p2Name", p2Name.TextField.Text)
		mqttMap.Put("p2Make", strP2Make)
	Else
		mqttMap.Put("p1Name", p2Name.TextField.Text)
		mqttMap.Put("p1Make", strP2Make)
		mqttMap.Put("p2Name", p1Name.TextField.Text)
		mqttMap.Put("p2Make", strP1Make)
	End If
	baseList.Add(mqttMap)
		
	baseMap.Initialize
	'baseMap.Put("base", baseList)
	baseMap.Put("player", mqttMap)
				
	jsonGen.Initialize(baseMap)
'	Log(jsonGen.ToString)
	File.WriteBytes(Starter.hostPath, "player-config", serializer.ConvertObjectToBytes(jsonGen.ToString))
	Sleep(300)
	UploadPlayers
End Sub

Private Sub UploadPlayers
	sftp.Initialize("sftp", "pi", "0", bordIp, 22)
	sftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
	sftp.UploadFile(Starter.hostPath, "player-config", "/home/pi/44/player-config")
	
	Wait For sftp_UploadCompleted (ServerPath As String, Success As Boolean)
	If Success = False Then
		func.createCustomToast($"Bord niet bijgewerkt"$, Colors.Red)
		sftp.Close
	Else
		func.createCustomToast($"Bord bijgewerkt"$, Colors.Blue)
		sftp.Close
	End If
	If File.Exists(Starter.hostPath, "player-config") Then
		File.Delete(Starter.hostPath, "player-config")
	End If
End Sub

Sub sftp_PromptYesNo (Message As String)
	sftp.SetPromptResult(True)
End Sub

Sub pnlClearFields_Click
	p1Name.TextField.Text = ""
	p2Name.TextField.Text = ""
	p1Make.TextField.Text = ""
	p2Make.TextField.Text = ""
End Sub

Sub p1Name_TextChanged (Old As String, New As String)
	If New.Length >= 24 Then
		func.createCustomToast("Maak de naam niet langer dan 24 tekens", Colors.Red)
		p1Name.TextField.TextColor = Colors.Red
	Else
		p1Name.TextField.TextColor = txtColor
	End If
End Sub

Sub p2Name_TextChanged (Old As String, New As String)
	If New.Length >= 24 Then
		func.createCustomToast("Maak de naam niet langer dan 24 tekens", Colors.Red)
		p2Name.TextField.TextColor = Colors.Red
	Else
		p2Name.TextField.TextColor = txtColor
	End If
End Sub

Private Sub ValidateFields As String
	If p1Name.TextField.Text = "" Then
		Return "Naam Speler 1 is leeg"
	End If
	
	If p1Make.TextField.Text = "" Then
		Return "Speler 1 te maken is leeg"
	End If
	
	If p2Name.TextField.Text = "" Then
		Return "Naam Speler 2 is leeg"
	End If
		
	If p2Make.TextField.Text = "" Then
		Return "Speler 2 te maken is leeg"
	End If
	
	Return "valid"
End Sub

public Sub UpdateBordWhenClient(data As String)
'	Log(data)
	If data = "players please" Or data = "data please" Then Return

	SetGetPlayerData(False)
	SetViewState(True)
	mqttClient.Disconnect
	Dim parser As JSONParser
	
	parser.Initialize(data)
	Dim root As Map = parser.NextObject
	Dim score As Map = root.Get("score")
	Dim p1 As Map = score.Get("p1")
	Dim p2 As Map = score.Get("p2")
	
	p1Name.TextField.Text = func.NameToCamelCase(p1.Get("naam"))
	p1Make.TextField.Text = p1.Get("maken")
	p2Name.TextField.Text = func.NameToCamelCase(p2.Get("naam"))
	p2Make.TextField.Text = p2.Get("maken")
	FormatText
	ime.ShowKeyboard(p1Name.TextField)
End Sub

Private Sub FormatText
	Dim make As Int
	
	p1Name.TextField.Text = p1Name.TextField.Text.Replace(CRLF, "")
	p2Name.TextField.Text = p2Name.TextField.Text.Replace(CRLF, "")
	
	make = p1Make.TextField.Text
	If make < 100 Then
		p1Make.TextField.Text = p1Make.TextField.Text.SubString(1)
	End If
	If make < 10 Then
		p1Make.TextField.Text = p1Make.TextField.Text.SubString(1)
	End If
	make = p2Make.TextField.Text
	If make < 100 Then
		p2Make.TextField.Text = p2Make.TextField.Text.SubString(1)
	End If
	If make < 10 Then
		p2Make.TextField.Text = p2Make.TextField.Text.SubString(1)
	End If
End Sub

Sub pnlUpdateNames_Click
	GetPlayerData(currBordName)
End Sub