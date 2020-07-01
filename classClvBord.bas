B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private clsFunc As classFunc
	Private clsMqtt As classMqtt
	Private clsSetMqtt As SetMqtt
	Private clsRetro As setRetroBord
	Private clsFindItem As classFindActiveBord
	Private mb As List
	Private mqttExists As Boolean
	Private countActiveBord As Int
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	clsFunc.Initialize
	clsMqtt.Initialize
	clsSetMqtt.Initialize
	clsRetro.Initialize
	clsFindItem.Initialize
End Sub

Sub bordAlive(clv As CustomListView)
	Dim p As Panel
	Dim itemCount As Int = clv.Size -1
	Dim lbl As Label
	Dim pValue As Int = 100/itemCount
	
	mqttExists = clsMqtt.CheckMqttExists
	
	CallSub2(config, "SetReloadBordName", "")
	
	Starter.lstActiveBord.Initialize
	mb.Initialize
	If mqttExists Then
		mb = clsMqtt.ParseMirrors
	End If
	
	ResetBordLabels(clv)
	
	countActiveBord = 0
	For i = 0 To itemCount
		p = clv.GetPanel(i)
'		CallSub2(config, "SetReloadBordName", p.Tag)
'		CallSub2(config, "UpdateProgress", pValue*i)
		For Each v As View In p.GetAllViewsRecursive
			CallSub2(config, "SetReloadBordName", p.Tag)
			CallSub2(config, "UpdateProgress", pValue*i)
			If Not (checkIsLabel(v)) Then Continue
			If v.Tag = "" Or v.Tag = "name" Then Continue
			
			If v.Tag = "ip" Then
				lbl = v
				If clsFunc.CompareIp(lbl.Text) = False Then 
					DisableButtons(p)
					Continue
				End If
				
				
				wait for (clsFunc.pingBord(lbl.Text)) Complete (result As Boolean)
				CallSub2(config, "SetReloadBordName", p.Tag)
				CallSub2(config, "UpdateProgress", pValue*i)
				
			End If
			
			If result Then countActiveBord = countActiveBord +1
			
			If Not(result) Then 'DISABLE MODIFIER BUTTONS
				DisableButtons(p)
				Exit
			End If
			
			If v.Tag = "mirror" Then
				SetMirrorColor(v)
				Continue
			End If
			If v.Tag = "retro" Then
				If mqttExists Then
					EnableLabel(v, False)
					Continue
				End If
			End If
			If v.Tag = "edit" Then
				If mqttExists Then
					EnableLabel(v, False)
					Continue
				End If
			End If
			If v.Tag = "delete" Then
				If mqttExists Then
					EnableLabel(v, False)
					Continue
				End If
			End If
		
		Next
	Next
	
	'DISABLE MIRROR If Starter.lstActiveBord.Size <= 1
	If Starter.lstActiveBord.Size <= 1 Then
		For j = 0 To itemCount
			p = clv.GetPanel(j)
			For Each v As View In p.GetAllViewsRecursive
				If v.Tag = "mirror" Then
					EnableLabel(v, False)
				End If
			Next
		Next
	End If
	
	Sleep(1000)
	CallSub2(config, "UpdateProgress", 0)
	Sleep(1000)
	CallSub(config, "HidePnlBlockInput")
End Sub




Sub EnableLabel(v As Label, enable As Boolean)
	v.Enabled = enable
	If Starter.darkTheme Then
		If enable Then
			v.TextColor = Starter.darkLabelEnabledColor
		Else
			v.TextColor =  Starter.darkLabelDisabledColor
		End If
	End If
	
	If Not(Starter.darkTheme) Then
		If enable Then
			v.TextColor = 0xff000000
		Else
			v.TextColor =  0xFFE4E4E4
		End If
	End If
	
End Sub

Sub checkIsLabel(v As View) As Boolean
	Return v Is Label
End Sub

Sub PanelBordIpName(Index As Int, clv As CustomListView, tag As String) As String
	Dim p As Panel
	Dim lbl As Label
	
	Starter.selectedBordPanel = Index
	
	p = clv.GetPanel(Index)
	For Each v As View In p.GetAllViewsRecursive
		If v Is Label And v.Tag = tag Then
			lbl = v
			Return lbl.Text
			Exit
		End If
	Next
	
	Return "unknown"
End Sub

Sub DisableButtons(p As Panel)
	Dim lbl As Label
	For Each v As View In p.GetAllViewsRecursive
'	If v Is Label And v.Tag = "config" Or v.Tag = "retro" Or v.Tag = "mirror" Or v.Tag = "edit" Or v.Tag = "delete" Or v.Tag = "bordondroid" Then
	If v Is Label And v.Tag = "config" Or v.Tag = "retro" Or v.Tag = "mirror" Or v.Tag = "bordondroid" Then
			lbl = v
			lbl.Enabled = False
			lbl.TextColor =  0xFFE4E4E4
		End If
	Next
End Sub

Sub editItem(Index As Int, clv As CustomListView)
	Starter.edtUnit = True
	Starter.selectedBordPanel = Index
	Starter.edtIpNumber = PanelBordIpName(Index, clv, "ip")
	StartActivity(units)
End Sub

Sub deleteItem(Index As Int, clv As CustomListView)
	Dim ip As String = PanelBordIpName(Index, clv, "ip")
	Starter.selectedBordPanel = Index
	
	Msgbox2Async("Geselecteerde bord verwijderen", Starter.AppName, "Ja", "", "Nee", Starter.appIcon, False)
	Wait For Msgbox_Result (Result As Int)
	If Result = DialogResponse.POSITIVE Then
		clv.RemoveAt(Index)
		gnDb.deleteBord(ip)
		CallSub(config, "getUnits")
	End If
End Sub

Sub configItem(Index As Int, clv As CustomListView)
	Starter.selectedBordIp = PanelBordIpName(Index, clv, "ip")
	Starter.selectedBordName = PanelBordIpName(Index, clv, "name")
	Starter.selectedBordPanel = Index
	StartActivity(tsBordConfig)
End Sub

Sub ConfigBordOnDroid(Index As Int, clv As CustomListView)
	Starter.selectedBordIp = PanelBordIpName(Index, clv, "ip")
	Starter.selectedBordName = PanelBordIpName(Index, clv, "name")
	Starter.selectedBordPanel = Index
	'clsSetMqtt.GenMqttFile(
End Sub

Public Sub ConfigItemRetro(Index As Int, clv As CustomListView)
	clsRetro.SetBordToRetro(PanelBordIpName(Index, clv, "ip"))
End Sub

Public Sub ConfigItemMirror(Index As Int, clv As CustomListView)
	Starter.selectedBordIp = PanelBordIpName(Index, clv, "ip")
	Starter.selectedBordName = PanelBordIpName(Index, clv, "name")
	
	StartActivity(mirror_bord)
End Sub

Sub ResetBordLabels(clv As CustomListView)
	Dim p As Panel
	Dim itemCount As Int = clv.Size -1
	Dim lbl As Label
	For i = 0 To itemCount
		p = clv.GetPanel(i)
		
		For Each v As View In p.GetAllViewsRecursive
			If v Is Label And v.Tag = "edit" Or v.Tag = "delete" Or v.Tag = "config" Or v.Tag = "retro" Or v.Tag = "mirror" Then
				lbl = v
				If Starter.darkTheme Then
					lbl.TextColor = Starter.darkLabelEnabledColor
					Else
				lbl.TextColor = Colors.Black
				End If
				lbl.Enabled = True
			End If
		Next
	Next
End Sub

Sub SetMirrorColor(lbl As Label)
	If Starter.darkTheme Then
		MirrorColorDarkTheme(lbl)
		Return
	End If
	
	If Not(mqttExists) Then
		lbl.TextColor = 0xFF000000
		lbl.Enabled = True
	Else
		lbl.TextColor = 0xFFC80C0C
		lbl.Enabled = False
	End If
End Sub

Sub MirrorColorDarkTheme(lbl As Label)
	If Not(mqttExists) Then
		
			lbl.TextColor = Starter.darkLabelDisabledColor'0xFF000000
			lbl.Enabled = True
		Else
			lbl.TextColor = Starter.darkLabelEnabledColor'0xFFC80C0C
			lbl.Enabled = False 
		End If
End Sub
