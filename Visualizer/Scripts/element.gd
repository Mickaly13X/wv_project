extends Node2D

onready var set = get_parent().get_parent()

var shape = StyleBoxFlat.new() 


func _ready():
	
	if set.name == "N": # ball
		#shape.bg_color = Color(0.335114, 0.295376, 0.613281)
		shape.set_corner_radius_all(16)
	else: # box
		shape.bg_color = Color.transparent
		
		shape.set_border_width_all(5)
		shape.border_width_top = 0


func _draw():
	
	draw_style_box(shape, Rect2(-16, -16, 32, 32))
