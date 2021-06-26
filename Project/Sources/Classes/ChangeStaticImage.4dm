

Class constructor
	This:C1470.label:="Select static image"
	This:C1470.images:=New collection:C1472(".jpg"; ".jpeg"; ".gif"; ".png"; ".svg"; ".tiff")
	
Function onInvoke($editor : Object)->$result : Object
	var $Doc; $DocType : Text
	var $i; $Options : Integer
	var $currentSelection; $folder; $menu; $subfolder : Object
	var $file : 4D:C1709.File
	
	$currentSelection:=This:C1470.currentSelection($editor)
	
	If ($currentSelection=Null:C1517)
		
		$currentSelection:=New object:C1471("type"; "picture"; \
			"class"; ""; \
			"width"; 400; \
			"height"; 300; \
			"top"; 0; \
			"left"; 0)
		
		$i:=0
		While ($editor.editor.currentPage.objects["Picture"+String:C10($i)]#Null:C1517)
			$i:=$i+1
		End while 
		
		$editor.editor.currentPage.objects["Picture"+String:C10($i)]:=$currentSelection
		
		$editor.editor.currentSelection.clear()  //unselect elements
		$editor.editor.currentSelection.push("Picture"+String:C10($i))
		
	End if 
	
	If ($currentSelection.type="picture")
		
		$menu:=cs:C1710.menu.new()
		$folder:=Folder:C1567(fk database folder:K87:14).folder("Project/Sources/Forms/").folder($editor.editor.name).folder("Images")
		If ($folder.exists)
			For each ($file; $folder.files())
				If (Length:C16($file.name)>0)
					$menu.append($file.fullName; $file.path)
				End if 
			End for each 
			$menu.line()
			$menu.append("Copy from disk..."; "#copyFromDisk")
			$menu.append("Select from /RESOURCES"; "#selectFromResources")
			
			$unsplashmenu:=cs:C1710.menu.new()
			$unsplashmenu.append("Get random image"; "#selectRandomImage")
			$unsplashmenu.append("Search an image"; "#searchRandomImage")
			
			$menu.append("Unsplash"; $unsplashmenu)
			
		End if 
		
		$menu.popup()
		
		If ($menu.selected)
			
			Case of 
				: ($menu.choice="#copyFromDisk")
					
					If (Is Windows:C1573)
						$DocType:=This:C1470.images.join(",")
					Else 
						$DocType:="public.image"
					End if 
					$Options:=Alias selection:K24:10+Package open:K24:8+Use sheet window:K24:11
					$Doc:=Select document:C905(""; $DocType; "Select the data file"; $Options)
					If (OK=1)
						If ($folder.file(File:C1566(Document; fk platform path:K87:2).fullName).exists)
							$currentSelection.picture:=File:C1566(Document; fk platform path:K87:2).copyTo($folder; File:C1566(Document; fk platform path:K87:2).fullName+Generate UUID:C1066).path
						Else 
							$currentSelection.picture:=File:C1566(Document; fk platform path:K87:2).copyTo($folder).path
						End if 
					End if 
					
				: ($menu.choice="#selectFromResources")
					
					This:C1470.menuResources(Folder:C1567(fk resources folder:K87:11; *); $currentSelection)
					
				: (($menu.choice="#selectRandomImage") | ($menu.choice="#searchRandomImage"))
					var $body; $blob : Blob
					
					var $url; $terms : Text
					$url:="https://source.unsplash.com/"
					
					$url:=$url+String:C10($currentSelection.width)+"x"+String:C10($currentSelection.height)
					
					If ($menu.choice="#searchRandomImage")
						$terms:=Request:C163("Search words?")
						If (OK=1)
							$url:=$url+"?"+Replace string:C233($terms; " "; "&")
						Else 
							$url:=""  // cancel
						End if 
					End if 
					
					If (Length:C16($url)>0)
						ARRAY TEXT:C222($headerNames; 0)
						ARRAY TEXT:C222($headerValues; 0)
						$status:=HTTP Request:C1158(HTTP GET method:K71:1; $url; $body; $blob; $headerNames; $headerValues)
						
						If ($status=200)
							var $filename : Text
							var $pos : Integer
							$pos:=Find in array:C230($headerNames; "X-Imgix-ID")
							If ($pos>0)
								$filename:=$headerValues{$pos}
							Else 
								$filename:=Generate UUID:C1066
							End if 
							$pos:=Find in array:C230($headerNames; "Content-type")
							If ($pos>0)
								$filename:=$filename+"."+Replace string:C233($headerValues{$pos}; "image/"; "")
							Else 
								$filename:=$filename+".png"
							End if 
							$file:=$folder.file($filename)
							$file.setContent($blob)
							
							$currentSelection.picture:=$file.path
						Else 
							ALERT:C41("unable to download random image")
						End if 
					End if 
					
				Else 
					
					$currentSelection.picture:=$menu.choice
					
			End case 
			
			$result:=New object:C1471("currentSelection"; $editor.editor.currentSelection; \
				"currentPage"; $editor.editor.currentPage)
			
		End if 
		
	Else 
		
		ALERT:C41("must select nothing or a picture object")
		
	End if 
	
Function menuResources($folder : 4D:C1709.Folder; $currentSelection : Object)
	var $menu : Object
	$menu:=cs:C1710.menu.new()
	var $file : 4D:C1709.File
	For each ($file; $folder.files())
		If (This:C1470.images.indexOf($file.extension)>-1)
			$menu.append($file.fullName; $file.path)
		End if 
	End for each 
	
	var $subfolder : 4D:C1709.Folder
	For each ($subfolder; $folder.folders())
		$menu.append($subfolder.fullName+"/"; $subfolder.path)
	End for each 
	
	$menu.popup()
	
	If ($menu.selected)
		
		If (Delete string:C232($menu.choice; 1; Length:C16($menu.choice)-1)="/")
			This:C1470.menuResources(Folder:C1567($menu.choice); $currentSelection)
		Else 
			$currentSelection.picture:=$menu.choice
		End if 
	End if 
	
Function currentSelection($editor)->$selection : Object
	If ($editor.editor.currentSelection#Null:C1517)
		If ($editor.editor.currentSelection.length#0)
			$selection:=$editor.editor.currentPage.objects[$editor.editor.currentSelection[0]]
		End if 
	End if 