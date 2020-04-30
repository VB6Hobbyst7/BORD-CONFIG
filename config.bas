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
	Dim clsJson As classGetConfig
	Dim clsPutJson As classSetConfig
	Dim clsUpdate As classGetLatestVersion
	Dim clsClvBord As classClvBord
	Dim clsFunc As classFunc
	Dim clsMqtt As classMqtt
	Dim bordPinged As Boolean = False
	'Private xui As XUI
End Sub

Sub Globals
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
	Private lblBordToevoegenTxt As Label
	Private lblMIrror As Label
	Private pnlBlockInput As Panel
	Private pnlMirror As Panel
	Private lblRefresh As Label
	Private pnlReload As Panel
	Private pnlNew As Panel
	Private lblBordName As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("main_config")
	clsFunc.Initialize
	clsJson.Initialize
	clsPutJson.Initialize
	clsUpdate.Initialize
	clsClvBord.Initialize
	clsMqtt.Initialize
	svInput.Initialize(1500dip)
	
	tsConfig.LoadLayout("main_bord", "Overzicht borden")
	For Each lbl As Label In GetAllTabLabels(tsConfig)
		'lbl.Typeface = Typeface.MATERIALICONS
		'lbl.TextSize=12
		lbl.Width=100%x
	Next
	
	ShowMirror
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
	
	If Starter.newUnitName <> "" Then
		UpdateBordName(Starter.newUnitName)
	End If
	If Starter.bordAdded Then
		Starter.bordAdded = False
		getUnits
	End If
End Sub

Sub GetAllTabLabels (tabstrip As TabStrip) As List
	Dim jo As JavaObject = tabstrip
	Dim r As Reflector
	r.Target = jo.GetField("tabStrip")
	Dim tc As Panel = r.GetField("tabsContainer")
	Dim res As List
	res.Initialize
	For Each v As View In tc
		If v Is Label Then res.Add(v)
	Next
	Return res
End Sub

Sub ShowMirror
	pnlMirror.Visible = clsMqtt.CheckMqttExists 'File.Exists(Starter.hostPath, "mqttP.conf")
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
	lblBordName.Text = ""
	
	pnlMirror.Visible = False
	pnlNew.Visible = False
	pnlReload.Visible = False
	
	pnlBlockInput.BringToFront
	pnlBlockInput.Visible = True
	
	Sleep(500)
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

	If bordPinged = False Then
		bordPinged = True
		clsClvBord.bordAlive(clv_borden)
	End If
	curs.Close
	
End Sub

Public Sub HidePnlBlockInput
	Sleep(1000)
	pnlBlockInput.SetVisibleAnimated(500, False)
	pnlMirror.SetVisibleAnimated(500, clsMqtt.CheckMqttExists)
	pnlNew.SetVisibleAnimated(500, True)
	pnlReload.SetVisibleAnimated(500, True)
	Sleep(1000)
End Sub

Sub genUnitList(name As String, ip As String, width As Int) As Panel
	Dim p As Panel
	p.Initialize(Me)
	p.SetLayout(0dip, 0dip, width, 245dip) '190
	p.LoadLayout("clv_bord")
	p.Tag = name
	
	lbl_bord_name.Text = name.Trim
	lbl_ip.Text = ip.Trim
	
	Return p
End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed = True Then
		Activity.Finish
	End If
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
	clsClvBord.ConfigItemMirror(clv_borden.GetItemFromView(Sender), clv_borden)
End Sub

Sub lbl_add_board_Click
	StartActivity(units)
End Sub

Sub clv_borden_ScrollChanged (Offset As Int)
''	snap.ScrollChanged(Offset)
End Sub

Sub lblMIrror_Click
	StartActivity(delen_aktief)
End Sub

Sub lblRefresh_Click
	clsMqtt.CheckMqttExists
	lblBordName.Text = ""
	pnlBlockInput.SetVisibleAnimated(500, True)
	pnlMirror.SetVisibleAnimated(500, False)
	pnlNew.SetVisibleAnimated(500, False)
	pnlReload.SetVisibleAnimated(500, False)
	
	Sleep(750)
	clsClvBord.bordAlive(clv_borden)
	Sleep(750)
End Sub

Sub SetReloadBordName(name As String)
	lblBordName.Text = name
	
End Sub


Sub pnlBlockInput_Click
	Return
End Sub