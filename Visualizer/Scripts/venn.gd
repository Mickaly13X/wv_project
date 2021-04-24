extends Node2D


const CIRCLE_COLORS = [
	Color(0.244292, 0.300939, 0.367188, 0.33),
	Color(0.244292, 0.300939, 0.367188, 0.33),
	Color(0.244292, 0.300939, 0.367188, 0.33)]

var circles = []


func _draw():
	
	for i in range(len(circles)):
		draw_circle_custom(
			circles[i].radius, circles[i].center, CIRCLE_COLORS[i]
		)


func draw_circle_custom(radius: float, center: Vector2, \
	color: Color = Color.white, maxerror = 0.25):
	
	if radius <= 0.0: return
	
	var maxpoints = 1024  # I think this is renderer limit
	var numpoints = ceil(PI / acos(1.0 - maxerror / radius))
	numpoints = clamp(numpoints, 3, maxpoints)
	var points = PoolVector2Array([])
	
	for i in numpoints:
		var phi = i * PI * 2.0 / numpoints
		var v = Vector2(sin(phi), cos(phi))
		points.push_back(v * radius + center)
	
	draw_colored_polygon(points, color)


func get_rect(circles = self.circles) -> Rect2:
	
	var rect = Rect2()
	rect.position = Vector2(g.lowest_func(circles, "get_left_x"),
							g.lowest_func(circles, "get_top_y"))
	rect.end = Vector2(g.highest_func(circles, "get_right_x"),
					   g.highest_func(circles, "get_bottom_y"))
	return rect


func get_size(circles = self.circles) -> Vector2:
	
	if circles.empty():
		return Vector2.ZERO
	return get_rect().size


func set_circles(circles: Array) -> void:
	self.circles = circles
	update()
