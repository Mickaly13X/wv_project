extends Node2D


const ELEMENT = preload("res://Scenes/Element.tscn")
const ELEMENT_OFFSET = 24
const ELEMENT_SIZE = 16
const Domain = preload("res://Scripts/classes.gd").Domain
const Interval = preload("res://Scripts/classes.gd").Interval

onready var Main : Node

var custom_name
var shape


func _ready():
	
	shape = StyleBoxFlat.new()
	shape.bg_color = Color.transparent
	shape.set_border_width_all(3)
	shape.set_corner_radius_all(30)
	
	set_name("")


func _draw():
	draw_style_box(shape, Rect2(Vector2(0, 0), $Mask.rect_size))


func get_center(offset = Vector2.ZERO) -> Vector2:
	return $Mask.rect_position + $Mask.rect_size / 2 + offset


func get_elements() -> Array:
	return $Elements.get_children()


func get_name() -> String:
	return custom_name


func get_size() -> int:
	return len(get_elements())


func has_max_elements() -> bool:
	
	if get_size() == 10:
		return true
	return false




func init(size : int, custom_name = get_name()) -> void:
	
	set_name(custom_name)
	set_size(size)


func set_name(custom_name : String) -> void:
	
	self.custom_name = custom_name
	if custom_name == "":
		$Label.text = "Config"
	else:
		$Label.text = "Config (" + custom_name + ")"


func set_size(size : int) -> void:
	
	for I in get_elements():
		I.free()
	var total_length = (size - 1) * (2*ELEMENT_SIZE + ELEMENT_OFFSET)
	var starting_point = get_center() + (total_length / 2.0) * Vector2.UP
	for i in range(size):
		var new_element = ELEMENT.instance()
		new_element.init("var", Color.white)
		new_element.position = \
			starting_point + (2*ELEMENT_SIZE + ELEMENT_OFFSET) * i * Vector2.DOWN
		$Elements.add_child(new_element)
