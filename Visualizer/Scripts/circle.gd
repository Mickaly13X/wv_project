var center: Vector2
var radius: float


func _init(center: Vector2, radius: float) -> void:
	
	self.center = center
	self.radius = radius


# returns an approximate of this circle with 'max_points' verteces, e.g. a polygon
# @post polygon lies strictly inside circle
func polygon(max_points = 1024, max_error = 0.25) -> PoolVector2Array:
	
	if radius <= 0.0: return PoolVector2Array()
	
	var num_points = ceil(PI / acos(1.0 - max_error / radius))
	num_points = clamp(num_points, 3, max_points)
	var points = PoolVector2Array()
	
	for i in num_points:
		var phi = i * PI * 2.0 / num_points
		var v = Vector2(sin(phi), cos(phi))
		points.push_back(v * radius + center)
	
	return points


# returns a rectangle which minimally encloses this circle
func rect() -> Rect2:
	
	return Rect2(
		center - radius * Vector2.ONE,
		center + radius * Vector2.ONE
	)


# returns the left most point
func left() -> Vector2:
	return center + radius * Vector2.LEFT


# returns the right most point
func right() -> Vector2:
	return center + radius * Vector2.RIGHT


# returns the top point
func top() -> Vector2:
	return center + radius * Vector2.UP


# returns the bottom point
func bottom() -> Vector2:
	return center + radius * Vector2.DOWN


# returns the lowest x-value of this circle
func left_x() -> float:
	return left().x


# returns the highest x-value of this circle
func right_x() -> float:
	return right().x


# returns the lowest y-value of this circle
func top_y() -> float:
	return top().y


# returns the highest y-value of this circle
func bottom_y() -> float:
	return bottom().y
