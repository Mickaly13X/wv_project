extends Node2D

onready var MASK = $Mask

var uni_name : String
var shape_selected = StyleBoxFlat.new() 
var shape_unselected = StyleBoxFlat.new() 

var r = 16
var selected = false

func _ready():
	
	init_mask()
	if uni_name == "N": # ball
		#shape_unselected.bg_color = Color(0.335114, 0.295376, 0.613281)
		shape_unselected.set_corner_radius_all(r)
		
		#shape_selected.bg_color = Color(0.335114, 0.295376, 0.613281)
		shape_selected.set_border_width_all(2)
		shape_selected.set_corner_radius_all(r)
		shape_selected.border_color = Color(1, 1, 1)
	else: # box
		shape_unselected.bg_color = Color.transparent
		
		shape_unselected.set_border_width_all(5)
		shape_unselected.border_width_top = 0


func _process(delta):
	update()


func _draw():
	
	if uni_name == "N":
		if selected == false:
			draw_style_box(shape_unselected, Rect2(-r, -r, 2*r, 2*r))
		else:
			draw_style_box(shape_selected, Rect2(-r, -r, 2*r, 2*r))
	else:
		draw_style_box(shape_unselected, Rect2(-r, -r, 2*r, 2*r))


func init_mask():
	MASK.rect_position = Vector2(-r,-r)
	MASK.rect_size = Vector2(2*r,2*r)


func on_gui_input(event):
	
	if (event.is_pressed() and event.button_index == BUTTON_LEFT):
		selected = !selected
	if (event.is_pressed() and event.button_index == BUTTON_RIGHT):
		self.get_parent().get_parent().show_menu()
		selected = true

func set_color(new_color : Color):
	
	if uni_name == "N":
		shape_unselected.bg_color = new_color
		shape_selected.bg_color = new_color
	else:
		shape_unselected.border_color = new_color
