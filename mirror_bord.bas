B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9.801
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: false
	#IncludeTitle: true
#End Region
'#IgnoreWarnings: 10, 11, 12 , 20
#Extends: android.support.v7.app.AppCompatActivity

Sub Process_Globals

End Sub

Sub Globals
	Private toolbar As ACToolBarDark
	Private lblBordNaam As Label
	Private pnlDeelBord As Panel
	Private clvDelen As CustomListView
	Private lblClientBord As Label
	Private lblClientIp As Label
	Private btnStartShare As Button
	Private ACSwitch1 As ACSwitch
	Private shareCount As Int = 0
	Private shareIpList As List
	Private pnlClv As Panel
End Sub

Sub Activity_Create(FirstTime As Boolean)
	Activity.LoadLayout("mirror_bord")
	lblBordNaam.Text = Starter.selectedBordName
	shareIpList.Initialize
	
	GetDeelBorden
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub

Sub GetDeelBorden()
	clvDelen.Clear
	Dim count As Int = 0
	Dim lst As List
	Dim aWidth As Int = clvDelen.AsView.Width
	Dim aHeight As Int = 250
	
	For Each item As String In Starter.lstActiveBord
		If item = Starter.selectedBordIp Then
			
		Else
			'Log($"BORD IS CLIENT (${item&".0"})"$)
			lst.Initialize
			lst = gnDb.getUnit(item)
			If lst.Size < 1 Then Continue
			clvDelen.Add(AddBord(aWidth, lst.Get(0), lst.Get(1), aHeight), count)
			count = count + 1
		End If
	Next
	
End Sub

Sub AddBord(width As Int, name As String, ip As String, height As Int) As Panel
	Dim p As Panel
	p.Initialize(Me)
	p.SetLayout(0dip, 10dip, width-10, height) '190
	p.LoadLayout("clvDeelBord")
	'p.LoadLayout("deel_bord")
	p.Tag = ip
	
	lblClientBord.Text = name
	lblClientBord.Tag = ip
	
	lblClientIp.Text = ip
	
	
	Return p
End Sub


Sub btnStartShare_Click
	
End Sub

Sub ACSwitch1_CheckedChange(Checked As Boolean)
	Dim ip As String
	Dim v As ACSwitch
	v.Initialize(Me)
	v = Sender
	Dim p As Panel = v.Parent
	
	
	
	If Checked Then
		shareCount = shareCount +1
	Else
		shareCount = shareCount -1
	End If
	
	For Each vw As View In p.GetAllViewsRecursive
		If vw.Tag = "IP Number" Then
			Dim lbl As Label = vw
			lbl = vw
			ip = lbl.Text
			Exit
		End If
	Next


	If Checked Then
		shareIpList.Add(ip)
	Else
		For i = shareIpList.Size - 1 To 0 Step -1	
			If shareIpList.Get(i) = ip Then
				shareIpList.RemoveAt(i)
			End If
		Next
	End If
	If shareCount > 1 Then btnStartShare.Text = "Deel op borden"	
	If shareCount <= 1 Then btnStartShare.Text = "Deel op bord"	
	btnStartShare.Enabled = shareCount > 0
	
End Sub






Sub clvDelen_ItemClick (Index As Int, Value As Object)
	Dim p As Panel = clvDelen.GetPanel(Index)
	Dim sw As ACSwitch
	
	
	For Each v As View In p.GetAllViewsRecursive
		If v Is ACSwitch Then
			sw = v
			If sw.Checked Then
				sw.Checked = False
			Else 
				sw.Checked = True	
			End If
			Exit
		End If
	Next
	
End Sub