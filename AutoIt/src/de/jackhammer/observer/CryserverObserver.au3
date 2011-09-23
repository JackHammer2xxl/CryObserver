;create by jack hammer 2 xxl free use copy and so on


;include other scripts
#include <GuiConstants.au3>
#include <Constants.au3>
#include <Array.au3>

;We need some variabls &
;Some constance
Global $workingBatch = "startup.bat"
Global $hWnd = "Crysis Wars Dedicated Server"
Global $autostartkey = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
Global $autostart

;this the process musst exsists or we start them.
Dim $cmdLineArgs[3]
$cmdLineArgs[0] = "bin64\crysiswarsdedicatedserver  -root ""C:\Games\CrysisWars Server\Server Steelmill"" +exec ""server.cfg"" -mod AegisX";"bin64\crysiswarsdedicatedserver  -root ""C:\Games\Electronic Arts\Crytek\Server Steelmill"" +exec ""server.cfg"" -mod AegisX"
$cmdLineArgs[1] = "bin64\crysiswarsdedicatedserver  -root ""C:\Games\CrysisWars Server\Server Mesa"" +exec ""server.cfg"" -mod AegisX" ;"bin64\crysiswarsdedicatedserver  -root ""C:\Games\Electronic Arts\Crytek\Server Mesa"" +exec ""server.cfg"" -mod AegisX"
$cmdLineArgs[2] = "bin64\crysiswarsdedicatedserver  -root ""C:\Games\CrysisWars Server\Server PS"" +exec ""server.cfg"" -mod AegisX" ;"bin64\crysiswarsdedicatedserver  -root ""C:\Games\Electronic Arts\Crytek\Server PS"" +exec ""server.cfg"" -mod AegisX"





; here is the executable path from the batch file assoziative to the other array.
Dim $workinDir[3]
$workinDir[0] = "C:\Games\CrysisWars Server\Server Steelmill" ;"C:\Games\Electronic Arts\Crytek\Server Steelmill"
$workinDir[1] = "C:\Games\CrysisWars Server\Server Mesa" ;"C:\Games\Electronic Arts\Crytek\Server Mesa"
$workinDir[2] = "C:\Games\CrysisWars Server\Server PS" ;"C:\Games\Electronic Arts\Crytek\Server PS"


;is process in observer list ?
Global $isMesaInChecklist 		= True
Global $isSteelmillInChecklist  = True
Global $isPSInChecklist 		= True


; main function
createTrayMenue()
main()



MsgBox(0, "ENDE", "all done")

Func main()
	logWrite("Crysis-Gameserver-observer wurde gestartet design by JackHammer2xxl2")

	;startServerInstance( $cmdLineArgs[2]) ;  line success invoke of any process
	runloop()
EndFunc   ;==>main

; the simple error handle, need if we have no process response
Func resetErrorWindow()

	If WinExists($hWnd) Then
		WinClose($hWnd)
		logWrite("Gameserver reagiert nicht mehr, exit process ")
		pushTrayMessage("Some server get no response")
	EndIf

EndFunc



; main run loop
Func runloop()

	While (True)
		Sleep(5000) ;five seconds
		resetErrorWindow()
		observer()
	WEnd

EndFunc   ;==>runloop




Func startServerInstance($directory, $executable) ; execute the batch file in specifierd target.
	FileChangeDir($directory)
	Run($executable, "", @SW_MINIMIZE)
	pushTrayMessage("Restart " & $directory )
	logWrite("Restart " & $directory )
EndFunc   ;==>startServerInstance


; Observer function called from run loop
Func observer()
	$executable = "CrysisWarsDedicatedServer.exe"

	$processList = getProcessesByName($executable)


	For $index = 0 To 2
		If checkInstanceIsOnline($cmdLineArgs[$index], $processList) Then
			; do nothing
		Else
			startServerInstance($workinDir[$index], $workingBatch)
			;MsgBox(0, "Missing start", $workinDir[$index] )
		EndIf
	Next


EndFunc   ;==>observer


Func checkInstanceIsOnline($exspected, $processList)

	For $process In $processList
		$process = $process.Commandline

		$result = StringCompare($process, $exspected, 0)
		;MsgBox(0, "Compare result: " & $result , "search:: " & $exspected  & @CRLF & "current: " &$process)
		If $result = 0 Then
			Return True
		EndIf
	Next

	Return False

EndFunc   ;==>checkInstanceIsOnline

; Windows Management Instrumentation !!!
;We use query language
Func getProcessesByName($processName)
	$strComputer = "."
	$wmiObject = ObjGet("winmgmts:{impersonationLevel=impersonate}!\\" & $strComputer & "\root\cimv2")
	$processQuery = "SELECT * FROM Win32_Process WHERE Name = '" & $processName & "'"
	$processCollection = $wmiObject.ExecQuery($processQuery)

	Return $processCollection

EndFunc   ;==>getProcessesByName

; --------------------------------------
Func dateFormate()

	Switch @WDAY
		Case 1
			$day = "Sonntag."

		Case 2
			$day = "Montag."

		Case 3
			$day = "Dienstag."

		Case 4
			$day = "Mittwoch."

		Case 5
			$day = "Donnerstag."

		Case 6
			$day = "Freitag."

		Case 7
			$day = "Samstag."

		Case Else
		; exception
	EndSwitch

		$timeStamp = $day  & @CRLF & @MDAY & "." & @MON & "." & @YEAR & " at: " & @HOUR & ":" & @MIN & ":" & @SEC

	Return $timeStamp
EndFunc

Func logWrite($msg)
	;FileChangeDir(@WorkingDir)
	FileChangeDir(@ScriptDir)
	$file = FileOpen("debug.log", 1)
	If $file = -1 Then
		;MsgBox(0, "Error", "Unable to open file")
		;Exit
	Else

		FileWrite($file, dateFormate() & @CRLF)
		FileWrite($file, "***" & $msg & @CRLF &  @CRLF)
		FileClose($file)

	EndIf

EndFunc

Func writeProcessArgsInFile($process)
	$file = FileOpen("debug.log", 1)

	If $file = -1 Then
		MsgBox(0, "Error", "Unable to open file")
		;Exit
	EndIf


	FileWrite($file, "Arguments: " & $process.Commandline & @CRLF)
	FileClose($file)

EndFunc   ;==>writeProcessArgsInFile

; -------------------------------------- GUI or sys tray


Func createTrayMenue()

	TrayTip("Crysis Observer", "Observer is running now", 5)
	opt("TrayAutoPause", 0)
	opt("TryMenuMode", 1)
	opt("TrayOnEventMode", 1)
	TraySetClick(16) ; right click


	Global $itemShowLog = TrayCreateItem("Show log", -1, 2)
	$itemSpace   = TrayCreateItem("", -1, 3)

	Global $itemSTELL 	  = TrayCreateItem("Steelmill", -1, 4)
	Global $itemMESA      = TrayCreateItem("Mesa", -1, 5)
	Global $itemPS 	      = TrayCreateItem("PS", -1, 6)

	$itemSpace2  		  = TrayCreateItem("", -1, 7)
	Global $itemautostart = TrayCreateItem("Autostart",-1,8)
	;$itemExit    		  = TrayCreateItem("Exit", -1, 9)
	$itemExit    		  = TrayCreateItem("", -1, 10)

	if(RegRead($autostartkey, "CrysisserverObserver")==@ScriptFullPath) Then
		TrayItemSetState($itemautostart, $TRAY_CHECKED)
		$autostart = True
	Else
		TrayItemSetState($itemautostart, $TRAY_UNCHECKED)
		$autostart = False
	EndIf

		TrayItemSetOnEvent($itemShowLog,"showLog")
		TrayItemSetOnEvent($itemautostart,"autostart")
		;TrayItemSetOnEvent($itemExit,"quit")
		TrayItemSetOnEvent($itemSTELL, "changeObserverValueSteelmill")
		TrayItemSetOnEvent($itemMESA, "changeObserverValueMesa")
		TrayItemSetOnEvent($itemPS, "changeObserverValuePS")


	TrayItemSetState($itemMESA, $TRAY_CHECKED)
	TrayItemSetState($itemSTELL, $TRAY_CHECKED)
	TrayItemSetState($itemPS, $TRAY_CHECKED)

EndFunc


Func changeObserverValueMesa()
	if($isMesaInChecklist == True) Then
		$isMesaInChecklist = False
		TrayItemSetState($itemMESA, $TRAY_UNCHECKED)
	Else
		$isMesaInChecklist = True
		TrayItemSetState($itemMESA, $TRAY_CHECKED)
	EndIf
EndFunc

Func changeObserverValuePS()
	if($isPSInChecklist == True) Then
		$isPSInChecklist = False
		TrayItemSetState($itemPS, $TRAY_UNCHECKED)
	Else
		$isPSInChecklist = True
		TrayItemSetState($itemPS, $TRAY_CHECKED)
	EndIf
EndFunc

Func changeObserverValueSteelmill()
	if($isSteelmillInChecklist == True) Then
		$isSteelmillInChecklist = False
		TrayItemSetState($itemSTELL, $TRAY_UNCHECKED)
	Else
		$isSteelmillInChecklist = True
		TrayItemSetState($itemSTELL, $TRAY_CHECKED)
	EndIf
EndFunc

Func autostart()
	if($autostart==False) Then
		RegWrite($autostartkey, "CrysisserverObserver", "REG_SZ", @ScriptFullPath)
		TrayItemSetState($itemautostart, 1)
		$autostart = True
	Else
		RegDelete($autostartkey,"CrysisserverObserver")
		TrayItemSetState($itemautostart, 4)
		$autostart = False
	EndIf
EndFunc

Func showLog()
	FileChangeDir(@ScriptDir)
	$file = FileOpen("debug.log", 1)

	$text = ""
	$line = ""
	;
	While $line <> -1
		$line = FileReadLine($file, 2)

		$err_sav = @error
		If $err_sav = -1 Then ExitLoop
		If $err_sav = 1 Then ExitLoop
		$line = String($line)
		$text = $text & $line & @CRLF
	WEnd
	MsgBox(0,"Logfile", $text )
	;
	;If $file = -1 Then
		;MsgBox(0, "Error", "Unable to open file")
		;Exit
	;Else
	;	$log = ""
	;	$last = FileRead($file )
	;	While $last <> -1
	;		$log += $last
	;	WEnd
	;	MsgBox(0,"Cry -log -file", $log )
	;	;MsgBox(0,"Cry -log -file", FileRead($file ) )
		;MsgBox(0,"Full path", @WorkingDir )
	;	FileClose($file)
	FileClose($file)
	TrayItemSetState($itemShowLog, $TRAY_UNCHECKED )
	;EndIf
EndFunc

Func quit()
	Exit
EndFunc

Func pushTrayMessage($msg )
	TrayTip("Crysis Observer", $msg , 4)
EndFunc

Func menueEvent($event)

	switch StringIsLower($event)
		case ""
			;
		case ""
			;
		case ""
			;
		case ""
			;
		Case ""
			;
	EndSwitch
EndFunc

