extends "res://Scripts/container.gd"


const ELEMENT_OFFSET = 24
const DOMAIN = preload("res://Scripts/classes.gd").Domain
const INTERVAL = preload("res://Scripts/classes.gd").Interval

onready var Buttons = $Menu/Buttons


func _gui_input(event):
	
	if is_editable():
		if event.is_pressed():
			Problem.lose_focus()


func _pressed(button_name : String) -> void:
	
	match button_name:
		
		"Constraint":
			Main.toggle_menu_pos_constraint(true)
	
	$Menu.hide()


func set_problem(problem) -> void:
	
	set_no_elements(problem.config.size)
	set_tag(problem.config.custom_name, problem.get_type().capitalize())


func add_elements(no_elements: int, origin: Vector2) -> void:
	
	var index = 1
	for point in Problem.calc_v_distri(origin, no_elements):
		var new_element = g.ELEMENT.instance()
		new_element.init(self, index)
		new_element.position = point
		$Elements.add_child(new_element)
		index += 1


func set_no_elements(no_elements: int) -> void:
	
	for I in get_elements(): I.free()
	
	if no_elements < 10:
		add_elements(no_elements, get_center())
	else:
		var no_elements_left = 9
		var no_elements_right = no_elements - no_elements_left
		add_elements(no_elements_left, get_center() + (g.ELEMENT_RADIUS * 1.5) * Vector2.LEFT)
		add_elements(no_elements_right, get_center() + (g.ELEMENT_RADIUS * 1.5) * Vector2.RIGHT)


func set_tag(custom_name: String, type: String) -> void:
	
	self.custom_name = custom_name
	if custom_name == "":
		$Label.text = "Config:"
	else:
		$Label.text = "Config (" + custom_name + "):"
	$Label.text += "\n" + type


func toggle_menu(is_visible : bool):
	
	$Menu.visible = is_visible
	if is_visible:
		$Menu.rect_position = get_local_mouse_position()
		toggle_menu_button("PosConstraint", true)


func toggle_menu_button(buttom_name: String, is_pressable : bool):
	Buttons.get_node(buttom_name).disabled = !is_pressable
