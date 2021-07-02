
Class constructor
	This:C1470.label:="🧹 'images'"
	
Function onInvoke($editor : Object)->$result : Object
	var $folder : Object
	$folder:=Folder:C1567(fk database folder:K87:14; *).folder("Project/Sources/Forms/").folder($editor.editor.name).folder("Images")
	If ($folder.exists)
		
		$files:=New collection:C1472
		For each ($objects; $editor.editor.form.pages.extract("objects"))
			For each ($objectName; $objects)
				$object:=$objects[$objectName]
				For each ($key; New collection:C1472("picture"; "icon"))  // others key ?
					If ($object[$key]#Null:C1517)
						If (Length:C16($object[$key])>0)
							$files.push(File:C1566($object[$key]).path)
						End if 
					End if 
				End for each 
			End for each 
		End for each 
		
		
		For each ($file; $folder.files())
			If ($files.indexOf($file.path)<0)
				$file.delete()
			End if 
			
		End for each 
		
		
	End if 