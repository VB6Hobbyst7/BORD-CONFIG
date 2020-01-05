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

#IgnoreWarnings: 10, 11, 12 , 20
#Extends: android.support.v7.app.AppCompatActivity

Sub Process_Globals
	Private nw As ServerSocket
	Private clsAes As AESCryptUtilities
	Private crypt As B4XCipher
End Sub

Sub Globals
	
	Private edt_description As EditText
	Private edt_ip As EditText
	Private btn_test As Button
	Private btn_add_unit As Button
	Private ProgressBar As ProgressBar
	Private clsFunc As classFunc
	Private btn_back As Button
End Sub

Sub Activity_Create(FirstTime As Boolean)
	nw.Initialize(0, "")
	Activity.LoadLayout("units")
	edt_ip.Hint = $"Bijvoorbeeld ${nw.GetMyIP}"$
	edt_description.Hint = "Tafel 8"
	clsFunc.Initialize
	clsAes.Initialize
	If Starter.edtUnit = True Then
		getUnit
	End If

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
	btn_add_unit.Enabled = True
End Sub



Sub Activity_KeyPress (KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		Return False
	End If
	Return True
End Sub


Sub EncryptText(text As String, password As String) As Byte()
	Dim c As B4XCipher
	Return c.Encrypt(text.GetBytes("utf8"), password)
End Sub

Sub DecryptText(EncryptedData() As Byte, password As String) As String
	Dim c As B4XCipher
	Dim b() As Byte = c.Decrypt(EncryptedData, password)
	Return BytesToString(b, 0, b.Length, "utf8")
End Sub


Sub btn_test_Click
'	Dim encryptedData() As Byte = EncryptText(Starter.pw, Starter.xStr)
'	Log(BytesToString(encryptedData, 0, encryptedData.Length, "UTF8"))
'	Log(DecryptText(encryptedData, Starter.xStr))
'	
'	
'	
'	Return
	
	
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
	Sleep(1000)
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
	If gnDb.bordNameExists(edt_description.Text) = True And Starter.edtUnit = False Then
		Msgbox("Omschrijving bestaat reeds","Bord config")
		Return
	End If
	
	If gnDb.bordIpExists(edt_ip.Text) = True And Starter.edtUnit = False Then
		Msgbox("Ip nummer bestaat reeds","Bord config")
		Return
	End If
	
	If Starter.edtUnit = True Then
		gnDb.updateBord(edt_description.Text, edt_ip.Text)
		clsFunc.createCustomToast("Gegevens bijgewerkt", Colors.Blue)
		Sleep(500)
		Starter.edtUnit = False
		Starter.edtIpNumber = ""
		Starter.unitId = ""
		Activity.Finish
	Else
		gnDb.addBord(edt_description.Text, edt_ip.Text)
	End If
	
End Sub

Sub setFieldsEdt(lst As List)
	edt_description.Text = lst.Get(0)
	edt_ip.Text = lst.Get(1)
	
	
End Sub

Sub btn_back_Click
	Activity.Finish
End Sub