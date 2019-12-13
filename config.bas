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

Sub Process_Globals
	Dim clsJson As classGetConfig
	Dim clsPutJson As classSetConfig
	Dim ftp As SFtp
	Dim lstDisplay, lstValue As List
	Dim clsFunc As classFunc
End Sub

Sub Globals
	Public msgMaxCharacter As Long = 40
	Public chk_timeout_active As CheckBox
	Public edt_timeout As EditText
	Private chk_use_digital As CheckBox
	Private btn_save As Button
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
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("config")
	clsFunc.Initialize
	clsJson.Initialize
	clsPutJson.Initialize
	
	svInput.Panel.LoadLayout("configInput")
	svInput.Panel.Height = 1000dip
	getUnits
	'getConfig
	
End Sub

Sub Activity_Resume
	clearConfig
	getUnits
End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Sub getConfig
	'clsJson.parseConfig(chk_timeout_active, edt_timeout, chk_use_digital)
	clsJson.parseConfig(sw_timeout, edt_timeout, sw_digital_numbers, sw_use_yellow_number, sw_toon_sponsor)
End Sub

Sub btn_save_Click
	'clsPutJson.parseConfig(chk_timeout_active, edt_timeout, chk_use_digital)
	Dim msgList As List
	msgList.Initialize
	msgList.AddAll(Array As String(edt_regel_1.text, edt_regel_2.text, edt_regel_3.text, edt_regel_4.text, edt_regel_5.text))
	clsPutJson.ipNumber = lstValue.get(cmb_units.SelectedIndex)
	clsPutJson.parseConfig(sw_timeout, edt_timeout, sw_digital_numbers, sw_use_yellow_number, msgList, sw_toon_sponsor)
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
	
End Sub

Sub cmb_units_SelectedIndexChanged (Index As Int)
	
	enableView(False)
	Dim value As String = lstValue.get(cmb_units.SelectedIndex)
	If value = "0" Then
		btn_save.Enabled = False
		btn_remove.Visible =False
		Return
	End If
	
	btn_remove.Visible = True
	ProgressBar.Visible = True
	'Sleep(500)
	retrieveConfig(value)
	ProgressBar.Visible = False
	
	
End Sub


Sub retrieveConfig(ipNumber As String)
'	#if debug
'	btn_save.Enabled = True
'	enableView(True)
'	getConfig
'	Return
'	#End If
	
	btn_save.Enabled = False
	Dim msg, unit As String
	ftp.Initialize("ftp", "pi", "0", ipNumber, 22)
	unit = cmb_units.GetItem(cmb_units.SelectedIndex)
	
	Try
		ftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
	Catch
		msg =$"$unit} niet bereikbaar"$
		
		clsFunc.createCustomToast(msg)
		Msgbox(msg, "Bord Config")
		
		ftp.Close
		Return
	End Try

	ftp.DownloadFile("/home/pi/44/cnf.44", Starter.hostPath, "cnf.44")
	wait for ftp_DownloadCompleted (ServerPath As String, Success As Boolean)
	If Success = False Then
		msg =$"Config bestand van ${unit} niet gevonden"$
		clsFunc.createCustomToast(msg)
	Else
		enableView(True)
		getConfig
		ftp.Close
		btn_save.Enabled = True
		msg =$"Configuratie van ${unit} geladen"$
		'Msgbox(msg, "Bord Config")
		clsFunc.createCustomToast(msg)
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
	
	edt_timeout.Enabled = enable
	edt_timeout.Text = ""
	
	lbl_timeout_min.Enabled = enable
	lbl_timeout_plus.Enabled = enable
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
	Msgbox2Async("Bord verwijderen?", "Bord Config", "JA", "", "NEE", Null, False)
	Wait For Msgbox_Result (Result As Int)
	If Result = DialogResponse.POSITIVE Then
		'...
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




