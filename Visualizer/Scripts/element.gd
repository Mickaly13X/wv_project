extends Node2D

# name is an int from 1 to max elem size




onready var Mask = $Mask
onready var Container_

var shape_selected = StyleBoxFlat.new() 
var shape_unselected = StyleBoxFlat.new() 

var r = 20
var is_selected = false


func _ready():
	init_mask()


func _process(_delta):
	update()


func _draw():
	
	if is_in_universe():
		if is_selected == false:
			draw_style_box(shape_unselected, Rect2(-r, -r, 2*r, 2*r))
		else:
			draw_style_box(shape_selected, Rect2(-r, -r, 2*r, 2*r))
	else:
		draw_style_box(shape_unselected, Rect2(-r, -r, 2*r, 2*r))


func _gui_input(event):
	
	if is_in_universe():
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				is_selected = !is_selected
			elif event.button_index == BUTTON_RIGHT:
				is_selected = true
				Container_.toggle_menu(true)


func get_id() -> int:
	return int(name)


func init(Container_ : Node2D) -> void:
	
	self.Container_ = Container_
	
	if is_in_universe(): # ball
		shape_unselected.set_corner_radius_all(r)
		shape_selected.set_border_width_all(4)
		shape_selected.set_corner_radius_all(r)
		shape_selected.border_color = Color(1, 1, 1)
	else: # box
		set_color(Color.white)
		shape_unselected.bg_color = Color.transparent
		shape_unselected.set_border_width_all(5)
		shape_unselected.border_width_top = 0


func init_mask():
	Mask.rect_position = Vector2(-r,-r)
	Mask.rect_size = Vector2(2*r,2*r)


func is_in_universe():
	return Container_.name == "Universe"


func set_color(new_color : Color):
	
	if is_in_universe():
		shape_unselected.bg_color = new_color
		shape_selected.bg_color = new_color
	else:
		shape_unselected.border_color = new_color


func set_id(id: int) -> void:
	name = str(id)
