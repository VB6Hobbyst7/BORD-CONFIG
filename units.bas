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
	Private nw As ServerSocket
End Sub

Sub Globals
	Private IME As IME
	
	Private edt_description As EditText
	Private edt_ip As EditText
	Private clsFunc As classFunc
	Private btnTest As Label
	Private btnAddUnit As Label
	Private btnTerug As Label
	Private LoadingIndicator As B4XLoadingIndicator
	Private edtBordName, edtBordIp As String
	Private B4XLoadingIndicatorBiljartBall1 As B4XLoadingIndicatorBiljartBall
End Sub

Sub Activity_Create(FirstTime As Boolean)
	nw.Initialize(0, "")
	Activity.LoadLayout("units")
	IME.Initialize(Me)
	edt_ip.Hint = $"Bijvoorbeeld ${nw.GetMyIP}"$
	edt_description.Hint = "Tafel 8"
	clsFunc.Initialize
	If Starter.edtUnit = True Then
		getUnit
	End If
	
	Starter.newUnitName = ""

End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)
	
End Sub

Sub getUnit
	Dim lst As List
	lst.Initialize
	
	lst = gnDb.getUnit(Starter.edtIpNumber)
	Starter.unitId = lst.Get(2)
	setFieldsEdt(lst)
	btnAddUnit.Enabled = True
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
		Msgbox2Async("Geef een omschrijving op", Starter.AppName, "OKE", "", "", Starter.appIcon, False)
		Wait For Msgbox_Result (Result As Int)
		Return
	End If
	addBord
End Sub

Sub pingBord
	btnAddUnit.Enabled = False
	If Not(clsFunc.IsValidIp(edt_ip.Text)) Then
		Msgbox2Async("Ip nummer niet geldig", Starter.AppName, "OKE", "","", Application.Icon, False)
		btnAddUnit.Enabled = False
		Return
	End If
	
	B4XLoadingIndicatorBiljartBall1.Show
	Sleep(0)
	wait for (clsFunc.pingBord(edt_ip.Text)) Complete (result As Boolean)
	If result Then
		B4XLoadingIndicatorBiljartBall1.Hide
		btnAddUnit.Enabled = True
		Msgbox2Async("Ip nummer bereikbaar", Starter.AppName, "OKE", "","", Application.Icon, False)
	Else
		B4XLoadingIndicatorBiljartBall1.Hide
		btnAddUnit.Enabled = False
		Msgbox2Async("Kan ip nummer niet bereiken", Starter.AppName, "OKE", "","", Application.Icon, False)
	End If
End Sub

Sub addBord
	If edtBordName = edt_description.Text And edtBordIp = edt_ip.Text Then
		Msgbox2Async("Geen veranderingen", Starter.AppName, "OKE", "", "", Starter.appIcon, False)
		Wait For Msgbox_Result (Result As Int)
		Return
	End If
	
	If Starter.edtUnit Then
		checkWhenEdited
		Return
	Else
		checkWhenNew	
	End If
	
	
''	If gnDb.bordNameExists(edt_description.Text) = True And Starter.edtUnit = False Then
''		Msgbox2Async("Omschrijving bestaat reeds", Starter.AppName, "OKE", "", "", Starter.appIcon, False)
''		Wait For Msgbox_Result (Result As Int)
''		Return
''	End If
	
''	If gnDb.bordIpExists(edt_ip.Text) = True And Starter.edtUnit = False Then
''		Msgbox2Async("Ip nummer bestaat reeds", Starter.AppName, "OKE", "", "", Starter.appIcon, False)
''		Wait For Msgbox_Result (Result As Int)
''		Return
''	End If
	
End Sub

Private Sub checkWhenNew
	If gnDb.bordNameExists(edt_description.Text, "") = True Then
		Msgbox2Async("Omschrijving bestaat reeds", Starter.AppName, "OKE", "", "", Starter.appIcon, False)
		Wait For Msgbox_Result (Result As Int)
		Return
	End If
	
	If gnDb.bordIpExists(edt_ip.Text, "") = True Then
		Msgbox2Async("Ip nummer bestaat reeds", Starter.AppName, "OKE", "", "", Starter.appIcon, False)
		Wait For Msgbox_Result (Result As Int)
		Return
	End If
	gnDb.addBord(edt_description.Text, edt_ip.Text)
	Starter.bordAdded = True
	Msgbox2Async("Bord opgeslagen", Starter.AppName, "OKE", "", "", Starter.appIcon, False)
End Sub


Private Sub checkWhenEdited
	Dim unitId As String = Starter.unitId
	
	If gnDb.bordNameExists(edt_description.Text, unitId) = True Then
		Msgbox2Async("Omschrijving bestaat reeds", Starter.AppName, "OKE", "", "", Starter.appIcon, False)
		Return
	End If
	
	If gnDb.bordIpExists(edt_ip.Text, unitId) = True Then
		Msgbox2Async("Ip nummer bestaat reeds", Starter.AppName, "OKE", "", "", Starter.appIcon, False)
		Return
	End If
		
	gnDb.updateBord(edt_description.Text, edt_ip.Text)
	Starter.newUnitName = edt_description.Text
	IME.HideKeyboard
	Msgbox2Async("Bord opgeslagen", Starter.AppName, "OKE", "", "", Starter.appIcon, False)
	
	Return
End Sub


Sub setFieldsEdt(lst As List)
	edt_description.Text = lst.Get(0)
	edt_ip.Text = lst.Get(1)
	edtBordName = lst.Get(0)
	edtBordIp = lst.Get(1)
End Sub

Sub btn_back_Click
	IME.HideKeyboard
	Activity.Finish
End Sub



