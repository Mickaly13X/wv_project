extends Node2D

var not_domains = ["structure","size","pos","count","not","inter","union","in"]
var diagrams = []

const ROOM_H = 600
const ROOM_W = 1024
const COLORS = [Color(1, 0, 0, 0.3), Color(0, 1, 0, 0.3), Color(0, 0, 1, 0.3)]

func _ready():
	randomize()
	var file_path = "res://tests/paper/constrained/permutation_5_4.test"
	var domains = get_domains(get_input(file_path))
	print(domains)
	set_diagram(get_venn_areas(domains.values()))

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().reload_current_scene()

func _draw():
	for i in range(len(diagrams)):
		draw_circle_custom(diagrams[i].radius, diagrams[i].pos, COLORS[i])

func get_input(file_path):
	var file = File.new()
	file.open(file_path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content.replace("\n","").split(".")
	
func get_ouput():
	#TODO
	pass

#Returns a dictionary with name(of domain):value
func get_domains(input):
	var domain = {} #the dict to be returned
	var domain_strings = []
	for i in input:
		var is_domain = true
		for j in not_domains:
			if j in i or i == "":
				is_domain = false
				break
		if is_domain:
			domain_strings.append(i)
	for i in domain_strings:
		var key = get_domain_name(i)
		var value = get_domain_value(i)
		domain[key] = value
	#delete domain with highest length -> universe
	var highest = [0,""]
	for key in domain:
		if len(domain[key]) > highest[0]:
			highest[0] = len(domain[key])
			highest[1] = key
		domain.erase(highest[1])

	return domain
	
	
func get_domain_name(domain_string):
	var regex = RegEx.new()
	regex.compile("^\\w*") #regex: ^\w*
	var result = regex.search(domain_string)
	if result:
		return result.get_string()
	return -1

#Only works for intervals for now
func get_domain_value(domain_string):
	var regex = RegEx.new()
	regex.compile("\\[.*\\]") #regex: [.*]
	var result = regex.search(domain_string)
	if result:
		var values
	#	var val = result.get_string()
	#	var regex2 = RegEx.new()
	#	regex2.compile("\\(\\[.*\\]\\)") #regex: ([.*])
	#	var result2 = regex2.search(val)
		var val = result.get_string()
		values = val.replace("[","").replace("]","").replace(" ","").split(",")
		return range(int(values[0]),int(values[1])+1)
	return -1



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

#domains is a list of ONLY the values of dictionary
func get_venn_areas(domains):
	var venn_area = []
	for i in domains:
		venn_area.append(len(i))
	if len(domains) == 2:
		for i in domains:
			for j in domains:
				if j != i:
					venn_area.append(len(intersection(i,j)))
			break
	return venn_area
	
func intersection(array1, array2):
	var intersection = []
	for item in array1:
		if array2.has(item):
			intersection.append(item)
	return intersection




