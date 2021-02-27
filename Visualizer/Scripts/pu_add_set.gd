extends Popup

const Exception = preload("res://util/ExceptionIDs.gd")

onready var NAME_INPUT = $VBox/Items/NameInput
onready var MB_SIZE = $VBox/Items/MbSize

var ref_universe : String

#clear user input
func clear_user_input():
	NAME_INPUT.text = ""
	MB_SIZE.text = "- -"

#returns if user input is valid
func get_input_validity():
	
	if NAME_INPUT.text == "":
		return Exception.NoName
	if MB_SIZE.text == "- -":
		return Exception.NoSize
	return 0

func get_name():
	return NAME_INPUT.text

func get_size():
	return int(MB_SIZE.text)

func _pressed_add():
	
	match get_input_validity():
		
		0:
			var new_set_name = get_name()
			var new_set_size = get_size()
			get_parent().get_parent().add_universe(ref_universe, new_set_name, new_set_size)
			#get_parent().add_set(new_set_name, new_set_size, new_set_distinguishable)
			#TODO Check for Advanced settings
			
			clear_user_input()
			
			self.hide()
		
		Exception.NoName:
			$Popup/PopupLabel.text = "Please specify a name"
			$Popup.popup()
		
		Exception.NoSize:
			$Popup/PopupLabel.text = "Please choose a size"
			$Popup.popup()

func _pressed_cancel():
	clear_user_input()
	self.hide()
