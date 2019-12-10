B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private parser As JSONParser
	Private cnf As String
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

Sub parseConfig(chkActive As CheckBox, edtTimeOut As EditText, chkDigital As CheckBox)
	
	cnf = File.ReadString(Starter.hostPath, "cnf.44")
	
	parser.Initialize(cnf)

	Dim root As Map = parser.NextObject
	Dim showPromote As Map = root.Get("showPromote")
	Dim digitalFont As Map = root.Get("digitalFont")
	Dim digitalActive As String = digitalFont.Get("active")
	
	If showPromote.Get("active") = 1 Then
		chkActive.Checked = True
	Else
		chkActive.Checked = True
	End If
	edtTimeOut.Text =  showPromote.Get("timeOut")
	
	If digitalActive = "1" Then
		chkDigital.Checked = True
		Else
		chkDigital.Checked = False
	End If
	
	
	
	
End Sub