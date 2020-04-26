﻿B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private clsFunc As classFunc
	Private clsMqtt As classMqtt
	Private clsRetro As setRetroBord
	Private mb As List
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	clsFunc.Initialize
	clsMqtt.Initialize
	clsRetro.Initialize
End Sub

Sub bordAlive(clv As CustomListView)
	Dim p As Panel
	Dim itemCount As Int = clv.Size -1
	Dim lbl As Label
	Dim colorNameTextDisabled, colorNameBgDisAbled As Int
	Dim colorNameTextEnabled, colorNameBgEnAbled As Int
	
	colorNameBgEnAbled = 0xFF004BA0 '0xFF0018FF
	colorNameTextEnabled = 0xFFA0B7D7'0xFFFFE700
	colorNameTextDisabled = Colors.Red
	colorNameBgDisAbled = Colors.Black
	
	Starter.lstActiveBord.Initialize
	mb.Initialize
	If clsMqtt.mqttExists Then
		mb = clsMqtt.ParseMirrors
	End If
	
	For i = 0 To itemCount
		p = clv.GetPanel(i)
		
		For Each v As View In p.GetAllViewsRecursive
			If v Is Label And v.Tag = "edit" Or v.Tag = "delete" Or v.Tag = "config" Or v.Tag = "retro" Then'v.Tag = "isAlive" Then
				lbl = v
				lbl.TextColor = Colors.Black
			End If
			If v Is Label And v.Tag = "name" Or v.Tag = "ip" Then
				lbl = v
				lbl.TextColor = colorNameTextEnabled'0xFFFFE700
				lbl.Color = colorNameBgEnAbled'0xFF0018FF
			End If
		Next
	Next
	
	For i = 0 To itemCount
		p = clv.GetPanel(i)
		
		For Each v As View In p.GetAllViewsRecursive
			If v Is Label And v.Tag = "name" Then
				lbl = v
			End If
			
			If v Is Label And v.Tag = "ip" Then
				lbl = v
				wait for (clsFunc.pingBord(lbl.Text)) Complete (result As Boolean)
				
				For Each v1 As View In p.GetAllViewsRecursive
					
					If v1.Tag = "mirror" And clsMqtt.mqttExists = False Or result = False Then
						lbl.TextColor = 0xFF000000
						lbl.Enabled = False
					Else
						lbl.TextColor = 0xFFC80C0C
						lbl.Enabled = True
					End If
					
					If v1 Is Label And v1.Tag = "name" Or v1.Tag = "ip" Then
						lbl = v1
						If result = True Then
							lbl.TextColor = colorNameTextEnabled
							lbl.Color = colorNameBgEnAbled
							EnableBordOptions(result, lbl)
						Else
							lbl.TextColor = colorNameTextDisabled
							lbl.Color = colorNameBgDisAbled
							EnableBordOptions(result, lbl)
						End If
					End If
				Next
				
			End If
		Next
	Next
	Sleep(400)
	''	CallSub(config,"HidePullDown")
	''	CallSub2(config, "PullDownSetTableName", "")
	
	
End Sub

Private Sub EnableBordOptions(enable As Boolean, lbl As Label)
	lbl.Enabled = enable
	If enable Then
		lbl.TextColor = 0xFF000000
	Else
		lbl.TextColor = 0xFFE4E4E4
	End If
	'STORE ENABLED BORD IPNUMBER
	If enable And lbl.Tag = "ip" Then
		If Starter.lstActiveBord.IndexOf(lbl.Text) = -1 Then
			Starter.lstActiveBord.Add(lbl.Text)
		End If
	End If
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
	
	Starter.selectedBordPanel = Index
	
	p = clv.GetPanel(Index)
	For Each v As View In p.GetAllViewsRecursive
		If v Is Label And v.Tag = "ip" Then
			lbl = v
			Msgbox2Async("Geselecteerde bord verwijderen", "", "Ja", "", "Nee", Null, False)
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
	
'	For Each v As View In p.GetAllViewsRecursive
'		If v Is Label And v.Tag = "retro" Then
'			lbl = v
'			name = lbl.Text
'			Exit
'		End If
'	Next
	
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



