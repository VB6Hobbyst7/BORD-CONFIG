B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private clsFunc As classFunc
	Private clsMqtt As classMqtt
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
	clsRetro.Initialize
	clsFindItem.Initialize
End Sub

Sub bordAlive(clv As CustomListView)
	Dim p As Panel
	Dim itemCount As Int = clv.Size -1
	Dim lbl As Label
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
		
		clv.ScrollToItem(i)
		
'	Log($"CURRENT INDEX : ${i} LAST VISIBLE INDEX : ${clv.LastVisibleIndex}"$)
		'GET AND SHOW FIND ICON TAG IS findbord
		clsFindItem.ShowFindIcon(p, i, False)
		
		For Each v As View In p.GetAllViewsRecursive
			If Not (checkIsLabel(v)) Then Continue
			If v.Tag = "" Or v.Tag = "name" Then Continue
			
			If v.Tag = "ip" Then
				lbl = v
				wait for (clsFunc.pingBord(lbl.Text)) Complete (result As Boolean)
				CallSub2(config, "SetReloadBordName", p.Tag)
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
	
	'GET AND SHOW FIND ICON TAG IS findbord
	Sleep(1000)
	clsFindItem.ShowFindIcon(p, i, True)
	
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

Sub DisableButtons(p As Panel)
	Dim lbl As Label
	For Each v As View In p.GetAllViewsRecursive
		If v Is Label And v.Tag = "config" Or v.Tag = "retro" Or v.Tag = "mirror" Then
			lbl = v
			lbl.Enabled = False
			If Starter.darkTheme Then
				lbl.TextColor = Starter.darkLabelDisabledColor
			Else
			lbl.TextColor =  0xFFE4E4E4
			End If
		End If
	Next
End Sub

Sub editItem(Index As Int, clv As CustomListView)
	Dim p As Panel
	Dim lbl As Label
	
	Starter.selectedBordPanel = Index
	
	p = clv.GetPanel(Index)
	For Each v As View In p.GetAllViewsRecursive
		If v Is Label And v.Tag = "ip" Then
			lbl = v
			Starter.edtUnit = True
			Starter.edtIpNumber = lbl.Text
			StartActivity(units)
			Exit
		End If
	Next
	
End Sub

Sub deleteItem(Index As Int, clv As CustomListView)
	Dim p As Panel
	Dim lbl As Label
	Dim xui As XUI

'	Dim icon As B4XBitmap = xui.LoadBitmapResize(File.DirAssets, "app_icon.png", 60dip, 60dip, True)
'	Dim sf As Object = xui.Msgbox2Async("Delete file?", Starter.AppName, "Yes", "Cancel", "No", icon)
'	
'	Wait For (sf) Msgbox_Result (Result As Int)
'	If Result = xui.DialogResponse_Positive Then
'		Log("Deleted!!!")
'	End If
	
	
	Starter.selectedBordPanel = Index
	
	p = clv.GetPanel(Index)
	For Each v As View In p.GetAllViewsRecursive
		If v Is Label And v.Tag = "ip" Then
			lbl = v
			
			Msgbox2Async("Geselecteerde bord verwijderen", Starter.AppName, "Ja", "", "Nee", Starter.appIcon, False)
			Wait For Msgbox_Result (Result As Int)
			If Result = DialogResponse.POSITIVE Then
				clv.RemoveAt(Index)
				gnDb.deleteBord(lbl.Text)
				CallSub(config, "getUnits")
			End If
			Exit
		End If
	Next
	
End Sub

Sub configItem(Index As Int, clv As CustomListView)
	Dim p As Panel
	Dim lbl As Label
	Dim name, ip As String
	
	Starter.selectedBordPanel = Index
	
	p = clv.GetPanel(Index)
	For Each v As View In p.GetAllViewsRecursive
		If v Is Label And v.Tag = "ip" Then
			lbl = v
			ip = lbl.Text
			Exit
		End If
	Next
	
	For Each v As View In p.GetAllViewsRecursive
		If v Is Label And v.Tag = "name" Then
			lbl = v
			name = lbl.Text
			Exit
		End If
	Next
	
	Starter.selectedBordName = name
	Starter.selectedBordIp = ip
	
	StartActivity(tsBordConfig)
	
End Sub

Public Sub ConfigItemRetro(Index As Int, clv As CustomListView)
	Dim p As Panel
	Dim lbl As Label
	Dim ip As String
	
	p = clv.GetPanel(Index)
	For Each v As View In p.GetAllViewsRecursive
		If v Is Label And v.Tag = "ip" Then
			lbl = v
			ip = lbl.Text
			Exit
		End If
	Next
	clsRetro.SetBordToRetro(ip)
End Sub

Public Sub ConfigItemMirror(Index As Int, clv As CustomListView)
	Dim p As Panel
	Dim lbl As Label
	Dim name, ip As String
	
	p = clv.GetPanel(Index)
	For Each v As View In p.GetAllViewsRecursive
		If v Is Label And v.Tag = "ip" Then
			lbl = v
			ip = lbl.Text
			Exit
		End If
	Next
	For Each v As View In p.GetAllViewsRecursive
		If v Is Label And v.Tag = "name" Then
			lbl = v
			name = lbl.Text
			Exit
		End If
	Next
	Starter.selectedBordName = name
	Starter.selectedBordIp = ip
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
