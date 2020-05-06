B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Service
Version=9.5
@EndOfDesignText@
#Region  Service Attributes 
	#StartAtBoot: False
	#ExcludeFromLibrary: True
#End Region

Sub Process_Globals
	Private rp As RuntimePermissions
	Public hostPath,  edtIpNumber, unitId, bordVersion, updateFile, upDateVersion As String
	Public fileSize As Long
	Public edtUnit As Boolean = False
	Public bordUpdate, bordAdded As Boolean= False
	Public darkTheme As Boolean = False
	Public sql As SQL
	Public xStr As String = "qlndfwjeklfnw213123912iedmd$%Gk"
	Public pw As String = "peter"
	Public doy As String ="pdegrootafr", moy As String ="hkWpXtB1!"
	Public pwSet As Boolean
	Public selectedBordPanel As Int
	Public selectedBordName, selectedBordIp, deviceIp As String
	Public lstActiveBord As List
	Public newUnitName, AppName As String
	Public appIcon As Bitmap
	Type mirrorBord(name As String, ip As String, server As String)
	
	Public darkActivityColor As Int
	Public darkClvColor As Int
	Public darkPanelColor As Int
	Public darkLabelEnabledColor As Int
	Public darkLabelDisabledColor As Int
	Public darkButtonEnabledColor As Int
	Public darkButtonDisabledColor As Int
	Public darkEditFieldTextColor As Int
	Public darkEditFieldBackColor As Int
	Public darkLabelButtonTextColor As Long
	Public darkLabelButtonBackColor As Int
	Public darkSwitchForeColor As Int
	
End Sub

Sub Service_Create
	AppName = Application.LabelName
	appIcon = LoadBitmap(File.DirAssets, "app_icon.png")
	GetDeviceIp
	SetViewColor
	hostPath = rp.GetSafeDirDefaultExternal("host")
	If File.Exists(hostPath, "boards.db") = False Then
		File.Copy(File.DirAssets, "boards.db", hostPath, "boards.db")
	End If
	sql.Initialize(hostPath, "boards.db", False)
End Sub

Sub Service_Start (StartingIntent As Intent)
	Service.StopAutomaticForeground 'Starter service can start in the foreground state in some edge cases.
End Sub

Sub Service_TaskRemoved
	'This event will be raised when the user removes the app from the recent apps list.
End Sub

'Return true to allow the OS default exceptions handler to handle the uncaught exception.
Sub Application_Error (Error As Exception, StackTrace As String) As Boolean
	Return True
End Sub

Sub Service_Destroy

End Sub

Sub GetDeviceIp
	Dim s As ServerSocket
'	s.Initialize(5555, Me)
	s.Initialize(5559, Me)
	deviceIp = s.GetMyIP
'	Log(s.GetMyIp)
End Sub

Public Sub SetViewColor
	
	darkActivityColor			= 0xFF000000
	darkClvColor				= 0xFF000000
	darkPanelColor				= 0xFF020303
	darkLabelEnabledColor		= 0xFF00FF00'x0FF00FF00
	darkLabelDisabledColor		= 0xFF028482
	darkButtonEnabledColor		= 0xFF0000FF
	darkButtonDisabledColor		= 0xFFC0C0C0
	darkEditFieldTextColor		= 0xFF00FF00
	darkEditFieldBackColor		= 0xFF000000
	darkLabelButtonTextColor	= 0xFF00FF00
	darkLabelButtonBackColor	= 0xFF003366
	darkSwitchForeColor			= 0xFF00FF00 'x0FF00FF00

	
End Sub





