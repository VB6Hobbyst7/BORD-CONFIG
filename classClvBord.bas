B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Private clsFunc As classFunc
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	clsFunc.Initialize
End Sub

Sub bordAlive(clv As CustomListView)
	Dim p As Panel
	Dim itemCount As Int = clv.Size -1
	Dim lbl As Label
	Dim scrollOffset As Int = clv.AsView.ScrollViewOffsetY
	
	Starter.lstActiveBord.Initialize
	
	For i = 0 To itemCount
		p = clv.GetPanel(i)
		For Each v As View In p.GetAllViewsRecursive
			If v Is Label And v.Tag = "isAlive" Then
				lbl = v
				lbl.TextColor = Colors.Black
			End If
		Next
	Next
	
	For i = 0 To itemCount
		'Sleep(300)
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
					If v1 Is Label And v1.Tag = "isAlive" Then
						lbl = v1
					End If
				Next
				
				If result = True Then
					lbl.TextColor = Colors.Green
				Else
					lbl.TextColor = Colors.Red
				End If
			End If
			
		Next
	Next
	Sleep(400)
	CallSub(config,"HidePullDown")
	CallSub2(config, "PullDownSetTableName", "")
	clv.ScrollToItem(0)
	
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
	
	Starter.selectedBordName = name
	Starter.selectedBordIp = ip
	
	StartActivity(tsBordConfig)
	
End Sub