extends Node2D


const CIRCLE_COLORS = [
	Color(0.244292, 0.300939, 0.367188, 0.33),
	Color(0.244292, 0.300939, 0.367188, 0.33),
	Color(0.244292, 0.300939, 0.367188, 0.33)]

var circles = []


func _draw():
	
	for i in range(len(circles)):
		draw_colored_polygon(circles[i].polygon(), CIRCLE_COLORS[i])


func get_rect(circles = self.circles) -> Rect2:
	
	var rect = Rect2()
	rect.position = Vector2(g.lowest_func(circles, "left_x"),
							g.lowest_func(circles, "top_y"))
	rect.end = Vector2(g.highest_func(circles, "right_x"),
					   g.highest_func(circles, "bottom_y"))
	return rect


func get_size(circles = self.circles) -> Vector2:
	
	if circles.empty():
		return Vector2.ZERO
	return get_rect().size


func set_circles(circles: Array) -> void:
	self.circles = circles
	update()
