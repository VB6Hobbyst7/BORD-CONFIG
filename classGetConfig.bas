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

Sub parseConfig(swTimeOut As B4XSwitch, edtTimeOut As EditText, swUseDigital As B4XSwitch, swUseYellow As B4XSwitch)
	
	cnf = File.ReadString(Starter.hostPath, "cnf.44")
	
	parser.Initialize(cnf)

	Dim root As Map = parser.NextObject
	Dim showPromote As Map = root.Get("showPromote")
	Dim digitalFont As Map = root.Get("digitalFont")
	Dim digitalActive As String = digitalFont.Get("active")
	Dim fontColor As Map = root.Get("fontColor")
	Dim colorYellow As String = fontColor.Get("colorYellow")
	
	If showPromote.Get("active") = "1" Then
		swTimeOut.Value = True
	Else
		swTimeOut.Value = False
	End If
	If showPromote.Get("timeOut") = "" Then
		edtTimeOut.Text = "0"
	Else
		edtTimeOut.Text =  showPromote.Get("timeOut")
	End If
	
	If digitalActive = "1" Then
		swUseDigital.Value = True
	Else
		swUseDigital.Value = False
	End If
	
	If colorYellow = "1" Then
		swUseYellow.Value = True
	Else
		swUseYellow.Value = False
	End If
	
	
	
	
End Sub