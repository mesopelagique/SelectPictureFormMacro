
Class constructor
	This:C1470.label:="New 🔲 from bounds"
	
Function onInvoke($editor : Object)->$result : Object
	var $currentSelection; $rectangle : Object
	var $i : Integer
	$currentSelection:=This:C1470.currentSelection($editor)
	
	If ($currentSelection#Null:C1517)
		
		$rectangle:=New object:C1471("type"; "rectangle"; \
			"class"; ""; \
			"fill"; "transparent"; \
			"width"; $currentSelection.width; \
			"height"; $currentSelection.height; \
			"top"; $currentSelection.top; \
			"left"; $currentSelection.left)
		
		$i:=0
		While ($editor.editor.currentPage.objects["Rectangle"+String:C10($i)]#Null:C1517)
			$i:=$i+1
		End while 
		$editor.editor.currentPage.objects["Rectangle"+String:C10($i)]:=$rectangle
		
		$editor.editor.currentSelection:=New collection:C1472("Rectangle"+String:C10($i))
		
		$result:=New object:C1471("currentSelection"; $editor.editor.currentSelection; \
			"currentPage"; $editor.editor.currentPage)
		
	Else 
		
		ALERT:C41("must select an object")
		
	End if 
	
Function currentSelection($editor)->$selection : Object
	If ($editor.editor.currentSelection#Null:C1517)
		If ($editor.editor.currentSelection.length#0)
			$selection:=$editor.editor.currentPage.objects[$editor.editor.currentSelection[0]]
		End if 
	End if 