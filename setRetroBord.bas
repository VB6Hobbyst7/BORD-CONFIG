B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.801
@EndOfDesignText@
Sub Class_Globals
	Private parser As JSONParser
	Private clsFunc As classFunc
	Private ipBord As String
	
	Dim ftp As SFtp
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	clsFunc.Initialize
End Sub

Public Sub SetBordToRetro(ip As String)
	Msgbox2Async("RETRO aan/uitzetten", $"Bord ${ip}"$, "JA", "", "NEE", Starter.appIcon, False)
	Wait For Msgbox_Result (Result As Int)
	If Result = DialogResponse.NEGATIVE Then
		Return
	End If
	
	ipBord = ip
	ConnectToBord(ip)
End Sub


Sub ConnectToBord(ip As String)
	ftp.Initialize("ftp", "pi", "0", ip, 22)
	Try
		ftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
	Catch
		Dim msg As String =$"${ip} niet bereikbaar"$
		
		Msgbox2Async(msg, $"Bord ${ip}"$, Starter.AppName, "", "OKE", Starter.appIcon, False)
		Wait For Msgbox_Result (Result As Int)
		If Result = DialogResponse.NEGATIVE Then
			Return
		End If
		
		ftp.Close
		Return
	End Try
	
	ftp.DownloadFile("/home/pi/44/retro.cnf", Starter.hostPath, "retro.cnf")
	
	wait for ftp_DownloadCompleted (ServerPath As String, Success As Boolean)
	If Success = False Then
		ftp.Close
		clsFunc.createCustomToast("Bestand niet gevonden", Colors.Red)
		Return
	Else
		ftp.Close
		
	End If
	
	ftp.Close
	EnableRetro
End Sub


Sub EnableRetro
	Dim strRetro As String = File.ReadString(Starter.hostPath, "retro.cnf")
	Dim setActive As String
	
	parser.Initialize(strRetro)
	Dim root As Map = parser.NextObject
	Dim retro As Map = root.Get("retroBord")
	Dim active As String = retro.Get("active")
	
	setActive = active
	
	If setActive = "0" Then
		setActive = "1"
	Else
		setActive = "0"
	End If
	
	
	retro.Put("active", setActive)
	
	Dim JSONGenerator As JSONGenerator
	JSONGenerator.Initialize(root)
	
	File.WriteString(Starter.hostPath, "retro.cnf", JSONGenerator.ToPrettyString(2))
	Sleep(100)
	
	pushConfig
End Sub


Sub pushConfig
	ftp.Initialize("ftp", "pi", "0", ipBord, 22)
	ftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
	
	ftp.UploadFile(Starter.hostPath, "retro.cnf", "/home/pi/44/retro.cnf")
	Wait For ftp_UploadCompleted (ServerPath As String, Success As Boolean)
	If Success = False Then
		clsFunc.createCustomToast("Kan status niet bijwerken", Colors.Red)
	Else
		clsFunc.createCustomToast("Bord RETRO status bijgewerkt", Colors.Blue)
	End If
	
	ftp.Close
End Sub


Sub ftp_PromptYesNo (Message As String)
	Log(Message)
	
	ftp.SetPromptResult(True)
End Sub