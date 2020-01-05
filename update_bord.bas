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
	Dim clsFunc As classFunc
	Dim ftp As FTP
	Dim sftp As SFtp
	Dim ipLst As List

End Sub

Sub Globals
	Private clvBorden As CustomListView
	Private pn_bord As Panel
	Private lbl_bord_name As Label
	Private sw_update As B4XSwitch
	Private lbl_ping_bord As Label
	Private btn_update As Button
	Private lbl_progres As Label
	Private ProgressBar As ProgressBar
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("update")
	clsFunc.Initialize
	getBorden
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub Activity_KeyPress (KeyCode As Int) As Boolean
	If KeyCode = KeyCodes.KEYCODE_BACK Then
		Starter.bordUpdate = True
	End If
	Return False
End Sub


Sub getBorden
	Dim curs As Cursor
	Dim descr, ipNumber As String
	Dim width As Int
	Dim cb As CSBuilder
	
	ipLst.Initialize
	width = clvBorden.AsView.Width
	curs = gnDb.RetieveBoardsForUpdate
	
	clvBorden.Clear
	
	For i = 0 To curs.RowCount - 1
		lbl_ping_bord.Text = ""
		curs.Position = i
		descr = curs.GetString("description")
		ipNumber = curs.GetString("ip_number")
		clvBorden.Add(setPanel(descr, ipNumber, width), "")
		lbl_ping_bord.Text = $"Bord ${descr} zoeken"$
		Sleep(0)
		Wait For (clsFunc.pingBord(ipNumber)) Complete (result As Boolean)
		sw_update.Value = result
		sw_update.Enabled = result
		If result = False Then
			cb.Initialize
			cb.Append("").Strikethrough.Color(Colors.red).Append(descr).PopAll
			lbl_bord_name.Text = cb
		Else
			ipLst.AddAll(Array As String($"${ipNumber}, ${descr}"$))
		End If
		lbl_ping_bord.Text = ""
		Sleep(0)
		
	Next
	
	curs.Close
	
	If ipLst.Size < 1 Then
		btn_update.Enabled = False
		ToastMessageShow("Geen borden gevonden", True)
	Else
		btn_update.Enabled = True
	End If
	
	
End Sub

Sub setPanel(descr As String, ip As String, width As Int) As Panel
	Dim p As Panel
		
	p.Initialize("")
	p.SetLayout(0,0, width, 85dip)
	p.LoadLayout("clv_bord")
	
	lbl_bord_name.Text = descr
	lbl_bord_name.Tag = ip
		
	Return p
End Sub


Sub btn_update_Click
	ftp.PassiveMode = True
	ftp.Initialize("FTP", "ftp.pdeg.nl", 21, Starter.doy, Starter.moy)
	ftp.DownloadFile($"${Starter.updateFile}"$, False, Starter.hostPath, Starter.updateFile)
End Sub

Sub FTP_DownloadProgress (ServerPath As String, TotalDownloaded As Long, Total As Long)
	Dim tot As Long = (TotalDownloaded/Starter.fileSize)*100
	updatProgres(tot)
End Sub

Sub updatProgres(tot As Int)
	ProgressBar.Progress = tot
	Sleep(400)
End Sub

Sub FTP_DownloadCompleted (ServerPath As String, Success As Boolean)
	ftp.Close
	
	If Success = False Then
		ToastMessageShow("Kan update niet downloaden", True)
	Else
		Log("KLAAR")
		updateBorden	
	End If
End Sub





Sub updateBorden
	Dim data() As String
	
	'CREATE VERSION FILE
	File.WriteString(Starter.hostPath, "lstVer.pdg", Starter.upDateVersion)
	
	For i = 0 To ipLst.Size -1
		data = Regex.Split(",", ipLst.Get(i))
		sftp.Initialize("ftp", "pi", "0", data(0), 22)
		sftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
	
		sftp.UploadFile(Starter.hostPath, Starter.updateFile,"/home/pi/44/44.jar")
	

		Wait For ftp_UploadCompleted (ServerPath As String, Success As Boolean)
		If Success = False Then
			Log(LastException.Message)
			clsFunc.createCustomToast("Kan update niet uploaden", Colors.Red)
			Sleep(5000)
			sftp.Close
			Continue
		End If
		clsFunc.createCustomToast($"${data(1)} bijgewerkt"$, Colors.Blue)
		ftp.Close
	Next
	
	For i = 0 To ipLst.Size -1
		data = Regex.Split(",", ipLst.Get(i))
		sftp.Initialize("ftp", "pi", "0", data(0), 22)
		sftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
		
		sftp.UploadFile(Starter.hostPath, "lstVer.pdg", "/home/pi/44/ver.pdg")

		Wait For ftp_UploadCompleted (ServerPath As String, Success As Boolean)
		If Success = False Then
			Log(LastException.Message)
			clsFunc.createCustomToast("Kan update niet uploaden", Colors.Red)
			Sleep(5000)
			sftp.Close
			Continue
		End If

	
		ftp.Close
	Next
	
	For i = 0 To ipLst.Size -1
		data = Regex.Split(",", ipLst.Get(i))
		sftp.Initialize("ftp", "pi", "0", data(0), 22)
		sftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
		File.WriteString(Starter.hostPath, "upd.pdg", "")
		sftp.UploadFile(Starter.hostPath, "upd.pdg", "/home/pi/44/upd.pdg")

		Wait For ftp_UploadCompleted (ServerPath As String, Success As Boolean)
		If Success = False Then
			Log(LastException.Message)
			clsFunc.createCustomToast("Kan update niet uploaden", Colors.Red)
			Sleep(5000)
			sftp.Close
			Continue
		End If

	
		ftp.Close
	Next
	
End Sub

Sub sftp_UploadCompleted (ServerPath As String, Success As Boolean)
	ftp.Close
	
	If Success = False Then
		ToastMessageShow("Kan update niet downloaden", True)
	Else
		Log("UPLOAD KLAAR")
		'updateBorden	
	End If
	
	
	
End Sub

Sub sftp_UploadProgress (ServerPath As String, TotalUploaded As Long, Total As Long)
	updatProgres((TotalUploaded/Total)*100)
	
	Dim s As String
	s = "Uploaded " & Round(TotalUploaded / 1000) & "KB"
	If Total > 0 Then s = s & " out of " & Round(Total / 1000) & "KB"
	Log(s)
End Sub




Sub sftp_PromptYesNo (Message As String)
	sftp.SetPromptResult(True)
End Sub
