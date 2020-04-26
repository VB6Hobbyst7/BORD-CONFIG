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
	Dim bordPinged As Boolean = False
''	Private xui As XUI
End Sub

Sub Globals
	Public msgMaxCharacter As Int = 40
	Public chk_timeout_active As CheckBox
	Public edt_timeout As EditText
'	Private edt_regel_1 As EditText
'	Private edt_regel_2 As EditText
'	Private edt_regel_3 As EditText
'	Private edt_regel_4 As EditText
'	Private edt_regel_5 As EditText
	Private tsConfig As TabStrip
	Private svInput As ScrollView
	Private toolbar As ACToolBarDark
	Private clv_borden As CustomListView
	Private btn_new_bord As Button
	Private lbl_ip As Label
	Private lbl_bord_name As Label
	Private lbl_alive As Label
	Private lbl_delete_bord As Label
	Private lbl_edit_bord As Label
	Private lbl_bord_config As Label
	Private lbl_add_board As Label
	Private lbl_bord_retro As Label
	Private lbl_mirror_bord As Label
	Private labl_mirror_bord As Label
	Private lblBordToevoegenTxt As Label
	Private lblMIrror As Label
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
	
	lblMIrror.Visible = File.Exists(Starter.hostPath, "mqttP.conf")
	clsFunc.SetTextShadow(lblMIrror, 10,8,8, 0xFF000000)
	clsFunc.SetTextShadow(lbl_add_board, 10,8,8, 0xFF000000)
	
	
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
	Starter.lstActiveBord.Initialize
	btn_new_bord.SetVisibleAnimated(1000, False)
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

Sub genUnitList(name As String, ip As String, width As Int) As Panel
	Dim p As Panel
	p.Initialize(Me)
	p.SetLayout(0dip, 0dip, width, 245dip) '190
	p.LoadLayout("clv_bord")
	
	lbl_bord_name.Text = name
	lbl_ip.Text = ip
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

'Sub edt_regel_1_TextChanged (Old As String, New As String)
'	If clsFunc.countChars(New, msgMaxCharacter) = False Then
'		edt_regel_1.Text = Old
'		cursEOL(edt_regel_1)
'	End If
'End Sub

'Sub edt_regel_2_TextChanged (Old As String, New As String)
'	If clsFunc.countChars(New, msgMaxCharacter) = False Then
'		edt_regel_2.Text = Old
'		cursEOL(edt_regel_2)
'	End If
'End Sub
'
'Sub edt_regel_3_TextChanged (Old As String, New As String)
'	If clsFunc.countChars(New, msgMaxCharacter) = False Then
'		edt_regel_3.Text = Old
'		cursEOL(edt_regel_3)
'	End If
'End Sub
'
'Sub edt_regel_4_TextChanged (Old As String, New As String)
'	If clsFunc.countChars(New, msgMaxCharacter) = False Then
'		edt_regel_4.Text = Old
'		cursEOL(edt_regel_4)
'	End If
'End Sub
'
'Sub edt_regel_5_TextChanged (Old As String, New As String)
'	If clsFunc.countChars(New, msgMaxCharacter) = False Then
'		edt_regel_5.Text = Old
'		cursEOL(edt_regel_5)
'	End If
'End Sub

'Sub cursEOL(v As EditText)
'	Dim str As String = v.Text
'	Dim strLen As Int = str.Length
'	
'	Log("TEXT LEN IS " & str.Length)
'	
'	v.SelectionStart = strLen  '40
'End Sub


'Sub setMeassage(msg As List)
'	edt_regel_1.Text = msg.Get(0)
'	edt_regel_2.Text = msg.Get(1)
'	edt_regel_3.Text = msg.Get(2)
'	edt_regel_4.Text = msg.Get(3)
'	edt_regel_5.Text = msg.Get(4)
'	
'End Sub

Sub updateAvailable
'	btn_update.SetVisibleAnimated(1000, False)
End Sub

Sub btn_update_Click
	StartActivity(update_bord)
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


