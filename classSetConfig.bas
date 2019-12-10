B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private parser As JSONParser
	Private cnf As String
	Dim ftp As SFtp
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
	
	
	If chkActive.Checked = True Then
		showPromote.Put("active", "1")
	Else
		showPromote.Put("active", "0")
	End If
	showPromote.Put("timeOut", edtTimeOut.Text)
	If chkActive.Checked Then
		showPromote.put("active","1")
	Else
		showPromote.put("active","1")
	End If
	If chkDigital.Checked Then
		digitalFont.put("active", "1")
	Else
		digitalFont.put("active", "0")
	End If
	
	Dim JSONGenerator As JSONGenerator
	JSONGenerator.Initialize(root)
	
	File.WriteString(Starter.hostPath, "cnf.44", JSONGenerator.ToPrettyString(2))
	pushConfig
End Sub
	
Sub pushConfig
	ftp.Initialize("ftp", "pi", "0", "192.168.1.27", 22)
	ftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
	
	Try
		ftp.UploadFile(Starter.hostPath, "cnf.44", "/home/pi/44/cnf.44")
		Wait For ftp_UploadCompleted (ServerPath As String, Success As Boolean)
		Log($"UploadCompleted (${ServerPath}, ${Success})"$)
		
		If Success = False Then Log(LastException.Message)
	Catch
		Log(LastException.Message)	
	End Try
	
	ftp.Close
End Sub