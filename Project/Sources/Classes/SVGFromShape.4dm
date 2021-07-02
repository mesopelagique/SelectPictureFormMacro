
Class constructor
	This:C1470.label:="New SVG from shapes"
	This:C1470.shapeTypes:=New collection:C1472("rectangle"; "line"; "oval"; "picture")
	
Function onInvoke($editor : Object)->$result : Object
	var $currentSelections; $coordinates; $folder; $picture : Object
	var $SVG; $svgContent; $name : Text
	
	$currentSelections:=This:C1470.currentSelections($editor)
	
	If (OB Is empty:C1297($currentSelections))
		
		ALERT:C41("you must select shapes object")
		
	Else 
		
		$coordinates:=This:C1470.enclosingRec($currentSelections)
		
		
		$folder:=Folder:C1567(fk database folder:K87:14; *).folder("Project/Sources/Forms/").folder($editor.editor.name).folder("Images")
		If (Not:C34($folder.exists))
			$folder.create()
		End if 
		
		$name:=Generate UUID:C1066
		
		$SVG:=SVG_New
		For each ($objectName; $currentSelections)
			This:C1470.objectToSVG($SVG; $currentSelections[$objectName]; $objectName; $coordinates)
		End for each 
		
		$file:=$folder.file($name+".svg")
		
		$svgContent:=SVG_Export_to_XML($SVG)
		$file.setText($svgContent)
		
		$picture:=New object:C1471("type"; "picture"; \
			"class"; ""; \
			"picture"; $file.path; \
			"width"; $coordinates.right-$coordinates.left; \
			"height"; $coordinates.bottom-$coordinates.top; \
			"top"; $coordinates.top; \
			"left"; $coordinates.left)
		
		$i:=0
		While ($editor.editor.currentPage.objects["Picture"+String:C10($i)]#Null:C1517)
			$i:=$i+1
		End while 
		$editor.editor.currentPage.objects["Picture"+String:C10($i)]:=$picture
		
		$editor.editor.currentSelection:=New collection:C1472("Picture"+String:C10($i))
		
		$result:=New object:C1471("currentSelection"; $editor.editor.currentSelection; \
			"currentPage"; $editor.editor.currentPage)
		
	End if 
	
Function objectToSVG($objetSVGParent : Variant; $object : Object; $objectName : Text; $coordinates : Object)
	Case of 
		: ($object.type="line")
			
			// startX ; startY ; endX ; endY {; color {; strokeWidth}} ) 
			Case of 
				: (String:C10($object.startPoint)="bottomLeft")
					
					SVG_New_line($objetSVGParent; \
						$object.left-$coordinates.left; \
						$object.top-$coordinates.top+$object.height; \
						$object.left-$coordinates.left+$object.width; \
						$object.top-$coordinates.top; \
						Choose:C955($object.stroke=Null:C1517; "#000000"; $object.stroke); \
						Choose:C955($object.strokeWidth=Null:C1517; 1; $object.strokeWidth))
					
				Else 
					
					SVG_New_line($objetSVGParent; \
						$object.left-$coordinates.left; \
						$object.top-$coordinates.top; \
						$object.left-$coordinates.left+$object.width; \
						$object.top-$coordinates.top+$object.height; \
						Choose:C955($object.stroke=Null:C1517; "#000000"; $object.stroke); \
						Choose:C955($object.strokeWidth=Null:C1517; 1; $object.strokeWidth))
					
			End case 
			
		: ($object.type="rectangle")
			
			$strokeWidth:=Choose:C955($object.strokeWidth=Null:C1517; 1; $object.strokeWidth)
			
			// x ; y ; width ; height {; roundedX {; roundedY {; foregroundColor {; backgroundColor {; strokeWidth}}}}} )
			$rec:=SVG_New_rect($objetSVGParent; \
				$object.left-$coordinates.left+($strokeWidth/2); \
				$object.top-$coordinates.top+($strokeWidth/2); \
				$object.width-($strokeWidth); \
				$object.height-($strokeWidth); \
				Choose:C955($object.borderRadius=Null:C1517; 0; $object.borderRadius); \
				Choose:C955($object.borderRadius=Null:C1517; 0; $object.borderRadius); \
				Choose:C955($object.stroke=Null:C1517; "#000000"; $object.stroke); \
				Choose:C955($object.fill=Null:C1517; "#FFFFFF"; $object.fill); \
				$strokeWidth)
			
			If (String:C10($object.fill)="transparent")
				DOM SET XML ATTRIBUTE:C866($rec; "fill-opacity"; 0)
			End if 
			
			SVG_SET_ID($rec; $objectName)
/*SVG_Define_shadow($rec; $objectName+"Shadow"; 4; 4; 4)
SVG_SET_FILTER($rec; $objectName+"Shadow")  // just some test to make a macro to add shadow*/
			
		: ($object.type="oval")
			
			If (String:C10($object.fill)="automatic")
				$object:=OB Copy:C1225($object)
				$object.fill:="white"  // or find a way with css style for dark mode
			End if 
			
			$strokeWidth:=Choose:C955($object.strokeWidth=Null:C1517; 1; $object.strokeWidth)
			
			// x ; y ; xRadius ; yRadius {; foregroundColor {; backgroundColor {; strokeWidth}}}
			$rec:=SVG_New_ellipse($objetSVGParent; \
				$object.left-$coordinates.left+($object.width/2); \
				$object.top-$coordinates.top+($object.height/2); \
				$object.width/2-($strokeWidth/2); \
				$object.height/2-($strokeWidth/2); \
				Choose:C955($object.stroke=Null:C1517; "#000000"; $object.stroke); \
				Choose:C955($object.fill=Null:C1517; "#000000"; $object.fill); \
				$strokeWidth)
			
			// or use SVG_New_ellipse_bounded if necessary (but seems do not consider strokewidth to center)
			//		$rec:=SVG_New_ellipse_bounded($objetSVGParent; \
																																				$object.left-$coordinates.left+($strokeWidth/2); \
																																				$object.top-$coordinates.top+($strokeWidth/2); \
																																				$object.width-($strokeWidth*2); \
																																				$object.height-($strokeWidth*2); \
																																				Choose($object.stroke=Null; "#000000"; $object.stroke); \
																																				Choose($object.fill=Null; "#000000"; $object.fill); \
																																				$strokeWidth)*/
			
			
			If (String:C10($object.fill)="transparent")
				DOM SET XML ATTRIBUTE:C866($rec; "fill-opacity"; 0)
			End if 
			
			
		: ($object.type="picture")
			
			var $pictureFile : Object
			$pictureFile:=File:C1566($object.picture)
			If ($pictureFile.exists)
				var $pictureBlob : Blob
				var $picture : Picture
				$pictureBlob:=$pictureFile.getContent()
				BLOB TO PICTURE:C682($pictureBlob; $picture)
				
				SVG_New_embedded_image($objetSVGParent; $picture; \
					$object.left-$coordinates.left; \
					$object.top-$coordinates.top)
				
				// XXX maybe force image size, or manage pictureFormat 
				
			End if 
			
		Else 
			ASSERT:C1129(False:C215; "Unknown object "+String:C10($object.type))
	End case 
	
Function enclosingRec($objects : Object)->$coordinates : Object
	var $o; $element : Object
	For each ($name; $objects)
		
		$element:=$objects[$name]
		
		$o:=New object:C1471(\
			"left"; $element.left; \
			"top"; $element.top; \
			"right"; $element.left+$element.width; \
			"bottom"; $element.top+$element.height)
		
		If ($coordinates=Null:C1517)
			
			$coordinates:=$o
			
		Else 
			
			$coordinates.left:=Choose:C955($o.left<$coordinates.left; $o.left; $coordinates.left)
			$coordinates.top:=Choose:C955($o.top<$coordinates.top; $o.top; $coordinates.top)
			$coordinates.right:=Choose:C955($o.right>$coordinates.right; $o.right; $coordinates.right)
			$coordinates.bottom:=Choose:C955($o.bottom>$coordinates.bottom; $o.bottom; $coordinates.bottom)
			
		End if 
	End for each 
	
Function currentSelections($editor)->$selections : Object
	var $object : Object
	$selections:=New object:C1471
	If ($editor.editor.currentSelection#Null:C1517)
		For each ($name; $editor.editor.currentSelection)
			$object:=$editor.editor.currentPage.objects[$name]
			If ($object#Null:C1517)
				If (This:C1470.shapeTypes.indexOf($object.type)#-1)
					$selections[$name]:=$object
				End if 
			End if 
		End for each 
	End if 