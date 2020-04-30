B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
	
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub

Sub pingBord(ipNumber As String) As ResumableSub
	Dim p As Phone
	
'	Log($"PING BORD ${ipNumber}"$)
	
'	If CheckIpRange(ipNumber.Replace(".", "-")) = False Then
'		Return False
'	End If
	

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


Sub SetLabelColor(labels As List, bgColor As Long, fgColor As Long)
	Dim lbl As Label
	
	For Each v In labels
		lbl = v
		lbl.Color = bgColor
		lbl.TextColor = fgColor
	Next
End Sub

