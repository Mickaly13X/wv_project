extends Popup

const Exception = preload("res://util/ExceptionIDs.gd")

onready var NAME_INPUT = $Items/NameInput
onready var MB_SIZE = $Items/MbSize

var ref_universe : String

#returns if user input is valid
func return_input_validity():
	
	if NAME_INPUT.text == "":
		return Exception.NoName
	if MB_SIZE.text == "- -":
		return Exception.NoSize
	return 0

#clear user input
func clear_user_input():
	NAME_INPUT.text = ""
	MB_SIZE.text = "- -"

func get_name():
	return NAME_INPUT.text

func get_size():
	return int(MB_SIZE.text)
	

func _on_B_Add_button_up():
	
	var return_value = return_input_validity()
	
	if return_value == 0:
		
		var new_set_name = get_name()
		var new_set_size = get_size()
		get_parent().get_parent().add_universe(ref_universe, new_set_name, new_set_size)
		#get_parent().add_set(new_set_name, new_set_size, new_set_distinguishable)
		#TODO Check for Advanced settings
		
		clear_user_input()
		
		self.hide()
		
	elif return_value == Exception.NoName:
		$Popup/PopupLabel.text = "Please specify a name"
		$Popup.popup()
		
	elif return_value == Exception.NoSize:
		$Popup/PopupLabel.text = "Please choose a size"
		$Popup.popup()


func _on_B_Cancel_button_up():
	clear_user_input()
	self.hide()
