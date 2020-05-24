B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.801
@EndOfDesignText@
Sub Class_Globals
	Private serializer As B4XSerializator
	Dim parser As JSONParser
	Dim jsonGen As JSONGenerator
	
	Private bordMqtt As String
	Private bordMqttName As String = "bordMqtt-map"
End Sub

Public Sub Initialize
	'CheckBordMqttExists
End Sub

Private Sub GetBordMqtt
	If File.Exists(Starter.hostPath, bordMqttName) Then
		bordMqtt =serializer.ConvertBytesToObject( File.ReadBytes(Starter.hostPath, bordMqttName))
	Else 
		bordMqtt = ""	
	End If
End Sub

Private Sub SetBordMatt(mqtt As String)
	File.WriteBytes(Starter.hostPath, bordMqttName, serializer.ConvertObjectToBytes(mqtt))
End Sub

Public Sub MirrorBord(bordName As String)
	GetBordMqtt
	
	If bordMqtt.Length > 0 Then 'process json
		parseMqtt(bordMqtt)
	
	Else
		Dim mqttMap As Map
		Dim baseMap As Map
		Dim baseList As List
		
		
		baseList.Initialize

		mqttMap.Initialize
		mqttMap.Put("baseName", "pdeg")
		mqttMap.Put("name", "PI 192.168.1.40")
		mqttMap.Put("enabled", "1")
		baseList.Add(mqttMap)
		
		mqttMap.Initialize
		mqttMap.Put("baseName", "pdeg")
		mqttMap.Put("name", "PI 192.168.1.41")
		mqttMap.Put("enabled", "1")
		baseList.Add(mqttMap)
		
		baseMap.Initialize
		baseMap.Put("base", baseList)
				
		jsonGen.Initialize(baseMap)
		SetBordMatt(jsonGen.ToString)
	End If
End Sub


Private Sub parseMqtt(data As String)
	Dim mqttList As List
	
	mqttList.Initialize
	
	parser.Initialize(data)
	Dim root As Map = parser.NextObject
	Dim mqttBase As List = root.Get("base")
	For Each colbase As Map In mqttBase
		Dim name As String = colbase.Get("name")
		Dim baseName As String = colbase.Get("baseName")
		Dim enabled As String = colbase.Get("enabled")
		mqttList.Add(Array As String(name, baseName, enabled))
	Next
End Sub