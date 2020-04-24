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
	Type mirrorBord(name As String, ip As String, server As String)
End Sub

Sub Globals
	Private parser As JSONParser
	Dim mb As List
	
	Private btnStopDelen As Label
	Private clvMirror As CustomListView
	Private lblServerName As Label
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("delen_aktief")
	mb.Initialize
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
	Dim str As String = File.ReadString(Starter.hostPath, "mqtt.conf")
	Dim lstFromDb As List
	
	
	lstFromDb.Initialize
	
	parser.Initialize(str)
	Dim root As List = parser.NextArray
	For Each colroot As List In root
		For Each colcolroot As Map In colroot
			Dim server As Int = colcolroot.Get("server")
			Dim ip As String = colcolroot.Get("ip")
			Dim b As mirrorBord
			
			lstFromDb = gnDb.getUnit(ip)
			
			b.name = lstFromDb.Get(0)
			b.ip = ip
			b.server = server
			mb.Add(b)
		Next
	Next
	GenClv
End Sub

Sub GenClv()
For i = 0 To mb.Size-1
		mb.SortType("server", False)
		
	Dim b As mirrorBord
	b = mb.Get(i)
	
	If b.server = "1" Then
		lblServerName.Text = b.name
		lblServerName.Tag = b.ip
	End If
	
	Log($"${b.name} ${b.ip} ${b.server}"$)
Next
	
End Sub

Sub btn_test_Click
	
End Sub