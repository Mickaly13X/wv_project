var center: Vector2
var radius: float


func _init(center: Vector2, radius: float) -> void:
	
	self.center = center
	self.radius = radius


func polygon(max_points = 1024, max_error = 0.25) -> Polygon2D:
	
	if radius <= 0.0: return null
	
	var num_points = ceil(PI / acos(1.0 - max_error / radius))
	num_points = clamp(num_points, 3, max_points)
	var points = PoolVector2Array()
	
	for i in num_points:
		var phi = i * PI * 2.0 / num_points
		var v = Vector2(sin(phi), cos(phi))
		points.push_back(v * radius + center)
	
	var polygon = Polygon2D.new()
	polygon.polygon = points
	return polygon


func rect() -> Rect2:
	
	return Rect2(
		center - radius * Vector2.ONE,
		center + radius * Vector2.ONE
	)


func left() -> Vector2:
	return center + radius * Vector2.LEFT


func right() -> Vector2:
	return center + radius * Vector2.RIGHT


func top() -> Vector2:
	return center + radius * Vector2.UP


func bottom() -> Vector2:
	return center + radius * Vector2.DOWN


func left_x() -> float:
	return left().x


func right_x() -> float:
	return right().x


func top_y() -> float:
	return top().y


func bottom_y() -> float:
	return bottom().y
