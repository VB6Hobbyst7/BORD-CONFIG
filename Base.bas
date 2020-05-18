B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.801
@EndOfDesignText@
Sub Class_Globals
	Private baseList As List
	Private baseFile, baseFolder As String
	Private serializator As B4XSerializator
	Private rp As RuntimePermissions
End Sub

Public Sub Initialize(fileName As String, fileFolder As String)
	'FILENAME, FOLDER
	CheckFileExists(fileFolder, fileName)
	
	'baseFile = CallSub(Starter, "GetBaseFilePath")
	'baseList.Initialize
End Sub
'
Public Sub GetBase As List
	If CheckBaseListExists Then
		Return serializator.ConvertBytesToObject(File.ReadBytes(baseFile, ""))
	Else
		Return Null
	End If
End Sub

Public Sub SetBase(baseName As String)
'	Dim loc As locationBord
	Dim lst As List
	
'	loc.Initialize
	lst.Initialize
	
'	loc.code = baseName
'	loc.description = "Nieuwe locatie"
'	loc.isdefault = "1"
	
	If CheckBaseListExists Then
		lst = File.ReadList(baseFile, "")
	End If
'	lst.Add(loc)

	writeList(lst)
End Sub

Private Sub CheckBaseListExists As Boolean
	If File.Exists(baseFile, "") Then
		Return True
	End If
	Return False
End Sub

Public Sub ModifyLocation(oldLocation As String, newLocation As String, description As String, isDefault As Boolean)
	Dim modList As List = GetBase
	
'	For Each location As locationBord In modList
'		If location.code = oldLocation Then
'			location.code = newLocation
'			location.description = description
'			If isDefault Then
'				location.isdefault = "1"
'			Else
'				location.isdefault = "0"
'			End If
'			Exit
'		End If
'	Next
'	writeList(modList)
End Sub

Private Sub writeList(lst As List)
	serializator.ConvertObjectToBytes(lst)
	File.WriteBytes(baseFile, "", serializator.ConvertObjectToBytes(lst))
End Sub

Private Sub CheckFileExists(fileFolder As String, fileName As String)
	Dim getBaseFolder As String = File.Combine(fileFolder, fileName)
	
	If File.Exists(getBaseFolder, "") = False Then
		rp.GetSafeDirDefaultExternal(getBaseFolder)
	End If
	baseFolder = getBaseFolder
End Sub