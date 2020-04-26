B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.5
@EndOfDesignText@
Sub Class_Globals
'	Dim ftp As SFtp
Private parser as JSONParser
End Sub

'Initializes the object. You can add parameters to this method if needed.
Public Sub Initialize
	
End Sub


'Sub TryConnectFtp(ipNumber As String) As ResumableSub
'	ftp.Initialize("ftp", "pi", "0", ipNumber, 22)
'	ftp.SetKnownHostsStore(Starter.hostPath, "hosts.txt")
'	
'
'	ftp.DownloadFile("/home/pi/44/ver.pdg", Starter.hostPath, "ver.pdg")
'
'	wait for ftp_DownloadCompleted (ServerPath As String, Success As Boolean)
'	Return Success
'End Sub




Sub pingBord(ipNumber As String) As ResumableSub
	Dim p As Phone
	
	
	If CheckIpRange(ipNumber.Replace(".", "-")) = False Then
		Return False
	End If
	

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

Sub ParseMirrors As List
	Dim str As String = File.ReadString(Starter.hostPath, "mqttP.conf")
	Private mb As List
	
	mb.Initialize
	parser.Initialize(str)
	
	Dim root As List = parser.NextArray
	For Each colroot As Map In root
		Dim b As mirrorBord
						
		b.name = GetBordNameFromIp(colroot.Get("ip"))
		b.ip = colroot.Get("ip")
		b.server = colroot.Get("server")
		mb.Add(b)
	Next
	Return mb
End Sub

Sub GetBordNameFromIp(ip As String) As String
	Dim lst As List = gnDb.getUnit(ip)
	
	Return lst.Get(0)
End Sub
'Sub countChars(str As String, maxCount As Int) As Boolean
'	If str.Length < 1 Then Return True
'	
'	If str.Length > maxCount Then
''		createCustomToast($"Maximaal ${maxCount} tekens.."$, Colors.Blue)
'		Return False
'	End If
'	Return True
'End Sub


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


