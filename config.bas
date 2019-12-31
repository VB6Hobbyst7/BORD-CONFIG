B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: True
	#IncludeTitle: False
#End Region
#IgnoreWarnings: 10, 20
#Extends: android.support.v7.app.AppCompatActivity
Sub Process_Globals
	Dim clsJson As classGetConfig
	Dim clsPutJson As classSetConfig
	Dim clsUpdate As classGetLatestVersion
	Dim clsC As classCrypt
	Dim ftp As SFtp
	Dim lstDisplay, lstValue As List
	Dim clsFunc As classFunc
	Dim access As Accessiblity
	
End Sub

Sub Globals
	Public msgMaxCharacter As Long = 40
	Public chk_timeout_active As CheckBox
	Public edt_timeout As EditText
	Private chk_use_digital As CheckBox
	Private btn_saveA As Button
	Private cmb_units As B4XComboBox
	Private ProgressBar As ProgressBar
	Private btn_add As Button
	Private btn_remove As Button
	Private svInput As ScrollView
	Private pnl_config As Panel
	Private sw_use_yellow_number As B4XSwitch
	Private sw_digital_numbers As B4XSwitch
	Private sw_timeout As B4XSwitch
	Private lbl_timeout_min As Label
	Private lbl_timeout_plus As Label
	Private edt_regel_1 As EditText
	Private edt_regel_2 As EditText
	Private edt_regel_3 As EditText
	Private edt_regel_4 As EditText
	Private edt_regel_5 As EditText
	Private sw_toon_sponsor As B4XSwitch
	Private btn_edit As Button
	Private btn_update As Label
	
	Private btn_save As Label
	Private lbl_digital As Label
	Private lbl_yellow As Label
	Private lbl_sponsor As Label
	Private lbl_timeout As Label
	Private lbl_to_minutes As Label
	Private lbl_text_header As Label
	Private lbl_text_footer As Label
	Private sw_game_time As B4XSwitch
	Private chk_alle_borden As CheckBox
	Private tsConfig As TabStrip
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("configMain")

'	setFontSize
'	clsC.Initialize
'	clsC.test
	clsFunc.Initialize
	clsJson.Initialize
	clsPutJson.Initialize
	clsUpdate.Initialize
'	svInput.Panel.LoadLayout("configInput")
'	svInput.Panel.Height = 1000dip
'	getUnits
	
	tsConfig.LoadLayout("conf_switch", "schakelaars")
	tsConfig.LoadLayout("conf_screenSaver", "ScreenSaver")
	'getConfig
	
End Sub

Sub setFontSize
	lbl_yellow.Initialize("")
	lbl_digital.Initialize("")
	lbl_sponsor.Initialize("")
	lbl_timeout.Initialize("")
	lbl_to_minutes.Initialize("")
	lbl_text_header.Initialize("")
	lbl_text_footer.Initialize("")
	
	edt_regel_1.Initialize(Me)
	edt_regel_2.Initialize(Me)
	edt_regel_3.Initialize(Me)
	edt_regel_4.Initialize(Me)
	edt_regel_5.Initialize(Me)
	
	
	
	ResetUserFontScaleLabel(lbl_digital)
	ResetUserFontScaleLabel(lbl_yellow)
	ResetUserFontScaleLabel(lbl_sponsor)
	ResetUserFontScaleLabel(lbl_timeout)
	ResetUserFontScaleLabel(lbl_to_minutes)
	ResetUserFontScaleLabel(lbl_text_header)
	ResetUserFontScaleLabel(lbl_text_footer)
	
'	ResetUserFontScaleEdit(edt_timeout)
	ResetUserFontScaleEdit(edt_regel_1)
	ResetUserFontScaleEdit(edt_regel_2)
	ResetUserFontScaleEdit(edt_regel_3)
	ResetUserFontScaleEdit(edt_regel_4)
	ResetUserFontScaleEdit(edt_regel_5)
	
	
End Sub

Sub Activity_Resume
	If Starter.bordUpdate = False Then
		clearConfig
		enableView(False)
		getUnits
	Else
		Starter.bordUpdate = False
	End If
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub getConfig
	'clsJson.parseConfig(chk_timeout_active, edt_timeout, chk_use_digital)
	clsJson.parseConfig(sw_timeout, edt_timeout, sw_digital_numbers, sw_use_yellow_number, sw_toon_sponsor, sw_game_time)
End Sub

Sub btn_save_Click
	PerformHapticFeedback(btn_save)
	'clsPutJson.parseConfig(chk_timeout_active, edt_timeout, chk_use_digital)
	Dim msgList As List
	msgList.Initialize
	msgList.AddAll(Array As String(edt_regel_1.text, edt_regel_2.text, edt_regel_3.text, edt_regel_4.text, edt_regel_5.text))
	
	If chk_alle_borden.Checked = False Then
		clsPutJson.ipNumber = lstValue.get(cmb_units.SelectedIndex)
		clsPutJson.parseConfig(sw_timeout, edt_timeout, sw_digital_numbers, sw_use_yellow_number, msgList, sw_toon_sponsor, sw_game_time)
		userMessage
	Else
		For i = 1 To lstValue.Size - 1
			Sleep(500)
			clsPutJson.bordNaam = lstDisplay.Get(i)
			clsPutJson.ipNumber = lstValue.get(i)
			clsPutJson.parseConfig(sw_timeout, edt_timeout, sw_digital_numbers, sw_use_yellow_number, msgList, sw_toon_sponsor, sw_game_time)
			Wait For (userMessage) Complete (result As Boolean)
		Next
	End If
End Sub

Sub userMessage As ResumableSub
	
	If clsPutJson.updateResult = 2 Then
		Msgbox2Async("Configuratie niet verzonden", clsPutJson.bordNaam, "Oke", "", "", Null, False)
		Wait For Msgbox_Result (oke As Int)
		If oke = DialogResponse.POSITIVE Then
			Return True
		End If
	Else if clsPutJson.updateResult = 1 Then
		Msgbox2Async("Configuratie verzonden", clsPutJson.bordNaam, "Oke", "", "", Null, False)
		Wait For Msgbox_Result (oke As Int)
		If oke = DialogResponse.POSITIVE Then
			Return True
		End If
	End If
	Return True
End Sub

Sub getUnits
	'Dim lstDisplay, lstValue As List
	Dim curs As Cursor = gnDb.RetieveBoards
	
	lstDisplay.Initialize
	lstValue.Initialize
	
	lstDisplay.Add("Selecteer bord")
	lstValue.Add("0")
	
	For i = 0 To curs.RowCount - 1
		curs.Position = i
		lstDisplay.Add(curs.GetString("description"))
		lstValue.Add(curs.GetString("ip_number"))
	Next
	cmb_units.SetItems(lstDisplay)
	
	
	chk_alle_borden.Enabled = lstValue.Size > 2
	
	
End Sub

Sub cmb_units_SelectedIndexChanged (Index As Int)
	
	enableView(False)
	Dim value As String = lstValue.get(cmb_units.SelectedIndex)
	If value = "0" Then
		btn_update.SetVisibleAnimated(1000, False)
		btn_save.Enabled = False
		btn_save.Color = Colors.Gray
		btn_remove.Visible =False
		btn_edit.Visible = False
		Return
	End If
	
	btn_remove.Visible = True
	btn_edit.Visible = True
'	ProgressBar.Visible = True
	'Sleep(500)
	retrieveConfig(value)
'	ProgressBar.Visible = False
	
	
End Sub


Sub retrieveConfig(ipNumber As String)
'	#if debug
'	btn_save.Enabled = True
'	enableView(True)
'	getConfig
'	Return
'	#End If
	Dim msg, unit As String
	unit = cmb_units.GetItem(cmb_units.SelectedIndex)
	
	ProgressBar.Visible = True
	'Sleep(300)
	
	wait For(clsFunc.pingBord(ipNumber)) Complete (result As Boolean)
	If result = False Then
		ProgressBar.Visible = False
		clsFunc.createCustomToast($"${unit} niet bereikbaar"$, Colors.Red)
	Return
	End If
	btn_save.Enabled = False
	btn_save.Color = Colors.Gray
	ftp.Initialize("ftp", "pi", "0", ipNumber, 22)
	
	
	Try
		ftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
	Catch
		ProgressBar.Visible = False
		msg =$"${unit} niet bereikbaar"$
		
		clsFunc.createCustomToast(msg, Colors.Red)
		Msgbox(msg, "Bord Config")
		
		ftp.Close
		Return
	End Try

	ftp.DownloadFile("/home/pi/44/cnf.44", Starter.hostPath, "cnf.44")
	ftp.DownloadFile("/home/pi/44/ver.pdg", Starter.hostPath, "ver.pdg")
	
	wait for ftp_DownloadCompleted (ServerPath As String, Success As Boolean)
	If Success = False Then
		ProgressBar.Visible = False
		msg =$"Config bestand van ${unit} niet gevonden"$
		clsFunc.createCustomToast(msg, Colors.Red)
	Else
		ProgressBar.Visible = False
		enableView(True)
		getConfig
		ftp.Close
		btn_save.Enabled = True
		btn_save.Color = Colors.Blue
		
		msg =$"Configuratie van ${unit} geladen"$
		'Msgbox(msg, "Bord Config")
	'	clsFunc.createCustomToast(msg, Colors.Blue)
		bordVersion
		clsUpdate.retrieveVersion
	End If
	
End Sub


Sub bordVersion
	
	If File.Exists(Starter.hostPath, "ver.pdg") Then
		Starter.bordVersion = File.ReadString(Starter.hostPath, "ver.pdg")	
	End If
	
End Sub


Sub ftp_ShowMessage (Message As String)
	Msgbox(Message, "")
End Sub

Sub ftp_PromptYesNo (Message As String)
	Log(Message)
	
	ftp.SetPromptResult(True)
End Sub

Sub enableView(enable As Boolean)
	sw_timeout.Enabled = enable
	sw_timeout.Value = enable
	
	sw_digital_numbers.Enabled = enable
	sw_digital_numbers.Value = enable
	
	sw_use_yellow_number.Enabled = enable
	sw_use_yellow_number.Value = enable
	
	sw_toon_sponsor.Enabled = enable
	sw_toon_sponsor.Value = enable
	
	sw_game_time.Enabled = enable
	sw_game_time.Value = enable
	
	edt_timeout.Enabled = enable
	edt_timeout.Text = ""
	
	lbl_timeout_min.Enabled = enable
	lbl_timeout_plus.Enabled = enable
	
	edt_regel_1.Text = ""
	edt_regel_1.Enabled = enable
	
	edt_regel_2.Text = ""
	edt_regel_2.Enabled = enable
	
	edt_regel_3.Text = ""
	edt_regel_3.Enabled = enable
	
	edt_regel_4.Text = ""
	edt_regel_4.Enabled = enable
	
	edt_regel_5.Text = ""
	edt_regel_5.Enabled = enable
End Sub

Sub clearConfig
	sw_timeout.Enabled = False
	sw_digital_numbers.Enabled = False
	sw_use_yellow_number.Enabled = False
	sw_toon_sponsor.Enabled = False
	edt_timeout.Text = ""
End Sub

Sub btn_add_Click
	StartActivity(units)
End Sub

Sub btn_remove_Click
	Dim index As Int
	index = cmb_units.SelectedIndex
	Msgbox2Async("Bord verwijderen?", "Bord Config", "JA", "", "NEE", Null, False)
	Wait For Msgbox_Result (Result As Int)
	If Result = DialogResponse.POSITIVE Then
		gnDb.deleteBord(lstValue.get(index))
		enableView(False)
		getUnits
	End If
End Sub

Sub lbl_timeout_min_Click
	Dim timeOut As Int = edt_timeout.Text
	If timeOut = 0 Then 
		Return
	Else 
		edt_timeout.Text = timeOut - 1	
	End If
End Sub

Sub lbl_timeout_plus_Click
	Dim timeOut As Int = edt_timeout.Text
	edt_timeout.Text = timeOut + 1
End Sub

Sub edt_regel_1_TextChanged (Old As String, New As String)
	If clsFunc.countChars(New, msgMaxCharacter) = False Then
		edt_regel_1.Text = Old
		cursEOL(edt_regel_1)
	End If
End Sub

Sub edt_regel_5_TextChanged (Old As String, New As String)
	If clsFunc.countChars(New, msgMaxCharacter) = False Then
		edt_regel_5.Text = Old
		cursEOL(edt_regel_5)
	End If
End Sub

Sub edt_regel_4_TextChanged (Old As String, New As String)
	If clsFunc.countChars(New, msgMaxCharacter) = False Then
		edt_regel_4.Text = Old
		cursEOL(edt_regel_4)
	End If
End Sub

Sub edt_regel_3_TextChanged (Old As String, New As String)
	If clsFunc.countChars(New, msgMaxCharacter) = False Then
		edt_regel_3.Text = Old
		cursEOL(edt_regel_3)
	End If
End Sub

Sub edt_regel_2_TextChanged (Old As String, New As String)
	If clsFunc.countChars(New, msgMaxCharacter) = False Then
		edt_regel_2.Text = Old
		cursEOL(edt_regel_2)
	End If
End Sub

Sub cursEOL(v As EditText)
	v.SelectionStart = 40
End Sub


Sub setMeassage(msg As List)
	edt_regel_1.Text = msg.Get(0)
	edt_regel_2.Text = msg.Get(1)
	edt_regel_3.Text = msg.Get(2)
	edt_regel_4.Text = msg.Get(3)
	edt_regel_5.Text = msg.Get(4)
	
End Sub



Sub btn_edit_Click
	Dim lst As List
	
	Starter.edtUnit = True	
	Starter.edtIpNumber = lstValue.get(cmb_units.SelectedIndex)
'	lst.Initialize
'	
'	lst = gnDb.getUnit(Starter.edtIpNumber)
'	
'	CallSub2(units, "setFieldsEdt", lst)
	StartActivity(units)
	
End Sub

Sub updateAvailable
'	btn_update.SetVisibleAnimated(1000, False)
End Sub

Sub btn_update_Click
	StartActivity(update_bord)
End Sub

Sub ResetUserFontScaleLabel(lbl As Label)
	Dim fscale As Double
	fscale = access.GetUserFontScale

	lbl.TextSize = NumberFormat2(lbl.TextSize / fscale,1,0,0,False)

End Sub

Sub ResetUserFontScaleEdit(v As B4XView)
	Dim fscale As Double
	fscale = access.GetUserFontScale
	chk_alle_borden.TextSize = 17
	chk_alle_borden.TextSize = NumberFormat2(chk_alle_borden.TextSize / fscale,1,0,0,False)
	
	If v Is EditText Then
		v.TextSize = NumberFormat2(v.TextSize / fscale,1,0,0,False)
'	btn_save.TextSize = NumberFormat2(btn_save.TextSize / fscale,1,0,0,False)
	End If
End Sub

Private Sub PerformHapticFeedback (view As Object)
   #if B4A
	Dim jo As JavaObject = view
	jo.RunMethod("performHapticFeedback", Array(1))
   #Else if B4i
   FeedbackGenerator.RunMethod("impactOccurred", Null) 'see the tetris example
   #end if
End Sub




