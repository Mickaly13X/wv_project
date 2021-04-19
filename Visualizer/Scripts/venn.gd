extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var circles_domain = []
var CIRCLE_COLORS
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	for i in range(len(circles_domain)):
		draw_circle_custom(
			circles_domain[i].radius, circles_domain[i].pos, CIRCLE_COLORS[i]
		)


func draw_circle_custom(radius: float, pos: Vector2, \
	color: Color = Color.white, maxerror = 0.25):
	
	if radius <= 0.0: return
	
	var maxpoints = 1024  # I think this is renderer limit
	var numpoints = ceil(PI / acos(1.0 - maxerror / radius))
	numpoints = clamp(numpoints, 3, maxpoints)
	var points = PoolVector2Array([])
	
	for i in numpoints:
		var phi = i * PI * 2.0 / numpoints
		var v = Vector2(sin(phi), cos(phi))
		points.push_back(v * radius + pos)
	
	draw_colored_polygon(points, color)
