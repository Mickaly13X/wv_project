extends Popup

const Exception = preload("res://util/ExceptionIDs.gd")

#returns if user input is valid
func return_input_validity():
	
	if $LE_Name.text == "":
		return Exception.NoName
	if $MB_Size.text == "--":
		return Exception.NoSize
	return 0

#clear user input
func clear_user_input():
	
	$LE_Name.text = ""
	$MB_Size.text = "--"
	

func get_name():
	
	return $LE_Name.text


func get_size():
	
	return int($MB_Size.text)


func get_distinguishability():
	
	return $CB_Distinguishable.pressed
	

func _on_B_Add_button_up():
	var return_value = return_input_validity()
	
	if return_value == 0:
		
		var new_set_name = get_name()
		var new_set_size = get_size()
		var new_set_distinguishable = get_distinguishability()
		
		get_parent().add_set(new_set_name, new_set_size, new_set_distinguishable)
		#TODO Check for Advanced settings
		
		clear_user_input()
		
		self.hide()
		
	elif return_value == Exception.NoName:
		$Popup/L_Popup.text = "Please specify a name"
		$Popup.popup()
		
	elif return_value == Exception.NoSize:
		$Popup/L_Popup.text = "Please choose a size"
		$Popup.popup()



func _on_B_AdvancedSettings_button_up():
	
	$PU_AdvancedSettings.popup()
