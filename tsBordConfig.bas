B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region
'#IgnoreWarnings: 10, 11, 12 , 20
#Extends: android.support.v7.app.AppCompatActivity

Sub Process_Globals
	Private clsJson As classGetConfig
	Private ftp As SFtp
	Private clsFunc As classFunc
	Dim clsPutJson As classSetConfig
	Dim lstActiveBords As List
End Sub

Sub Globals
	Private tsConfig As TabStrip
	Private toolbar As ACToolBarDark
	Private svSettings As ScrollView
	Private lbl_bord_naam As Label
	Private lbl_ip_nummer As Label
	Private edt_timeout As EditText
	Private lbl_digital As Label
	Private lbl_spel_duur As Label
	Private lbl_sponsor As Label
	Private lbl_timeout As Label
	Private lbl_timeout_min As Label
	Private lbl_timeout_plus As Label
	Private lbl_to_minutes As Label
	Private lbl_yellow As Label
	Private sw_digital_numbers As B4XSwitch
	Private sw_game_time As B4XSwitch
	Private sw_timeout As B4XSwitch
	Private sw_toon_sponsor As B4XSwitch
	Private sw_use_yellow_number As B4XSwitch
	Private edt_regel_1 As EditText
	Private edt_regel_2 As EditText
	Private edt_regel_3 As EditText
	Private edt_regel_4 As EditText
	Private edt_regel_5 As EditText
	Private btn_save As Label
	Private chk_alle_borden As CheckBox
	Private sw_retro As B4XSwitch
	Private lbl_ip_nummer1 As Label
	Private lbl_bord_naam1 As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("tsBordConfig")
	'chk_alle_borden.Initialize("")
	toolbar.Elevation = 0
	
	clsJson.Initialize
	clsFunc.Initialize
	clsPutJson.Initialize
	svSettings.Initialize(100)
''	chk_alle_borden.Enabled = True
	tsConfig.LoadLayout("configMain", "Instellingen")
	tsConfig.LoadLayout("confScreenSaver", "ScreenSaver")
	
	
	svSettings.Panel.LoadLayout("conf_switch")
	
	lbl_bord_naam.Text = Starter.selectedBordName
	lbl_ip_nummer.Text = Starter.selectedBordIp
	
	lbl_bord_naam1.Text = Starter.selectedBordName
	lbl_ip_nummer1.Text = Starter.selectedBordIp
	
''	chk_alle_borden.Enabled = False
	btn_save.Enabled = False
	btn_save.Color = Colors.Red
	btn_save.TextColor = Colors.White
	
'	Log(Starter.lstActiveBord.IndexOf(Starter.selectedBordIp))
	'Log(Starter.lstActiveBord.Size)
''	chk_alle_borden.Enabled = False
'''	chk_alle_borden.Enabled = Starter.lstActiveBord.Size > 1
	CheckBordActive
	
	For i = 0 To Starter.lstActiveBord.Size - 1
		Log($"IP NUMBER = ${Starter.lstActiveBord.Get(i)}"$)
	Next
	
	Dim bordCount As Int = Starter.lstActiveBord.Size
	
	If bordCount = 1 Then
		chk_alle_borden.Enabled = False
	Else
		chk_alle_borden.Enabled = True
	End If
	
End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean
 
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		If tsConfig.CurrentPage = 1 Then
			tsConfig.ScrollTo(0, True)
			Return True
		End If
		Return False
	Else
		Return False
	End If
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub




Sub getConfig
	clsJson.parseConfig(sw_timeout, edt_timeout, sw_digital_numbers, sw_use_yellow_number, sw_toon_sponsor, sw_game_time, sw_retro)
End Sub


Sub ftp_PromptYesNo (Message As String)
	Log(Message)
	
	ftp.SetPromptResult(True)
End Sub

Sub retrieveConfig(ipNumber As String)
	Dim msg, unit As String
	unit = Starter.selectedBordName
	
	wait For(clsFunc.pingBord(ipNumber)) Complete (result As Boolean)
	If result = False Then
		clsFunc.createCustomToast($"${unit} niet bereikbaar"$, Colors.Red)
		Return
	End If
	ftp.Initialize("ftp", "pi", "0", ipNumber, 22)
	
	Try
		ftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
	Catch
		msg =$"${unit} niet bereikbaar"$
		
		clsFunc.createCustomToast(msg, Colors.Red)
		ftp.Close
		Return
	End Try

'	ftp.List("/home/pi/44/")
'
'	Wait For ListCompleted (ServerPath As String, Success As Boolean, Folders() As SFtpEntry, Files() As SFtpEntry)

	ftp.DownloadFile("/home/pi/44/cnf.44", Starter.hostPath, "cnf.44")
	ftp.DownloadFile("/home/pi/44/ver.pdg", Starter.hostPath, "ver.pdg")
'	ftp.DownloadFile("/home/pi/score/cnf.44", Starter.hostPath, "cnf.44")
'	ftp.DownloadFile("/home/pi/score/ver.pdg", Starter.hostPath, "ver.pdg")
	
	
	wait for ftp_DownloadCompleted (ServerPath As String, Success As Boolean)
	If Success = False Then
		Log(ServerPath)
		msg =$"Config bestand van ${unit} niet gevonden"$
		clsFunc.createCustomToast(msg, Colors.Red)
	Else
		getConfig
		ftp.Close
		
		msg =$"Configuratie van ${unit} geladen"$
	End If
	
End Sub

Sub setMeassage(msg As List)
	edt_regel_1.Text = msg.Get(0)
	edt_regel_2.Text = msg.Get(1)
	edt_regel_3.Text = msg.Get(2)
	edt_regel_4.Text = msg.Get(3)
	edt_regel_5.Text = msg.Get(4)
	
End Sub


Sub btn_save_Click
	'clsPutJson.parseConfig(chk_timeout_active, edt_timeout, chk_use_digital)
	Dim msgList, lstBord As List
	msgList.Initialize
	msgList.AddAll(Array As String(edt_regel_1.text, edt_regel_2.text, edt_regel_3.text, edt_regel_4.text, edt_regel_5.text))
	
	If chk_alle_borden.Checked = False Then
		ToastMessageShow($"Configuratie ${Starter.selectedBordName} bijwerken"$, True)
		clsPutJson.ipNumber = Starter.selectedBordIp
		clsPutJson.parseConfig(sw_timeout, edt_timeout, sw_digital_numbers, sw_use_yellow_number, msgList, sw_toon_sponsor, sw_game_time, sw_retro)
		'userMessage
	Else
		Dim naam, ip, lstStr As String
		Dim lstUnit As List

	'	Log($"START TIME : $Time{DateTime.Now}"$)
		For i = 0 To Starter.lstActiveBord.Size - 1
			lstUnit = gnDb.getUnit(Starter.lstActiveBord.Get(i))	
			naam = lstUnit.Get(0)
			ip = lstUnit.Get(1)
	'		Log($"TSCONFIG IP NUMBER : ${ip} - $Time{DateTime.Now}"$)
			clsPutJson.bordNaam = naam
			clsPutJson.ipNumber = ip
			ToastMessageShow($"Configuratie ${naam} bijwerken"$, False)
			clsPutJson.parseConfig(sw_timeout, edt_timeout, sw_digital_numbers, sw_use_yellow_number, msgList, sw_toon_sponsor, sw_game_time, sw_retro)
			'wait for (clsPutJson.parseConfig(sw_timeout, edt_timeout, sw_digital_numbers, sw_use_yellow_number, msgList, sw_toon_sponsor, sw_game_time, sw_retro)) Complete (result As Boolean)
			Sleep(2000)
		Next
		Log($"END TIME : $Time{DateTime.Now}"$)
		

	End If
End Sub

Private Sub CheckBordActive
	If Starter.lstActiveBord.IndexOf(Starter.selectedBordIp) > -1 Then
		btn_save.Enabled = True
		btn_save.TextColor = 0xFFA0B7D7'Colors.Yellow
		btn_save.Color = 0xFF004BA0'Colors.Blue
		retrieveConfig(Starter.selectedBordIp)
		EnableControls(True)
	Else
		EnableControls(False)
	End If
End Sub

Private Sub EnableControls(enable As Boolean)
	sw_digital_numbers.Enabled = enable
	sw_use_yellow_number.Enabled = enable
	sw_toon_sponsor.Enabled = enable
	sw_game_time.Enabled = enable
	sw_timeout.Enabled = enable
	
''	chk_alle_borden.Enabled =  Starter.lstActiveBord.Size > 1
	
	edt_timeout.Enabled = False
	lbl_timeout_min.Enabled = enable
	lbl_timeout_plus.Enabled = enable
	
	
	edt_regel_1.Enabled = enable
	edt_regel_2.Enabled = enable
	edt_regel_3.Enabled = enable
	edt_regel_4.Enabled = enable
	edt_regel_5.Enabled = enable
	
End Sub

Sub lbl_timeout_min_Click
	setNewTimeOut(-Abs(1))
End Sub

Sub lbl_timeout_plus_Click
	setNewTimeOut(1)
End Sub

Sub setNewTimeOut(newValue As Int)
	Dim oldTimeOut As Int = edt_timeout.Text
	Dim newTimeOut As Int
	
	edt_timeout.Text = oldTimeOut + newValue
	newTimeOut = edt_timeout.Text
	
	If newTimeOut < 1 Then
		edt_timeout.Text = "0"
		sw_timeout.Value = False
		Return
	End If
	
	If newTimeOut >= 60 Then
		edt_timeout.Text = "60"
		sw_timeout.Value = True
		Return
	End If
	
	sw_timeout.Value = True
End Sub



