B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private clsFunc As classFunc
	Private clsRetro As setRetroBord
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	clsFunc.Initialize
	clsRetro.Initialize
End Sub

Sub bordAlive(clv As CustomListView)
	Dim p As Panel
	Dim itemCount As Int = clv.Size -1
	Dim lbl As Label
	Dim colorNameTextDisabled, colorNameBgDisAbled As Int
	Dim colorNameTextEnabled, colorNameBgEnAbled As Int
	
	colorNameBgEnAbled = 0xFF0018FF
	colorNameTextEnabled = 0xFFFFE700
	colorNameTextDisabled = Colors.Red
	colorNameBgDisAbled = Colors.Black
	
	Starter.lstActiveBord.Initialize
	
	For i = 0 To itemCount
		p = clv.GetPanel(i)
		For Each v As View In p.GetAllViewsRecursive
			If v Is Label And v.Tag = "edit" Or v.Tag = "delete" Or v.Tag = "config" Or v.Tag = "retro" Then'v.Tag = "isAlive" Then
				lbl = v
				lbl.TextColor = Colors.Black
			End If
			If v Is Label And v.Tag = "name" Then
				lbl = v
				lbl.TextColor = colorNameTextEnabled'0xFFFFE700
				lbl.Color = colorNameBgEnAbled'0xFF0018FF
			End If
		Next
	Next
	
	For i = 0 To itemCount
		If i > 3 Then
			clv.ScrollToItem(i)
		End If
		p = clv.GetPanel(i)
		
		For Each v As View In p.GetAllViewsRecursive
			If v Is Label And v.Tag = "name" Then
				lbl = v
				CallSub2(config, "PullDownSetTableName", lbl.Text)
				
			End If
			
			If v Is Label And v.Tag = "ip" Then
				lbl = v
				wait for (clsFunc.pingBord(lbl.Text)) Complete (result As Boolean)
				
				For Each v1 As View In p.GetAllViewsRecursive
					'If v1 Is Label And v1.Tag = "isAlive" Then
					If v1 Is Label And v1.Tag = "name" Then
						lbl = v1
					End If
				Next
				
				If result = True Then
					'lbl.TextColor = Colors.Green
					lbl.TextColor = colorNameTextEnabled
					lbl.Color = colorNameBgEnAbled
					EnableBordOptions(result, p)
				Else
					'lbl.TextColor = Colors.Red
					lbl.TextColor = colorNameTextDisabled
					lbl.Color = colorNameBgDisAbled
					EnableBordOptions(result, p)
				End If
			End If
		Next
	Next
	Sleep(400)
	CallSub(config,"HidePullDown")
	CallSub2(config, "PullDownSetTableName", "")
	clv.ScrollToItem(0)
	
End Sub

Private Sub EnableBordOptions(enable As Boolean, p As Panel)
	For Each v As View In p.GetAllViewsRecursive
		'If v Is Label And v.Tag = "edit" Or v.Tag = "delete" Or v.Tag = "config" Or v.Tag = "retro" Then
		If v Is Label And  v.Tag = "config" Or v.Tag = "retro" Then
			Dim lbl As Label = v
			lbl.Enabled = enable
			If enable Then
				lbl.TextColor = 0xFF000000
			Else 
				lbl.TextColor = 0xFFE4E4E4
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





