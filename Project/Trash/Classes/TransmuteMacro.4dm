
Class constructor
	This:C1470.label:="Transmute object"
	This:C1470.objectTypes:=New collection:C1472(\
		"button"; \
		"text"; \
		"groupBox"; \
		"input"; \
		"-"; \
		"list"; \
		"listbox"; \
		"-"; \
		"combo"; \
		"dropdown"; \
		"-"; \
		"picturePopup"; \
		"button"; \
		"pictureButton"; \
		"buttonGrid"; \
		"-"; \
		"radio"; \
		"checkbox"; \
		"-"; \
		"progress"; \
		"ruler"; \
		"stepper"; \
		"spinner"; \
		"-"; \
		"rectangle"; \
		"line"; \
		"oval"; \
		"picture"; \
		"-"; \
		"splitter"; \
		"tab"; \
		"-"; \
		"write"; \
		"view")
	
Function onInvoke($editor : Object)->$result : Object
	var $type : Text
	var $currentSelection; $editor; $menu; $result : Object
	
	$currentSelection:=This:C1470.currentSelection($editor)
	
	If ($currentSelection#Null:C1517)
		
		$menu:=cs:C1710.menu.new()
		
		For each ($type; This:C1470.objectTypes)
			Case of 
				: ($type="-")
					$menu.line()
				Else 
					If (String:C10($currentSelection.type)=$type)
						$menu.append(Uppercase:C13(Substring:C12($type; 1; 1))+Delete string:C232($type; 1; 1); $type).disable()
					Else 
						$menu.append(Uppercase:C13(Substring:C12($type; 1; 1))+Delete string:C232($type; 1; 1); $type)
					End if 
			End case 
		End for each 
		$menu.popup()
		
		If ($menu.selected)
			
			$currentSelection.type:=$menu.choice
			
			
			$result:=New object:C1471("currentPage"; $editor.editor.currentPage)
			
		End if 
		
		// else no selection
	End if 
	
Function currentSelection($editor)->$selection : Object
	If ($editor.editor.currentSelection#Null:C1517)
		If ($editor.editor.currentSelection.length#0)
			$selection:=$editor.editor.currentPage.objects[$editor.editor.currentSelection[0]]
		End if 
	End if 