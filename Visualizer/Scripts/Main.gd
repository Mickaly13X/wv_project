extends Control

const EXCEPTION = preload("res://util/ExceptionIDs.gd")
const SET = preload("res://Scenes/Universe.tscn")
const STRUCTURE_NAMES = [ \
	["sequence", "permutation", "composition"],
	["multisubset",  "subset", "integer composition"],
	["partition", "partition", "partition", "partition"],
	["integer partition", "integer partition", "integer partition", "integer partition"]]

enum Distinct {NONE_SAME, N_SAME, X_SAME, NX_SAME}
enum SetFunction {ANY, INJ, SUR}

onready var CoLaInput = $HSplit/CoLaPanel/CoLaInput
onready var CoLaPanel = $HSplit/CoLaPanel
onready var DistInput = $Popups/MenuStructure/VBox/Items/DistInput
onready var FuncInput = $Popups/MenuStructure/VBox/Items/FuncInput
onready var HSplit = $HSplit
onready var OpenCoLa = $HSplit/MainPanel/UI/HUD/OpenCoLa
onready var Universes = $HSplit/MainPanel/Universes
onready var MenuUniverse = $Popups/MenuUniverse
onready var SizeInput = $Popups/MenuUniverse/VBox/Items/SizeInput

onready var POPUPS = {
	"set_universe": $Popups/MenuUniverse, 
	"open_file": $Popups/OpenFile
	}

var universe_menu : String
var not_domains = ["structure", "size", "pos", "count", "not", "inter", "union", "in"]
var structure = [Distinct.NONE_SAME, SetFunction.ANY]

const ROOM_H = 600
const ROOM_W = 1024
#const COLORS = [Color(1, 0.3, 0.3, 0.33), Color(0.3, 1, 0.3, 0.33), Color(0.3, 0.3, 1, 0.33)]
const MAX_SET_SIZE = 10


func _ready():
	
	randomize()
	init_menus()
	set_structure()
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


func _on_cola_file_selected(path):
	
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	#if is_cola()
	CoLaInput.text = content


func _pressed_mb_input(index, TypeInput):
	
	var InputMenu = TypeInput.get_popup()
	TypeInput.text = InputMenu.get_item_text(index)
	
	if TypeInput == DistInput: structure[0] = index
	if TypeInput == FuncInput: structure[1] = index





func get_input(file_path):
	
	var file = File.new()
	file.open(file_path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content.replace("\n", "").split(".")


func get_ouput():
	pass


func get_universe_name_from_cola():
	pass


func get_universe_size_from_cola():
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


func init_menus() -> void:
	
	# structure menu
	FuncInput.get_popup().connect("id_pressed", self, "_pressed_mb_input", [FuncInput])
	DistInput.get_popup().connect("id_pressed", self, "_pressed_mb_input", [DistInput])
	
	# universe menu
	SizeInput.get_popup().connect("id_pressed", self, "_pressed_mb_input", [SizeInput])
	
	for i in range(MAX_SET_SIZE):
		#to add zero before single digits like 01, 02 instead of 1, 2
		var numberstr = "0" + str(i + 1) if i + 1 < 10 else str(i + 1)
		SizeInput.get_popup().add_item(numberstr)


func intersection(array1, array2):
	
	var intersection = []
	for item in array1:
		if array2.has(item):
			intersection.append(item)
	return intersection


func popup_import():
	
	POPUPS["open_file"].popup()


func set_menu_structure(is_opened : bool) -> void:
	
	if is_opened:
		DistInput.text = DistInput.get_popup().get_item_text(structure[0])
		FuncInput.text = FuncInput.get_popup().get_item_text(structure[1])
		$Popups/MenuStructure.popup()
	else:
		$Popups/MenuStructure.hide()


# ref = N or X
func set_menu_universe(is_opened : bool, ref : String = "N") -> void:
	
	if is_opened:
		universe_menu = ref
		if ref == "N":
			$Popups/MenuUniverse/VBox/Title.text = "Set Universe"
		else:
			$Popups/MenuUniverse/VBox/Title.text = "Set Variables"
		$Popups/MenuUniverse.popup()
	else:
		#$Popups/MenuUniverse/VBox/Items/NameInput.text = ""
		#SizeInput.text = "- -"
		$Popups/MenuUniverse.hide()


func set_structure() -> void:
	
	var distinct = structure[0]
	var set_function = structure[1]
	
	for I in Universes.get_children():
		
		var is_distinct : bool
		if I.name == "N":
			is_distinct = (distinct == Distinct.X_SAME || distinct == Distinct.NONE_SAME)
		else:
			is_distinct = (distinct == Distinct.N_SAME || distinct == Distinct.NONE_SAME)
		I.init(-1, "", is_distinct)
		
	$Structure.text = "Structure = " + STRUCTURE_NAMES[distinct][set_function]


func set_universe() -> void:
	
	var new_name = MenuUniverse.get_node("VBox/Items/NameInput").text
	if new_name == "":
		show_message("Please specify a name")
		return
	
	var new_size = MenuUniverse.get_node("VBox/Items/SizeInput").text
	if new_size == "- -":
		show_message("Please choose a size")
		return
		
	Universes.get_node(universe_menu).init(int(new_size), new_name)
	
	CoLaInput.text += new_name + "{[1," + str(new_size) + "]}"
	set_menu_universe(false)


#func set_universe_diagram() -> void:
#
#	if domains.size() == 0:
#

func show_message(message : String) -> void:
	
	$Popups/Message/Label.text = message
	$Popups/Message.popup()


func run_cola():
	pass


func toggle_cola_panel():
	
	if OpenCoLa.text == ">":
		HSplit.set_dragger_visibility(SplitContainer.DRAGGER_VISIBLE)
		CoLaPanel.show()
		OpenCoLa.text = "<"
	else:
		HSplit.set_dragger_visibility(SplitContainer.DRAGGER_HIDDEN_COLLAPSED)
		CoLaPanel.hide()
		OpenCoLa.text = ">"
