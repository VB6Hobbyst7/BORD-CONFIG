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
	Private nw As ServerSocket
End Sub

Sub Globals
	
	Private edt_description As EditText
	Private edt_ip As EditText
	Private btn_test As Button
	Private btn_add_unit As Button
	Private ProgressBar As ProgressBar
End Sub

Sub Activity_Create(FirstTime As Boolean)
	nw.Initialize(0, "")
	Activity.LoadLayout("units")
	edt_ip.Hint = $"Bijvoorbeeld ${nw.GetMyIP}"$
	edt_description.Hint = "Tafel 8"

End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)
	
End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		Return False
	End If
	Return True
End Sub


Sub btn_test_Click
	pingBord
End Sub

Sub btn_add_unit_Click
	If edt_description.Text = "" Then
		Msgbox("Geef een omschrijving op", "Bord config")
		Return
	End If
	addBord
End Sub

Sub pingBord
	ProgressBar.Visible = True
	Sleep(2000)
	Dim p As Phone
	Dim sb As StringBuilder
	sb.Initialize
	p.Shell($"ping -c 1 ${edt_ip.text}"$,Null,sb,Null)
	If sb.Length = 0 Or sb.ToString.Contains("Unreachable") Then 
		ProgressBar.Visible = False
		btn_add_unit.Enabled = False
		Msgbox("Kan ip nummer niet bereiken", "Bord Config")
	Else
		ProgressBar.Visible = False
		btn_add_unit.Enabled = True
		Msgbox("Ip nummer bereikbaar", "Bord Config")
	End If	
	
End Sub

Sub addBord
	If gnDb.bordNameExists(edt_description.Text) = True Then
		Msgbox("Omschrijving bestaat reeds","Bord config")
		Return
	End If
	
	If gnDb.bordIpExists(edt_ip.Text) = True Then
		Msgbox("Ip nummer bestaat reeds","Bord config")
		Return
	End If
	
	gnDb.addBord(edt_description.Text, edt_ip.Text)
	
End Sub