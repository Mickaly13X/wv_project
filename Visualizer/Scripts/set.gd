extends Node2D

const ELEMENT = preload("res://Scenes/Element.tscn")

var shape

onready var main = get_parent()

func _ready():
	
	shape = StyleBoxFlat.new()
	shape.bg_color = Color.transparent
	shape.set_border_width_all(3)
	shape.set_corner_radius_all(30)
	
	$ButtonGlobal.flat = true

func _draw():
	draw_style_box(shape, Rect2(Vector2(0, 0), $ButtonGlobal.rect_size))

func _pressed(button_name : String) -> void:
	
	match button_name:
		
		"Add": 
			
			var new_element = ELEMENT.instance()
			new_element.position = $Menu.position
			$Elements.add_child(new_element)
	
	$Menu.hide()

func _pressed_global() -> void:
	
	$Menu.position = get_local_mouse_position()
	$Menu.show()
