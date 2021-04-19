extends Node2D

# name is an int from 1 to max elem size


onready var Mask = $Mask
onready var container

var shape_selected = StyleBoxFlat.new() 
var shape_unselected = StyleBoxFlat.new() 

var r = 20
var is_selected = false


func _ready():
	init_mask()


func _draw():
	
	if is_in_universe():
		if is_selected == false:
			draw_style_box(shape_unselected, Rect2(-r, -r, 2*r, 2*r))
		else:
			draw_style_box(shape_selected, Rect2(-r, -r, 2*r, 2*r))
	else:
		draw_style_box(shape_unselected, Rect2(-r, -r, 2*r, 2*r))


func _gui_input(event):
	
	if container.is_editable():
		if event.is_pressed():
			
			if is_in_universe():
				if event.button_index == BUTTON_LEFT:
					container.Problem.block_close = true
					toggle_selected(!is_selected)
				elif event.button_index == BUTTON_RIGHT:
					toggle_selected(true)
					container.toggle_menu(true)
			elif event.button_index == BUTTON_RIGHT:
				container.elem_selected = get_id()
				container.toggle_menu(true)


func get_id() -> int:
	return int(name)


func init(container: Node, id: int) -> void:
	
	self.container = container
	set_id(id)
	
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
	update()


func init_mask():
	
	Mask.rect_position = Vector2(-r, -r)
	Mask.rect_size = Vector2(2*r, 2*r)


func is_in_universe():
	return container.name == "Universe"


func set_color(new_color: Color):
	
	if is_in_universe():
		shape_unselected.bg_color = new_color
		shape_selected.bg_color = new_color
	else:
		shape_unselected.border_color = new_color
	update()


func set_id(id: int) -> void:
	name = str(id)


func toggle_entered(is_entered: bool):
	self.is_entered = is_entered


func toggle_selected(is_selected: bool) -> void:
	
	if container.is_editable():
		self.is_selected = is_selected
		update()
