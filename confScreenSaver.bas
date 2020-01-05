B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Activity
Version=9.5
@EndOfDesignText@
#Region  Activity Attributes 
	#FullScreen: False
	#IncludeTitle: True
#End Region

Sub Process_Globals
	'These global variables will be declared once when the application starts.
	'These variables can be accessed from all modules.

End Sub

Sub Globals
	'These global variables will be redeclared each time the activity is created.
	'These variables can only be accessed from this module.

	Private edt_regel_1 As EditText
	Private edt_regel_3 As EditText
	Private edt_regel_4 As EditText
	Private edt_regel_5 As EditText
	Private pnl_config As Panel
	Private edt_regel_2 As EditText
End Sub

Sub Activity_Create(FirstTime As Boolean)
	'Do not forget to load the layout file created with the visual designer. For example:
	'Activity.LoadLayout("Layout1")
	edt_regel_1.Initialize(Me)
	edt_regel_2.Initialize(Me)
	edt_regel_3.Initialize(Me)
	edt_regel_4.Initialize(Me)
	edt_regel_5.Initialize(Me)
	setForceNext
	Activity.Finish
End Sub

Sub Activity_Resume

End Sub

Sub Activity_Pause (UserClosed As Boolean)

End Sub


Sub setForceNext
	Log("SDSD")
	editTextForceNext(edt_regel_1)
	editTextForceNext(edt_regel_2)
	editTextForceNext(edt_regel_3)
	editTextForceNext(edt_regel_4)
	editTextForceNext(edt_regel_5)
End Sub

Sub editTextForceNext(v As EditText)
	Dim r As Reflector
	r.Target = v
	r.RunMethod2("setImeOptions", 5, "java.lang.int")
End Sub

Sub edt_regel_2_TextChanged (Old As String, New As String)
	
End Sub