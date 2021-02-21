extends Node2D

var shape = StyleBoxFlat.new() 

func _ready():
	
	shape.set_corner_radius_all(16)
	shape.bg_color = Color.red

func _draw():
	draw_style_box(shape, Rect2(0, 0, 32, 32))
