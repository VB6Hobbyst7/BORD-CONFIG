B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.801
@EndOfDesignText@
Sub Class_Globals
	Private parser As JSONParser
End Sub


Public Sub Initialize
	
End Sub

Public Sub CheckMqttExists As Boolean
	Return File.Exists(Starter.hostPath, "mqttP.conf")
End Sub

Sub ParseMirrors As List
	Dim str As String = File.ReadString(Starter.hostPath, "mqttP.conf")
	Private mb As List
	
	mb.Initialize
	parser.Initialize(str)
	
	Dim root As List = parser.NextArray
	For Each colroot As Map In root
		Dim b As mirrorBord
						
		b.name = GetBordNameFromIp(colroot.Get("ip"))
		b.ip = colroot.Get("ip")
		b.server = colroot.Get("server")
		mb.Add(b)
	Next
	Return mb
End Sub

Sub GetBordNameFromIp(ip As String) As String
	Dim lst As List = gnDb.getUnit(ip)
	
	Return lst.Get(0)
End Sub