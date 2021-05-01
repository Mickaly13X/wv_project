extends Node2D

# name is an int from 1 to max elem size

const BORDER_WIDTH = 5
const R = 20

enum Type {BALL, BOX}

onready var Mask = $Mask
onready var container

var shape = StyleBoxFlat.new() 
var is_selected = false
var type: int


func _ready():
	init_mask()


func _draw():
	draw_style_box(shape, Rect2(-R, -R, 2*R, 2*R))


func _gui_input(event):
	
	if has_container():
		if container.is_editable():
			if event.is_pressed():
				
				container.Problem.lose_focus(container.name)
				if type == Type.BALL:
					if event.button_index == BUTTON_LEFT:
						toggle_selected(!is_selected)
					elif event.button_index == BUTTON_RIGHT:
						toggle_selected(true)
						container.toggle_menu(true)
				elif type == Type.BOX:
					if event.button_index == BUTTON_RIGHT:
						container.deselect_elements()
						toggle_selected(true)
						container.toggle_menu(true)


func get_id() -> int:
	return int(name)


func has_container() -> bool:
	return !g.is_null(container)


func init(container: Node = null, id = -1, type = -1) -> void:
	
	self.container = container
	if has_container():
		if container.name == "Config":
			set_type(Type.BOX)
		else:
			set_type(Type.BALL)
	else:
		set_type(type)
	
	set_id(id)
	toggle_selected(false)
	update()


func init_mask():
	
	Mask.rect_position = Vector2(-R, -R)
	Mask.rect_size = Vector2(2*R, 2*R)


func set_color(new_color: Color):
	
	if type == Type.BALL:
		shape.bg_color = new_color
	if new_color != Color.white:
		shape.border_color = Color.white
	else:
		shape.border_color = Color.blue
	update()


func set_id(id: int) -> void:
	name = str(id)


func set_type(type: int) -> void:
	
	self.type = type
	if type == Type.BALL:
		shape.set_corner_radius_all(R)
	elif type == Type.BOX:
		set_color(Color.blue)
		shape.bg_color = Color.transparent
		shape.set_border_width_all(BORDER_WIDTH)
		shape.border_width_top = 0


func toggle_selected(is_selected: bool) -> void:
	
	if has_container():
		if container.is_editable():
			self.is_selected = is_selected
			if type == Type.BALL:
				shape.set_border_width_all(BORDER_WIDTH * int(is_selected))
			elif type == Type.BOX:
				set_color(Color.white * int(is_selected))
			update()
