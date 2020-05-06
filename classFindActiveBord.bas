B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.801
@EndOfDesignText@
Sub Class_Globals
	Public currPanel As Panel
	Private currLabel As Label
	Public currItem As String
	Public showItem As Boolean
	Public itemCount As InputStream
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	currLabel.Initialize(Me)
End Sub

Sub ShowFindIcon(panel As Panel, index As String, isLast As Boolean)
	Dim lbl As Label

	If isLast Then
		currLabel.Visible = False
		Return
	End If
	
	For Each v As View In panel.GetAllViewsRecursive
		If v.Tag = "findbord" Then
			lbl = v
			Exit
		End If
	Next
	
	If currItem = "" Then
		currItem = index
		currLabel = lbl
		lbl.Visible = True
		Return
	End If
	
	If currItem <> index Then
		currLabel.Visible = False
		currItem = index
		currLabel = lbl
		lbl.Visible = True
		Return
	End If
	
	
	
End Sub