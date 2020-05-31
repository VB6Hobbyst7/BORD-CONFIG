B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	Dim p As Phone
	Private serializer As B4XSerializator
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

Sub GetBaseName As String
	Dim baseBytes() As Byte
	Dim baseName As String
	
	If File.Exists(Starter.hostPath, "base-config") Then
		baseBytes = File.ReadBytes(Starter.hostPath, "base-config")
		baseName = GetBaseNameFromBytes(serializer.ConvertBytesToObject(baseBytes))
	End If
	Return baseName
End Sub

Sub GetBaseNameFromBytes(baseFile As String) As String
	Dim baseName As String
	If baseFile.Length = 0 Then 
		Return baseName
	End If
	
	Dim parser As JSONParser
	parser.Initialize(baseFile)
	Dim root As Map = parser.NextObject
	Dim baseJ As List = root.Get("base")
	For Each colbase As Map In baseJ
		baseName = colbase.Get("baseName")
	Next
	
	Return baseName
End Sub

Sub pingBord(ipNumber As String) As ResumableSub
	Wait For (p.ShellAsync("ping", Array As String("-c", "1", ipNumber))) Complete (Success As Boolean, ExitValue As Int, StdOut As String, StdErr As String)
	If Success Then
		If StdOut.IndexOf("Destination Host Unreachable") <> -1 Then
			
			Return False
		Else
			If Starter.lstActiveBord.IndexOf(ipNumber) = -1 Then
				Starter.lstActiveBord.Add(ipNumber)
			End If
			Return True
		End If
	Else
		Return False
	End If
End Sub

'padText e.g. "9", padChar e.g. "0", padSide 0=left 1=right, padCount e.g. 2
Public Sub padString(padText As String ,padChr As String, padSide As Int, padCount As Int) As String
	Dim padStr As String
	
	If padText.Length = padCount Then
		Return padText
	End If
	
	For i = 1 To padCount-padText.Length
		padStr = padStr&padChr
	Next
	
	If padSide = 0 Then
		Return padStr&padText
	Else
		Return padText&padStr
	End If
	
End Sub


Sub createCustomToast(txt As String, color As String)
	Dim cs As CSBuilder
	cs.Initialize.Typeface(Typeface.LoadFromAssets("Arial.ttf")).Color(Colors.White).Size(16).Append(txt).PopAll
	ShowCustomToast(cs, False, color)
End Sub

Sub ShowCustomToast(Text As Object, LongDuration As Boolean, BackgroundColor As Int)
	Dim ctxt As JavaObject
	ctxt.InitializeContext
	Dim duration As Int
	If LongDuration Then duration = 1 Else duration = 0
	Dim toast As JavaObject
	toast = toast.InitializeStatic("android.widget.Toast").RunMethod("makeText", Array(ctxt, Text, duration))
	Dim v As View = toast.RunMethod("getView", Null)
	Dim cd As ColorDrawable
	cd.Initialize(BackgroundColor, 20dip)
	v.Background = cd
	'uncomment to show toast in the center:
	'  toast.RunMethod("setGravity", Array( _
	' Bit.Or(Gravity.CENTER_HORIZONTAL, Gravity.CENTER_VERTICAL), 0, 0))
	toast.RunMethod("show", Null)
End Sub



Public Sub SetTextShadow(pView As View, pRadius As Float, pDx As Float, pDy As Float, pColor As Int)
	Dim ref As Reflector
   
	ref.Target = pView
	ref.RunMethod4("setShadowLayer", Array As Object(pRadius, pDx, pDy, pColor), Array As String("java.lang.float", "java.lang.float", "java.lang.float", "java.lang.int"))
End Sub

Public Sub CheckIpRange(ip As String) As Boolean
	Dim lstBord, lstDevice As List
	Dim deviceIp As String = Starter.deviceIp
	
	
	lstBord.Initialize
	lstDevice.Initialize
	deviceIp = 	deviceIp.Replace(".", "-")
	
	lstBord = Regex.Split("-", ip)
	lstDevice = Regex.Split("-", deviceIp)

	
	If lstBord.Get(2) = lstDevice.Get(2) Then
		Return True
	Else
		Return False
	End If
End Sub

Sub IsValidIp(ip As String) As Boolean
	Dim m As Matcher
	m = Regex.Matcher("^(\d+)\.(\d+)\.(\d+)\.(\d+)$", ip)
	If m.Find = False Then Return False
	For i = 1 To 4
		If m.Group(i) > 255 Or m.Group(i) < 0 Then Return False
	Next
	Return True
End Sub

Sub CompareIp(ipNumber As String) As Boolean
	Dim deviceIp, passedIp As List
	
	deviceIp = Regex.Split("_", Starter.deviceIp.Replace(".", "_"))
	passedIp = Regex.Split("_", ipNumber.Replace(".", "_"))
	
	For i = 0 To 2
	If deviceIp.Get(i) <> passedIp.Get(i) Then
			Return False
		End If
	Next
	Return True
End Sub

Sub SetLabelColor(labels As List, bgColor As Long, fgColor As Long)
	Dim lbl As Label
	
	For Each v In labels
		lbl = v
		lbl.Color = bgColor
		lbl.TextColor = fgColor
	Next
End Sub

Sub NameToCamelCase(name As String) As String
	Dim nameList() As String = Regex.Split(" ", name)
	If nameList.Length = 2 Then
		nameList(0) = SetFirstLetterUpperCase(nameList(0))
		nameList(1) = SetFirstLetterUpperCase(nameList(1))
		Return $"${nameList(0)} ${nameList(1)}"$
	End If
	If nameList.Length = 3 Then
		nameList(0) = SetFirstLetterUpperCase(nameList(0))
		nameList(2) = SetFirstLetterUpperCase(nameList(2))
		Return $"${nameList(0)} ${nameList(1).ToLowerCase} ${nameList(2)}"$
	End If

	Return name
End Sub

Private Sub SetFirstLetterUpperCase(str As String) As String
	str = str.ToLowerCase
	Dim m As Matcher = Regex.Matcher("\b(\w)", str)
	Do While m.Find
		Dim i As Int = m.GetStart(1)
		str = str.SubString2(0, i) & str.SubString2(i, i + 1).ToUpperCase & str.SubString(i + 1)
	Loop
	
	Return str
End Sub