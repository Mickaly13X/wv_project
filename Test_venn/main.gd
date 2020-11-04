extends Node2D

var diagrams = []

const ROOM_H = 600
const ROOM_W = 1024
const COLORS = [Color(1, 0, 0, 0.3), Color(0, 1, 0, 0.3), Color(0, 0, 1, 0.3)]

func _ready():
	randomize()
	set_diagram([5, 10, 15, 1, 0, 1, 0])

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()

func _draw():
	for i in range(len(diagrams)):
		draw_circle_custom(diagrams[i].radius, diagrams[i].pos, COLORS[i])

func draw_circle_custom(radius : float, pos : Vector2, color : Color = Color.white, maxerror = 0.25):

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

# for 2-part venns, use 'venn_areas' = [A, B, AB]
# for 3-part venns, use 'venn_areas' = [A, B, C, AB, BC, AC, ABC]
func set_diagram(venn_areas : Array) -> void:
	
	var venn_size = 2 + int(len(venn_areas) > 3)
	var args = ["fetch.py", str(venn_size)]
	for i in venn_areas:
		args.append(str(i))
	var output = []
	var exit_code = OS.execute("python", args, true, output)
	output = str(output[0]).split("\n")
	
	for i in range(venn_size):
		
		var new_diagram = {}
		new_diagram.pos = (Vector2(float(output[2 * i]), float(output[2 * i + 1]))) * 100 + \
			Vector2(ROOM_W, ROOM_H) / 2
		new_diagram.radius = float(output[venn_size * 2 + i]) * 100
		diagrams.append(new_diagram)
	
	print("exit_code " + str(exit_code))
