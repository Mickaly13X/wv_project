extends Node2D

var shape = StyleBoxFlat.new() 

func _ready():
	
	shape.set_corner_radius_all(16)
	shape.bg_color = Color(0.335114, 0.295376, 0.613281)

func _draw():
	draw_style_box(shape, Rect2(0, 0, 32, 32))
