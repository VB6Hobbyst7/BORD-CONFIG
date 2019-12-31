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

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.

	Private clvBorden As CustomListView
	Private pn_bord As Panel
	Private lbl_bord_name As Label
	Private sw_update As B4XSwitch
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("update")

	getBorden
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Sub getBorden
	Dim curs As Cursor
	Dim descr, ipNumber As String
	
	curs = gnDb.RetieveBoardsForUpdate
	
	clvBorden.Clear
	
	For i = 0 To curs.RowCount - 1
		descr = curs.GetString("description")
		ipNumber = curs.GetString("ip_number")
		clvBorden.Add(setPanel(descr, ipNumber), "")
	Next
	
	
	
End Sub

Sub setPanel(descr As String, ip As String) As Panel
	Dim p As Panel
	
	p.Initialize("")
	p.SetLayout(0,0, 300dip, 200dip)
	p.LoadLayout("clv_bord")
	
	lbl_bord_name.Text = descr
	lbl_bord_name.Tag = ip
	
	Return p
End Sub




