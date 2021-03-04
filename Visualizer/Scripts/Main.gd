extends Control

const EXCEPTION = preload("res://util/ExceptionIDs.gd")
const Domain = preload("res://Scripts/classes.gd").Domain
const Interval = preload("res://Scripts/classes.gd").Interval
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
onready var GroupInput = $Popups/MenuGroup/VBox/Items/GroupInput
onready var HSplit = $HSplit
onready var NewGroupInput = $Popups/MenuGroup/VBox/Items/NewGroupInput
onready var OpenCoLa = $HSplit/MainPanel/UI/HUD/OpenCoLa
onready var Universes = $HSplit/MainPanel/Universes
onready var MenuUniverse = $Popups/MenuUniverse
onready var SizeInput = $Popups/MenuUniverse/VBox/Items/SizeInput
onready var Popups = $Popups

var universe_menu : String
var not_domains = ["structure", "size", "pos", "count", "not", "inter", "union", "in"]
var structure = [Distinct.NONE_SAME, SetFunction.ANY]

const ROOM_H = 600
const ROOM_W = 1024
#const COLORS = [Color(1, 0.3, 0.3, 0.33), Color(0.3, 1, 0.3, 0.33), Color(0.3, 0.3, 1, 0.33)]
const MAX_SET_SIZE = 10


func _ready():
	
	randomize()
	init_children()
	init_menus()
	set_structure()
	Popups.get_node("OpenFile").current_dir = ""
	Popups.get_node("OpenFile").current_path = ""
	#var file_path = "res://tests/paper/constrained/permutation_5_4.test"
	#var domains = get_domains(get_input(file_path))
	#print(domains)
	#set_diagram(get_venn_areas(domains.values()))


func _process(_delta):
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	#if Input.is_action_just_pressed("ui_accept"):
	#	get_tree().reload_current_scene()
	if Input.is_action_pressed("mouse_left"):
		Universes.get_node("N").toggle_menu(false)
		Universes.get_node("X").toggle_menu(false)

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


# @return exit_code
func group() -> bool:
	
	var group_name : String
	if GroupInput.text == "New group":
		if NewGroupInput.text == "New group" || NewGroupInput.text == "":
			show_message("Please enter a group name")
			return false
		group_name = NewGroupInput.text
		GroupInput.get_popup().add_item(group_name)
	else:
		group_name = GroupInput.text
	
	Universes.get_node("N").group(group_name)
	toggle_menu_group(false)
	return true


func init_children() -> void:
	
	Universes.get_node("N").Main = self 
	Universes.get_node("X").Main = self 


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
	
	# group menu
	GroupInput.get_popup().connect("id_pressed", self, "_pressed_mb_group")


func popup_import():
	Popups.get_node("OpenFile").popup()


func set_structure() -> void:
	
	var distinct = structure[0]
	var set_function = structure[1]
	
	for I in Universes.get_children():
		
		var is_distinct : bool
		if I.name == "N":
			is_distinct = (distinct == Distinct.X_SAME || distinct == Distinct.NONE_SAME)
		else:
			is_distinct = (distinct == Distinct.N_SAME || distinct == Distinct.NONE_SAME)
		I.init_distinct(is_distinct)
		
	toggle_menu_structure(false)
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
	toggle_menu_universe(false)


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


func toggle_menu_group(is_opened : bool) -> void:
	
	if is_opened:
		Popups.get_node("MenuGroup").popup()
	else:
		NewGroupInput.text = ""
		GroupInput.text = "-Select Group-"
		Universes.get_node("N").deselect_elements()
		Popups.get_node("MenuGroup").hide()


func toggle_menu_structure(is_opened : bool) -> void:
	
	if is_opened:
		DistInput.text = DistInput.get_popup().get_item_text(structure[0])
		FuncInput.text = FuncInput.get_popup().get_item_text(structure[1])
		$Popups/MenuStructure.popup()
	else:
		$Popups/MenuStructure.hide()


# ref = N or X
func toggle_menu_universe(is_opened : bool, ref : String = "N") -> void:
	
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



func _pressed_mb_group(id):
	
	var selected_group = GroupInput.get_popup().get_item_text(id)
	if selected_group == "New group":
		NewGroupInput.show()
		GroupInput.text = selected_group
	else:
		NewGroupInput.hide()
		GroupInput.text = selected_group
