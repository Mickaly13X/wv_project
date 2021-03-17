extends Node2D


var custom_name: String
var shape: StyleBoxFlat


func get_center(offset = Vector2.ZERO) -> Vector2:
	return $Mask.rect_position + $Mask.rect_size / 2 + offset


func get_elements() -> Array:
	return $Elements.get_children()


func get_name() -> String:
	return custom_name


func get_size() -> int:
	return len(get_elements())
