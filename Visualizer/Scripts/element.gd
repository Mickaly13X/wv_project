extends Node2D

# name is an int from 1 to max elem size

const BORDER_WIDTH = 5
const R = 20

onready var Mask = $Mask
onready var container

var shape = StyleBoxFlat.new() 
var is_selected = false


func _ready():
	init_mask()


func _draw():
	draw_style_box(shape, Rect2(-R, -R, 2*R, 2*R))


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
				container.deselect_elements()
				toggle_selected(true)
				container.toggle_menu(true)


func get_id() -> int:
	return int(name)


func init(container: Node, id: int) -> void:
	
	self.container = container
	set_id(id)
	
	if is_in_universe(): # ball
		shape.set_corner_radius_all(R)
	else: # box
		set_color(Color.white)
		shape.bg_color = Color.transparent
		shape.set_border_width_all(BORDER_WIDTH)
		shape.border_width_top = 0
		
	toggle_selected(false)
	update()


func init_mask():
	
	Mask.rect_position = Vector2(-R, -R)
	Mask.rect_size = Vector2(2*R, 2*R)


func is_in_universe():
	return container.name == "Universe"


func set_color(new_color: Color):
	
	if is_in_universe():
		shape.bg_color = new_color
	if new_color != Color.white:
		shape.border_color = Color.white
	else:
		shape.border_color = Color.blue
	update()


func set_id(id: int) -> void:
	name = str(id)


func toggle_selected(is_selected: bool) -> void:
	
	if container.is_editable():
		self.is_selected = is_selected
		if is_in_universe():
			shape.set_border_width_all(BORDER_WIDTH * int(is_selected))
		else:
			set_color(Color.white * int(is_selected))
		update()
