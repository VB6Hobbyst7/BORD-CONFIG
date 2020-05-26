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
	Private bordIp As String
	Private btnCancel As Button
	Private btnOk As Button
	Private p1Make As B4XFloatTextField
	Private p1Name As B4XFloatTextField
	Private p2Make As B4XFloatTextField
	Private p2Name As B4XFloatTextField
	Private sprBorden As ACSpinner
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("bordSetName")
	GetBorden
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Private Sub GetBorden
	Dim lstBorden As List
	Dim curs As Cursor = gnDb.RetieveBoards
	
	If curs.RowCount = 0 Then
		'doe iets
		Return
	End If
	
	curs.Position = 0
	lstBorden.Initialize
	lstBorden.Add("")
	For i = 0 To curs.RowCount - 1
		curs.Position = i
		lstBorden.Add(curs.GetString("description"))
	Next
	curs.Close
	
	sprBorden.AddAll(lstBorden)
End Sub

Sub sprBorden_ItemClick (Position As Int, Value As Object)
	GetBordIp(Value)
	Log(bordIp)
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

Sub btnOk_Click
	
End Sub

Sub btnCancel_Click
	
End Sub