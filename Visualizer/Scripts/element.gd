extends Node2D

onready var MASK = $Mask

var container : String
var shape_selected = StyleBoxFlat.new() 
var shape_unselected = StyleBoxFlat.new() 

var r = 20
var selected = false


func _ready():
	init_mask()


func _process(_delta):
	update()


func _draw():
	
	if container == "uni":
		if selected == false:
			draw_style_box(shape_unselected, Rect2(-r, -r, 2*r, 2*r))
		else:
			draw_style_box(shape_selected, Rect2(-r, -r, 2*r, 2*r))
	else:
		draw_style_box(shape_unselected, Rect2(-r, -r, 2*r, 2*r))


func _gui_input(event):
	
	if container == "uni":
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				selected = !selected
			elif event.button_index == BUTTON_RIGHT:
				selected = true
				get_parent().get_parent().toggle_menu(true)
				get_parent().get_parent().toggle_add_button(false)
				get_parent().get_parent().toggle_group_button(true)


func get_id() -> int:
	return int(name)


func init(container : String) -> void:
	
	self.container = container
	
	if container == "uni": # ball
		shape_unselected.set_corner_radius_all(r)
		shape_selected.set_border_width_all(4)
		shape_selected.set_corner_radius_all(r)
		shape_selected.border_color = Color(1, 1, 1)
	else: # box
		shape_unselected.bg_color = Color.transparent
		shape_unselected.set_border_width_all(5)
		shape_unselected.border_width_top = 0


func init_mask():
	MASK.rect_position = Vector2(-r,-r)
	MASK.rect_size = Vector2(2*r,2*r)


func set_color(new_color : Color):
	
	if container == "uni":
		shape_unselected.bg_color = new_color
		shape_selected.bg_color = new_color
	else:
		shape_unselected.border_color = new_color


func set_id(id: int) -> void:
	name = str(id)
