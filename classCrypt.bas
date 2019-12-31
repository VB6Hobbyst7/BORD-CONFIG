B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
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

Sub test
	Dim EncryptedData() As Byte = EncryptText("confidential", "123456")
	Log(DecryptText(EncryptedData, "123456"))
End Sub


