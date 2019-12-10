B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=9.5
@EndOfDesignText@
Sub Process_Globals
	Dim qry As String

End Sub


Sub RetieveBoards As Cursor
	qry = "SELECT * FROM unit ORDER BY description"
	
	Return Starter.sql.ExecQuery(qry)	
End Sub



Sub GUID As String
	Dim sb As StringBuilder
	sb.Initialize
	For Each stp As Int In Array(8, 4, 4, 4, 12)
		If sb.Length > 0 Then sb.Append("-")
		For n = 1 To stp
			Dim c As Int = Rnd(0, 16)
			If c < 10 Then c = c + 48 Else c = c + 55
			sb.Append(Chr(c))
		Next
	Next
	Return sb.ToString
End Sub