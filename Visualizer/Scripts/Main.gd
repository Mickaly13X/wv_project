extends Control

const Exception = preload("res://util/ExceptionIDs.gd")

onready var SET = preload("res://Scenes/Set.tscn")
onready var MB_SIZE = $Popups/SetUniverse/Items/MbSize
onready var OPEN_COLA = $HSplit/MainPanel/UI/HUD/OpenCoLa
onready var COLA_PANEL = $HSplit/CoLaPanel
onready var COLA = $HSplit/CoLaPanel/CoLaInput
onready var SETS = $HSplit/MainPanel/Sets
onready var HSPLIT = $HSplit
onready var POPUPS = {
	"set_universe": $Popups/SetUniverse, 
	"open_file": $Popups/OpenFile
	}

var not_domains = ["structure", "size", "pos", "count", "not", "inter", "union", "in"]
var diagrams = []

const ROOM_H = 600
const ROOM_W = 1024
const COLORS = [Color(1, 0.3, 0.3, 0.33), Color(0.3, 1, 0.3, 0.33), Color(0.3, 0.3, 1, 0.33)]
const MAX_SET_SIZE = 10


func _ready():
	add_menu_button_items()
	init_menu_buttons()
	randomize()
	POPUPS["open_file"].current_dir = ""
	POPUPS["open_file"].current_path = ""
	#var file_path = "res://tests/paper/constrained/permutation_5_4.test"
	#var domains = get_domains(get_input(file_path))
	#print(domains)
	#set_diagram(get_venn_areas(domains.values()))


func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	#if Input.is_action_just_pressed("ui_accept"):
	#	get_tree().reload_current_scene()


#Initiate the menu button items
func add_menu_button_items():
	for i in range(MAX_SET_SIZE):
		#to add zero before single digits like 01, 02 instead of 1, 2
		var numberstr = "0" + str(i + 1) if i + 1 < 10 else str(i + 1)
		MB_SIZE.get_popup().add_item(numberstr)


#func _draw():
#	for i in range(len(diagrams)):
#		draw_circle_custom(diagrams[i].radius, diagrams[i].pos, COLORS[i])


func add_universe(tag: String, custom_name: String, size: int) -> void:
	var Universe: Node = SETS.get_node(tag)
	Universe.set_name(custom_name)
	Universe.add_elements(size)
	COLA.text += custom_name + "{[1," + str(size) + "]}"


func draw_circle_custom(radius: float, pos: Vector2, color: Color = Color.white, maxerror = 0.25):
	if radius <= 0.0:
		return

	var maxpoints = 1024  # I think this is renderer limit

	var numpoints = ceil(PI / acos(1.0 - maxerror / radius))
	numpoints = clamp(numpoints, 3, maxpoints)

	var points = PoolVector2Array([])

	for i in numpoints:
		var phi = i * PI * 2.0 / numpoints
		var v = Vector2(sin(phi), cos(phi))
		points.push_back(v * radius + pos)

	draw_colored_polygon(points, color)


func get_input(file_path):
	var file = File.new()
	file.open(file_path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content.replace("\n", "").split(".")


func get_ouput():
	#TODO
	pass


#Returns a dictionary with name(of domain):value
func get_domains(input):
	var domain = {}  #the dict to be returned
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
	var highest = [0, ""]
	for key in domain:
		if len(domain[key]) > highest[0]:
			highest[0] = len(domain[key])
			highest[1] = key
		domain.erase(highest[1])

	return domain


func get_domain_name(domain_string):
	var regex = RegEx.new()
	regex.compile("^\\w*")  #regex: ^\w*
	var result = regex.search(domain_string)
	if result:
		return result.get_string()
	return -1


#Only works for intervals for now
func get_domain_value(domain_string):
	var regex = RegEx.new()
	regex.compile("\\[.*\\]")  #regex: [.*]
	var result = regex.search(domain_string)
	if result:
		var values
		#	var val = result.get_string()
		#	var regex2 = RegEx.new()
		#	regex2.compile("\\(\\[.*\\]\\)") #regex: ([.*])
		#	var result2 = regex2.search(val)
		var val = result.get_string()
		values = val.replace("[", "").replace("]", "").replace(" ", "").split(",")
		return range(int(values[0]), int(values[1]) + 1)
	return -1


# domains is a list of ONLY the values of dictionary
func get_venn_areas(domains):
	var venn_areas = []

	# main sets
	for i in domains:
		venn_areas.append(len(i))
	# intersections
	if len(domains) == 2:
		venn_areas.append(len(intersection(domains[0], domains[1])))
	elif len(domains) == 3:
		venn_areas.append(len(intersection(domains[0], domains[1])))
		venn_areas.append(len(intersection(domains[1], domains[2])))
		venn_areas.append(len(intersection(domains[2], domains[0])))
		venn_areas.append(len(intersection(intersection(domains[0], domains[1]), domains[2])))
	return venn_areas


func intersection(array1, array2):
	var intersection = []
	for item in array1:
		if array2.has(item):
			intersection.append(item)
	return intersection


# for 2-part venns, use 'venn_areas' = [A, B, AB]
# for 3-part venns, use 'venn_areas' = [A, B, C, AB, BC, AC, ABC]
func set_diagram(venn_areas: Array) -> void:
	var venn_size = 2 + int(len(venn_areas) > 3)
	var args = ["fetch.py", str(venn_size)]
	for i in venn_areas:
		args.append(str(i))
	var output = []
	var exit_code = OS.execute("python", args, true, output)
	output = str(output[0]).split("\n")

	for i in range(venn_size):
		var new_diagram = {}
		new_diagram.pos = (
			(Vector2(float(output[2 * i]), float(output[2 * i + 1]))) * 100
			+ Vector2(ROOM_W, ROOM_H) / 2
		)
		new_diagram.radius = float(output[venn_size * 2 + i]) * 100
		diagrams.append(new_diagram)

	print("exit_code " + str(exit_code))


#Initialize menu buttons
func init_menu_buttons():
	MB_SIZE.get_popup().connect("id_pressed", self, "_on_size_item_pressed")


#Called when pressing on a size menu button (MB_Size) item
func _on_size_item_pressed(id):
	var selected_size = MB_SIZE.get_popup().get_item_text(id)
	MB_SIZE.text = selected_size


#called when pressing on the Add Set Button
func popup_universe(universe_tag: String) -> void:
	POPUPS["set_universe"].ref_universe = universe_tag
	POPUPS["set_universe"].popup()


func _on_AddVariables_button_up():
	pass  # Replace with function body.


func toggle_cola_panel():
	if OPEN_COLA.text == ">":
		HSPLIT.set_dragger_visibility(SplitContainer.DRAGGER_VISIBLE)
		COLA_PANEL.show()
		OPEN_COLA.text = "<"
	else:
		HSPLIT.set_dragger_visibility(SplitContainer.DRAGGER_HIDDEN_COLLAPSED)
		COLA_PANEL.hide()
		OPEN_COLA.text = ">"


func popup_import():
	POPUPS["open_file"].popup()


func _on_cola_file_selected(path):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	#if is_cola()
	COLA.text = content


func run_cola():
	pass


func get_universe_size_from_cola():
	pass


func get_universe_name_from_cola():
	pass
