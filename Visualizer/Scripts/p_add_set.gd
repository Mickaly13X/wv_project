extends Panel

const Exception = preload("res://util/ExceptionIDs.gd")

#returns if user input is valid
func return_input_validity():
	if $L_Name/LE_Name.text == "":
		return Exception.NoName
	if $L_Size/MB_Size.text == "--":
		return Exception.NoSize
	return 0

#clear user input
func clear_user_input():
	$L_Name/LE_Name.text = ""
	$L_Size/MB_Size.text = "--"
	
