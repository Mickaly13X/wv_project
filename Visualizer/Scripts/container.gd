extends Control


var custom_name: String = ""
var shape: StyleBoxFlat

onready var Main: Node
onready var Problem: Node


func _ready():
	
	shape = StyleBoxFlat.new()
	shape.bg_color = Color.transparent
	shape.set_border_width_all(3)
	shape.set_corner_radius_all(30)
	update()


func _draw():
	draw_style_box(shape, Rect2(Vector2(0, 0), $Mask.rect_size))


func deselect_elements():
	
	for I in get_elements():
		I.toggle_selected(false)


func get_center(offset = Vector2.ZERO) -> Vector2:
	return $Mask.rect_position + $Mask.rect_size / 2.0 + offset


func get_container_rect(scaling = 1.0) -> Rect2:
	return Rect2(get_size() * (1 - scaling) / 2.0, get_size() * scaling)


func get_element(element_id: int) -> Node:
	
	for I in get_elements():
		if I.get_id() == element_id:
			return I
	return null


func get_elements() -> Array:
	return $Elements.get_children()


func get_elements_selected() -> Array:
	
	var elements_selected = []
	for I in get_elements():
		if I.is_selected:
			elements_selected.append(I)
	return elements_selected


func get_name() -> String:
	return custom_name


func get_no_elements() -> int:
	return len(get_elements())


func get_size() -> Vector2:
	return $Mask.rect_size


func has_element(id : int):
	
	for I in get_elements():
		if I.get_id() == id:
			return true
	return false


func has_max_elements() -> bool:
	return get_no_elements() == g.MAX_ELEMENTS


func is_editable() -> bool:
	return Main.is_editable()


func lose_focus() -> void:
	deselect_elements()
	toggle_menu(false)


func toggle_menu(is_visible: bool) -> void:
	pass
