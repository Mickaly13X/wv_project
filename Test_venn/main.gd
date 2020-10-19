extends Node2D

var diagram = []

const COLORS = [Color(1, 0, 0, 0.3), Color(0, 1, 0, 0.3), Color(0, 0, 1, 0.3)]

func _ready():
	
	randomize()
	set_diagram([(randi() % 6 + 1) * 30])

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()

func draw_circle_custom(radius, pos : Vector2, color : Color = Color.white, maxerror = 0.25):

	if radius <= 0.0:
		return
	
	var maxpoints = 1024 # I think this is renderer limit
	
	var numpoints = ceil(PI / acos(1.0 - maxerror / radius))
	numpoints = clamp(numpoints, 3, maxpoints)
	
	var points = PoolVector2Array([])
	
	for i in numpoints:
		var phi = i * PI * 2.0 / numpoints
		var v = Vector2(sin(phi), cos(phi))
		points.push_back(v * radius + pos)
	
	draw_colored_polygon(points, color)

func _draw():
	for i in diagram:
		draw_circle_custom(i.radius, i.pos, i.color)

func set_diagram(sizes : Array):
	
	if len(sizes) >= 1:
		
			var new_circle = {}
			new_circle.radius = sizes[0]
			new_circle.pos = Vector2.ONE * sizes[0]
			new_circle.color = COLORS[0]
			diagram.append(new_circle)
	
	if len(sizes) >= 2:
	
