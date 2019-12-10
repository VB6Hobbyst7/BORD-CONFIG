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


Sub addBord(description As String, ipNumber As String)
	Dim curs As Cursor
	
	qry = "INSERT INTO unit (description, ip_number) VALUES(?,?)"
	Starter.sql.ExecNonQuery2(qry, Array As String(description, ipNumber))
		
End Sub


Sub bordNameExists(name As String) As Boolean
	Dim curs As Cursor
	Dim count As Int
	
	qry = "SELECT COUNT(*) as cnt FROM unit WHERE description = ? COLLATE NOCASE"
	curs = Starter.sql.ExecQuery2(qry, Array As String(name))
	curs.Position = 0
	count = curs.GetInt("cnt")
	curs.Close
	
	If count > 0 Then
		Return True
	End If
	Return False
End Sub

Sub bordIpExists(ip As String) As Boolean
	Dim curs As Cursor
	Dim count As Int
	
	qry = "SELECT COUNT(*) cnt FROM unit WHERE ip_number = ? COLLATE NOCASE"
	curs = Starter.sql.ExecQuery2(qry, Array As String(ip))
	curs.Position = 0
	count  = curs.GetInt("cnt")
	curs.Close
	
	If count > 0 Then
		Return True
	End If
	Return False
	
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