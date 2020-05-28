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
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub

Sub Globals
	Private mqttClient As MqttClient
	Private baseName As String
	Private subscribeStr As String = "pdeg/code/bord"
	Private mqtt As mqttBase
	Private func As classFunc
	Private serializer As B4XSerializator
	Private sftp As SFtp
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
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("bordSetName")
	
	mqtt.Initialize
	txtColor = p1Name.TextField.TextColor
	func.Initialize
	ime.Initialize("IME")
	ime.AddHeightChangedEvent
	IME_HeightChanged(100%y, 0)
	GetBorden
	SetViewState(False)
	'https://www.b4x.com/android/forum/threads/programmatically-open-a-b4xcombobox.117765/#post-736803
	Dim jo As JavaObject = b4xCombo.cmbBox
	jo.RunMethod("performClick", Null)
	
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

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
	GetBordIp(b4xCombo.GetItem(Index))
	SetViewState(Index > 0)
	ime.ShowKeyboard(p1Name.TextField)
	If Index > 0 Then
		GetPlayerData(b4xCombo.GetItem(Index))
	End If
End Sub

Private Sub GetPlayerData(bordName As String)
	subscribeStr = $"pdeg/getdata/${bordName}"$
	
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