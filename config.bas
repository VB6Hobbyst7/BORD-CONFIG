B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: false
#End Region
'#IgnoreWarnings: 10, 11, 12 , 20
#Extends: android.support.v7.app.AppCompatActivity
Sub Process_Globals
	Dim kvs As KvsMqtt
	Dim clsJson As classGetConfig
	Dim clsPutJson As classSetConfig
	Dim clsUpdate As classGetLatestVersion
	'Dim clsClvBord As classClvBord
	Dim clsFunc As classFunc
	Dim clsMqtt As classMqtt
	Dim bordPinged As Boolean = False
	'Private xui As XUI
End Sub

Sub Globals
	Dim clsClvBord As classClvBord
	
	Public msgMaxCharacter As Int = 40
	Public chk_timeout_active As CheckBox
	Public edt_timeout As EditText
	Private tsConfig As TabStrip
	Private svInput As ScrollView
	Private toolbar As ACToolBarDark
	Private clv_borden As CustomListView
	Private lbl_ip As Label
	Private lbl_bord_name As Label
	Private lbl_delete_bord As Label
	Private lbl_edit_bord As Label
	Private lbl_bord_config As Label
	Private lbl_add_board As Label
	Private lbl_bord_retro As Label
	Private lbl_mirror_bord As Label
	Private labl_mirror_bord As Label
'	Private lblBordToevoegenTxt As Label
	Private lblMIrror As Label
	Private pnlBlockInput As Panel
	Private pnlMirror As Panel
	Private lblRefresh As Label
	Private pnlReload As Panel
	Private pnlNew As Panel
	Private lblBordName As Label
	Private pnlDark As Panel
	Private lblDark As Label
	
	Private findBordActive As Boolean
'	Private clvBordForPing As CustomListView
'	Private pnlBord As Panel
'	
'	Private lblForPingBordName As Label
'	Private lblForPingBordIp As Label
'	Private lblPingBordAlive As Label
	Private lblLocatingBord As Label
	Private AnotherProgressBar1 As AnotherProgressBar
	Private labl_on_droid As Label
	Private lbl_bord_on_droid As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	If Starter.darkTheme Then
		Activity.LoadLayout("main_config_dark")
	Else
		'Activity.LoadLayout("main_config")
		Activity.LoadLayout("main_bord")
	End If
	kvs.Initialize
	clsFunc.Initialize
	clsJson.Initialize
	clsPutJson.Initialize
	clsUpdate.Initialize
	clsClvBord.Initialize
	clsMqtt.Initialize
	svInput.Initialize(1500dip)
	AnotherProgressBar1.Value = 0
	ShowMirror
	getUnits
	If clv_borden.Size > 0 Then
''		PingBord
	End If
	'Starter.SetViewColor(Activity, True)
End Sub

Sub Activity_Resume
	If Starter.bordUpdate = False Then
		
		If Starter.edtUnit = False Then
		End If
		Starter.edtUnit = False
	Else
		Starter.bordUpdate = False
	End If
	
	If Starter.newUnitName <> "" Then
		UpdateBordName(Starter.newUnitName)
	End If
	If Starter.bordAdded Then
		Starter.bordAdded = False
		getUnits
	End If
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed = True Then
		Activity.Finish
	End If
End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean
 
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		If findBordActive Then
			Return True
		End If
		Return False
	Else
		Return False
	End If
End Sub

Sub ShowMirror
'	pnlMirror.Visible = clsMqtt.CheckMqttExists 'File.Exists(Starter.hostPath, "mqttP.conf")
End Sub

Sub UpdateBordName(name As String)
	Dim p As Panel
	Dim lbl As Label
	Starter.newUnitName = ""
	
	p = clv_borden.GetPanel(Starter.selectedBordPanel)
	For Each v As View In p.GetAllViewsRecursive
		If v Is Label And v.Tag = "name" Then
			lbl = v
			lbl.Text = name
		End If
	Next
End Sub

Sub getUnits
'	lblBordName.Text = ""

	Starter.lstActiveBord.Initialize
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
	
	If clv_borden.Size < 1 Then
		Log("AANTAL BORDEN " & clv_borden.Size)
		Return
	End If

	curs.Close
	PingBord
End Sub

Private Sub PingBord
	findBordActive = True
	lblLocatingBord.Text = ""
	AnotherProgressBar1.Value = 0
	AnotherProgressBar1.Visible = True
	AnotherProgressBar1.UpdateGraphics
	Sleep(10)
	HideButtons
	clsClvBord.bordAlive(clv_borden)
End Sub

Public Sub HidePnlBlockInput
'	Sleep(1000)
'	AnotherProgressBar1.Visible = True
	lblLocatingBord.Text = ""
	pnlBlockInput.SetVisibleAnimated(500, False)
	
	pnlBlockInput.SetElevationAnimated(500, 6dip)
	pnlMirror.SetElevationAnimated(500, 6dip)
	pnlNew.SetElevationAnimated(500, 6dip)
	pnlReload.SetElevationAnimated(500, 6dip)
	pnlDark.SetElevationAnimated(500, 6dip)
	Sleep(1000)
	findBordActive = False
	
	'clv_borden.ScrollToItem(0)
End Sub

Sub genUnitList(name As String, ip As String, width As Int) As Panel
	Dim p As Panel
	p.Initialize(Me)
	p.SetLayout(0dip, 0dip, width, 245dip) '190
	p.LoadLayout("clv_bord")
	p.Tag = name
	
	lbl_bord_name.Text = name.Trim
	lbl_ip.Text = ip.Trim
	
	If gnDb.GetBordOnDroid(name) Then
		lbl_bord_on_droid.TextColor = Colors.Green
		Else
		lbl_bord_on_droid.TextColor = Colors.Red
	End If
	
	Return p
End Sub

Sub btn_add_Click
	StartActivity(units)
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

Sub updateAvailable
'	btn_update.SetVisibleAnimated(1000, False)
End Sub

Sub btn_new_bord_Click
	StartActivity(units)
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

Sub lbl_bord_retro_Click
	clsClvBord.ConfigItemRetro(clv_borden.GetItemFromView(Sender), clv_borden)
End Sub

Sub lbl_mirror_bord_Click
	'BordOnDroid(clsClvBord.PanelBordIpName(clv_borden.GetItemFromView(Sender), clv_borden, "name"))

	'kvs.MirrorBord(clsClvBord.PanelBordIpName(clv_borden.GetItemFromView(Sender), clv_borden, "name"))
	clsClvBord.ConfigItemMirror(clv_borden.GetItemFromView(Sender), clv_borden)
End Sub

Sub BordOnDroid(bordName As String) As Boolean
	Return gnDb.GetBordOnDroid(bordName)
End Sub


Sub lbl_bord_on_droid_Click
	Dim bordName As String = clsClvBord.PanelBordIpName(clv_borden.GetItemFromView(Sender), clv_borden, "name")
	Dim bordIp As String = clsClvBord.PanelBordIpName(clv_borden.GetItemFromView(Sender), clv_borden, "ip")
	
	If BordOnDroid(bordName) Then
		
	Else
				
	End If
	'clsClvBord.ConfigItemMirror(clv_borden.GetItemFromView(Sender), clv_borden)
	StartActivity(mqttbord)
	
	'clsClvBord.ConfigBordOnDroid(clv_borden.GetItemFromView(Sender), clv_borden)
End Sub

Sub CreateMqtt(bordName As String, ip As String)
	Dim mqtt As String = File.ReadString(File.DirAssets, "mqtt.conf")
	
	Dim parser As JSONParser
	parser.Initialize(mqtt)
	Dim root As Map = parser.NextObject
	Dim mqttClients As Map = root.Get("mqttClients")
	mqttClients.Put("server", "0_0_0_0")
	mqttClients.put("name", bordName)
	mqttClients.put("enabled", "1")
	mqttClients.Put("base", "base")
	
End Sub

Sub lbl_add_board_Click
	StartActivity(units)
End Sub

Sub clv_borden_ScrollChanged (Offset As Int)
''	snap.ScrollChanged(Offset)
End Sub

Sub lblMIrror_Click
	'StartActivity(delen_aktief)
	StartActivity(mqttbord)
End Sub

Sub lblRefresh_Click
	clsMqtt.CheckMqttExists
'	lblBordName.Text = ""
	
	HideButtons
	Sleep(750)
	'clsClvBord.bordAlive(clv_borden)
	PingBord
''	Sleep(750)
End Sub

Sub SetReloadBordName(name As String)
	lblLocatingBord.Text = name
	Sleep(0)
	'clsFunc.SetTextShadow(lblLocatingBord, 2, 4, 5, Colors.Gray)
End Sub

Sub UpdateProgress(value As Int)
	AnotherProgressBar1.Value = value
End Sub

Sub pnlBlockInput_Click
	Return
End Sub

Sub lblDark_Click
	Msgbox2Async("Donkere modus inschekelen", Starter.AppName, "JA", "", "NEE", Starter.appIcon, False)
	Wait For Msgbox_Result (Result As Int)
	
	If Result = DialogResponse.NEGATIVE Then
		Return
	End If
End Sub

Sub HideButtons
'	AnotherProgressBar1.Visible = False
	pnlBlockInput.SetVisibleAnimated(500, True)
	
	pnlBlockInput.SetElevationAnimated(500, 0dip)
	pnlMirror.SetElevationAnimated(500, 0dip)
	pnlNew.SetElevationAnimated(500, 0dip)
	pnlReload.SetElevationAnimated(500, 0dip)
	pnlDark.SetElevationAnimated(500, 0dip)
	Sleep(1000)
End Sub

