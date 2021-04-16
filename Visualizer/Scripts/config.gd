extends "res://Scripts/container.gd"


const ELEMENT = preload("res://Scenes/Element.tscn")
const ELEMENT_OFFSET = 24
const Domain = preload("res://Scripts/classes.gd").Domain
const Interval = preload("res://Scripts/classes.gd").Interval

onready var Buttons = $Menu/Buttons

var index_selected: int


func _ready():
	
	shape = StyleBoxFlat.new()
	shape.bg_color = Color.transparent
	shape.set_border_width_all(3)
	shape.set_corner_radius_all(30)
	
	set_size(0)


func _draw():
	
	draw_self()


func _gui_input(event):
	
	if event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			toggle_menu(false)
			#deselect_elements()
		elif event.button_index == BUTTON_RIGHT:
			#var has_selected_elements = has_selected_elements()
			#toggle_group_button(has_selected_elements)
			#toggle_add_button(!(has_max_elements() || has_selected_elements))
			toggle_menu(false)


func _pressed(button_name : String) -> void:
	
	match button_name:
		
		"Constraint": 
			Main.toggle_menu_pos_constraint(true)
	
	$Menu.hide()


func get_element(index: int) -> Node2D:
	
	for I in get_elements():
		if I.index == index:
			return I
	return null


func has_max_elements() -> bool:
	
	if get_size() == 10:
		return true
	return false


func set_problem(problem) -> void:
	
	set_tag(problem.config.custom_name, problem.get_type().capitalize())
	set_size(problem.config.size)


func set_size(size : int) -> void:
	
	for I in get_elements():
		I.free()
	var total_length = (size - 1) * (2*ELEMENT_SIZE + ELEMENT_OFFSET)
	var starting_point = get_center() + (total_length / 2.0) * Vector2.UP
	for i in range(size):
		var new_element = ELEMENT.instance()
		new_element.index = i + 1
		new_element.init(self)
		new_element.position = \
			starting_point + (2*ELEMENT_SIZE + ELEMENT_OFFSET) * i * Vector2.DOWN
		$Elements.add_child(new_element)


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
		Problem.close_menus(name)
		$Menu.position = get_local_mouse_position()
		toggle_menu_button("PosConstraint", true)


func toggle_menu_button(buttom_name: String, is_pressable : bool):
	Buttons.get_node(buttom_name).disabled = !is_pressable
