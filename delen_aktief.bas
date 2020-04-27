B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9.801
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

#Extends: android.support.v7.app.AppCompatActivity

Sub Process_Globals
	
End Sub

Sub Globals
	Private mb As List
	Private serverIp As String
	Private mqtt As SetMqtt
	Private clsMqtt As classMqtt
	
	Private btnStopDelen As Label
	Private clvMirror As CustomListView
	Private lblServerName As Label
	Private pnlDeelBord As Panel
	Private ACSwitch1 As ACSwitch
	Private lblClientBord As Label
	Private lblClientIp As Label
	Private B4XLoadingIndicator1 As B4XLoadingIndicator
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("delen_aktief")
	mqtt.Initialize
	mb.Initialize
	clsMqtt.Initialize
	ParseMirrors
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)
	If UserClosed = True Then
		Activity.Finish
	End If
End Sub

Sub ParseMirrors
	If clsMqtt.CheckMqttExists = False Then Return
	mb = clsMqtt.ParseMirrors
	GenClv
End Sub

Sub GenClv()
	Dim aWidth As Int = clvMirror.AsView.Width
	Dim aHeight As Int = 250
	
	clvMirror.Clear
	
	For i = 0 To mb.Size-1
		mb.SortType("server", False)
		
		Dim b As mirrorBord
		b = mb.Get(i)
	
		If b.server = "1" Then
			lblServerName.Text = b.name
			lblServerName.Tag = b.ip
			serverIp = b.ip
			Continue
		End If
	
		clvMirror.Add(AddBord(aWidth, b.name, b.ip, aHeight), "")
	Next
	
End Sub

Sub AddBord(width As Int, name As String, ip As String, height As Int) As Panel
	Dim p As Panel
	p.Initialize(Me)
	p.SetLayout(5dip, 10dip, width-5, height) '190
	p.LoadLayout("clvDeelBord")
	p.Tag = ip
	
	lblClientBord.Text = name
	lblClientBord.Tag = ip
	lblClientIp.Text = ip
	ACSwitch1.Checked = True
	ACSwitch1.Tag = ip
	
	Return p
End Sub

Sub ACSwitch1_CheckedChange(Checked As Boolean)
	Dim sw As ACSwitch = Sender
	Dim enabled As Int

	If Checked Then
		enabled = 1
	Else
		enabled = 0	
	End If
	mqtt.GenMqttFile(serverIp, sw.Tag, enabled)
	
End Sub

'Sub clvMirror_ItemClick (Index As Int, Value As Object)
'	Dim p As Panel
'	Dim sw As ACSwitch
'	
'	p = clvMirror.GetPanel(Index)
'	
'	For Each v As View In p.GetAllViewsRecursive
'		If v Is ACSwitch Then
'			sw = v
'			Log($"SW VALUE : ${sw.Checked}"$)
'			Exit
'		End If
'	Next
'End Sub

'Sub GetBordNameFromIp(ip As String) As String
'	Dim lst As List = gnDb.getUnit(ip)
'	
'	Return lst.Get(0)
'End Sub

Sub StopDelen_Click
	Msgbox2Async("Stop delen naar alle borden?", "Bord Config", "JA", "", "NEE", Null, False)
	Wait For Msgbox_Result (Result As Int)
	
	If Result = DialogResponse.POSITIVE Then
		StopSharing
	End If
End Sub

Sub StopSharing
	B4XLoadingIndicator1.Show
	mb.SortType("server", False)
	Dim b As mirrorBord
	
	For i = mb.Size-1 To 0 Step-1
		b = mb.Get(i)
		If b.server = "1" Then
			mqtt.GenMqttFile(b.ip, "0.0.0.0" ,"0")
		Else
			mqtt.GenMqttFile(b.ip, b.ip, "0")
		End If
		Sleep(1000)
	Next
	
	If File.Exists(Starter.hostPath, "mqttP.conf") Then
		File.Delete(Starter.hostPath, "mqttP.conf")
	End If

	clvMirror.Clear
	lblServerName.Text = ""
	clsMqtt.mqttExists = False
	
	B4XLoadingIndicator1.Hide
	Sleep(1000)
	Activity.Finish
	StartActivity(config)
	CallSubDelayed(config, "lblRefresh_Click")
End Sub