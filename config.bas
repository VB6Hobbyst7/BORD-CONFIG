B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: false
	#IncludeTitle: true
#End Region
#IgnoreWarnings: 10, 11, 12 , 20
#Extends: android.support.v7.app.AppCompatActivity
Sub Process_Globals
	Dim clsJson As classGetConfig
	Dim clsPutJson As classSetConfig
	Dim clsUpdate As classGetLatestVersion
	Dim clsC As classCrypt
	Dim clsClvBord As classClvBord
	Dim ftp As SFtp
	Dim lstDisplay, lstValue As List
	Dim clsFunc As classFunc
	Dim access As Accessiblity
	Dim bordPinged As Boolean = False
	Private xui As XUI
End Sub

Sub Globals
	Private Swipe As CLVSwipe
	Public msgMaxCharacter As Int = 40
	Public chk_timeout_active As CheckBox
	Public edt_timeout As EditText
	Private chk_use_digital As CheckBox
	Private btn_saveA As Button
	Private cmb_units As B4XComboBox
	Private ProgressBar As ProgressBar
	Private btn_add As Button
	Private btn_remove As Button
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
	Private svInput As ScrollView
	Private toolbar As ACToolBarDark
	Private clv_borden As CustomListView
	Private btn_new_bord As Button
	Private lbl_ip As Label
	Private lbl_bord_name As Label
	Private sw_update As B4XSwitch
	Private lbl_alive As Label
	Private lbl_delete_bord As Label
	Private lbl_edit_bord As Label
	
	Private lbl_bord_config As Label
	Private lblPullToRefresh As B4XView
	Private refreshIndicator As B4XLoadingIndicator
	Private lblTafelNaam As Label
	Private lbl_add_board As Label
	
	Private snap As CLVSnap
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("main_config")
	setMenuColor
	clsFunc.Initialize
	clsJson.Initialize
	clsPutJson.Initialize
	clsUpdate.Initialize
	clsClvBord.Initialize
	
	svInput.Initialize(1500dip)
	
	tsConfig.LoadLayout("main_bord", "Borden")
	'#######################################################################
	Swipe.Initialize(clv_borden, Me, "Swipe")
	Dim PullToRefreshPanel As B4XView = xui.CreatePanel("")
	PullToRefreshPanel.SetLayoutAnimated(0, 0, 0, 100%x, 70dip)
	PullToRefreshPanel.LoadLayout("PullToRefresh")
	Swipe.PullToRefreshPanel = PullToRefreshPanel
	'#######################################################################
	
	getUnits
End Sub

Sub Activity_Resume
	If Starter.bordUpdate = False Then
		If Starter.edtUnit = False Then
		End If
		Starter.edtUnit = False
	Else
		Starter.bordUpdate = False
	End If
End Sub

Sub Swipe_RefreshRequested
	Starter.lstActiveBord.Clear
	getUnits
	Dim i As Int
End Sub

Sub Activity_CreateMenu(Menu As ACMenu)
	Menu.Clear
	Menu.Add(1, 1, "Bord Toevoegen", Null)
	If lstDisplay.Size >= 2 Then
		Menu.Add(2, 2, "Bord Bewerken", Null)
		Menu.Add(3, 4, "Bord Verwijderen", Null)
	End If
End Sub

Sub getUnits
	btn_new_bord.SetVisibleAnimated(1000, False)
	Swipe.ChangeYOffsetInit(245, False)
	Swipe.PullToRefreshPanel.Visible = True
	lblPullToRefresh.Text = "Borden zoeken..."
	refreshIndicator.Show

	Dim unitList As List
	Dim viewWidth As Int = clv_borden.AsView.Width
	clv_borden.Clear
	
	Dim curs As Cursor = gnDb.RetieveBoards
	
	If curs.RowCount = 0 Then
		Return
	End If
	
	For i = 0 To curs.RowCount - 1
		curs.Position = i
		clv_borden.Add(genUnitList(curs.GetString("description"), curs.GetString("ip_number"), viewWidth), "")
	Next
	snap.Initialize(clv_borden)
	If bordPinged = False Then
		bordPinged = True
		clsClvBord.bordAlive(clv_borden)
	End If
	curs.Close
End Sub

Sub HidePullDown
	Swipe.RefreshCompleted '<-- call to exit refresh mode
	lblPullToRefresh.Text = "Sleep om te vernieuwen"
	refreshIndicator.Hide
	bordPinged = False
	btn_new_bord.SetVisibleAnimated(1000, True)
	
End Sub

Sub PullDownSetTableName(name As String)
	lblTafelNaam.Text = name
End Sub

Sub genUnitList(name As String, ip As String, width As Int) As Panel
	Dim p As Panel
	p.Initialize(Me)
	p.SetLayout(0dip, 0dip, width, 150dip)
	p.LoadLayout("clv_bord")
	
	lbl_bord_name.Text = name
	lbl_ip.Text = ip
	
	
	
	Return p
End Sub

Sub toolbar_MenuItemClick (Item As ACMenuItem)
	Select  Item.Id
		Case 1
			StartActivity(units)
		Case 2
			btn_edit_Click
		Case 3
			btn_remove_Click
	End Select
	
End Sub

Sub edtFnext
	editTextForceNext(edt_regel_1)
	editTextForceNext(edt_regel_2)
	editTextForceNext(edt_regel_3)
	editTextForceNext(edt_regel_4)
	editTextForceNext(edt_regel_5)
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
	
End Sub



Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub getConfig
	clsJson.parseConfig(sw_timeout, edt_timeout, sw_digital_numbers, sw_use_yellow_number, sw_toon_sponsor, sw_game_time)
	edtFnext
End Sub

Sub btn_save_Click
	PerformHapticFeedback(btn_save)
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
	Else if clsPutJson.updateResult = 1 Then
	End If
	Return True
End Sub

Sub getUnits1
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
	
	
	chk_alle_borden.Enabled = lstValue.Size >= 1
	
	
End Sub

Sub cmb_units_SelectedIndexChanged (Index As Int)
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
	retrieveConfig(value)
End Sub


Sub retrieveConfig(ipNumber As String)
	Dim msg, unit As String
	unit = cmb_units.GetItem(cmb_units.SelectedIndex)
	
	ProgressBar.Visible = True
	
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
		'enableView(True)
		getConfig
		ftp.Close
		btn_save.Enabled = True
		btn_save.Color = Colors.Blue
		
		msg =$"Configuratie van ${unit} geladen"$
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

Sub edt_regel_2_TextChanged (Old As String, New As String)
	If clsFunc.countChars(New, msgMaxCharacter) = False Then
		edt_regel_2.Text = Old
		cursEOL(edt_regel_2)
	End If
End Sub

Sub edt_regel_3_TextChanged (Old As String, New As String)
	If clsFunc.countChars(New, msgMaxCharacter) = False Then
		edt_regel_3.Text = Old
		cursEOL(edt_regel_3)
	End If
End Sub

Sub edt_regel_4_TextChanged (Old As String, New As String)
	If clsFunc.countChars(New, msgMaxCharacter) = False Then
		edt_regel_4.Text = Old
		cursEOL(edt_regel_4)
	End If
End Sub

Sub edt_regel_5_TextChanged (Old As String, New As String)
	If clsFunc.countChars(New, msgMaxCharacter) = False Then
		edt_regel_5.Text = Old
		cursEOL(edt_regel_5)
	End If
End Sub



Sub cursEOL(v As EditText)
	Dim str As String = v.Text
	Dim strLen As Int = str.Length
	
	Log("TEXT LEN IS " & str.Length)
	
	v.SelectionStart = strLen  '40
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


Sub editTextForceNext(v As EditText)
	Dim r As Reflector
	r.Target = v
	r.RunMethod2("setImeOptions", 5, "java.lang.int")
End Sub

Sub setMenuColor
Dim jo As JavaObject = toolbar
Dim xl As XmlLayoutBuilder
jo.RunMethod("setPopupTheme", Array(xl.GetResourceId("style", "ToolbarMenu")))
End Sub

Sub btn_new_bord_Click
	StartActivity(units)
End Sub

Sub clv_borden_ItemClick (Index As Int, Value As Object)
'	clsClvBord.editItem(Index, Value, Sender)
End Sub

Sub lbl_delete_bord_Click
	clsClvBord.deleteItem(clv_borden.GetItemFromView(Sender), clv_borden)
End Sub

Sub lbl_edit_bord_Click
	clsClvBord.editItem(clv_borden.GetItemFromView(Sender), clv_borden)
End Sub



Sub lbl_bord_config_Click
	
	clsClvBord.configItem(clv_borden.GetItemFromView(Sender), clv_borden)
End Sub

Sub lbl_add_board_Click
	StartActivity(units)
End Sub

Sub clv_borden_ScrollChanged (Offset As Int)
	snap.ScrollChanged(Offset)
End Sub