var center: Vector2
var radius: float


func _init(center: Vector2, radius: float) -> void:
	
	self.center = center
	self.radius = radius


func get_rect() -> Rect2:
	
	return Rect2(
		center - radius * Vector2.ONE,
		center + radius * Vector2.ONE
	)


func get_left() -> Vector2:
	return center + radius * Vector2.LEFT


func get_right() -> Vector2:
	return center + radius * Vector2.RIGHT


func get_top() -> Vector2:
	return center + radius * Vector2.UP


func get_bottom() -> Vector2:
	return center + radius * Vector2.DOWN


func get_left_x() -> float:
	return get_left().x


func get_right_x() -> float:
	return get_right().x


func get_top_y() -> float:
	return get_top().y


func get_bottom_y() -> float:
	return get_bottom().y
