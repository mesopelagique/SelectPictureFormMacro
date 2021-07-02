
Class constructor
	This:C1470.label:="Reveal image on disk"
	
Function onInvoke($editor : Object)->$result : Object
	var $currentSelection : Object
	
	$currentSelection:=This:C1470.currentSelection($editor)
	
	Case of 
		: ($currentSelection=Null:C1517)
			ALERT:C41("must a picture object")
		: (String:C10($currentSelection.type)#"picture")
			ALERT:C41("must a picture object")
		Else 
			
			var $file : Object
			$file:=File:C1566($currentSelection.picture)
			If ($file.exists)
				SHOW ON DISK:C922($file.platformPath)
			End if 
			
	End case 
	
	
	
Function currentSelection($editor)->$selection : Object
	If ($editor.editor.currentSelection#Null:C1517)
		If ($editor.editor.currentSelection.length#0)
			$selection:=$editor.editor.currentPage.objects[$editor.editor.currentSelection[0]]
		End if 
	End if 