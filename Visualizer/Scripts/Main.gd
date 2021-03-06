extends Control

const EXCEPTION = preload("res://util/ExceptionIDs.gd")
const Domain = preload("res://Scripts/classes.gd").Domain
const Interval = preload("res://Scripts/classes.gd").Interval
const IntervalString = preload("res://Scripts/classes.gd").IntervalString
const CoLaExpression = preload("res://Scripts/classes.gd").CoLaExpression
const SET = preload("res://Scenes/Universe.tscn")
const STRUCTURE_NAMES = [ \
	["sequence", "permutation", "composition"],
	["multisubset",  "subset", "integer composition"],
	["partition", "partition", "partition", "partition"],
	["integer partition", "integer partition", "integer partition", "integer partition"]]

enum Distinct {NONE_SAME, N_SAME, X_SAME, NX_SAME}
enum SetFunction {ANY, INJ, SUR}

onready var Config = $HSplit/MainPanel/Containers/Config
onready var Containers = $HSplit/MainPanel/Containers
onready var CoLaInput = $HSplit/CoLaPanel/CoLaInput
onready var CoLaPanel = $HSplit/CoLaPanel
onready var DistInput = $Popups/MenuStructure/VBox/Items/DistInput
onready var FuncInput = $Popups/MenuStructure/VBox/Items/FuncInput
onready var GroupInput = $Popups/MenuGroup/VBox/Items/GroupInput
onready var HSplit = $HSplit
onready var NewGroupInput = $Popups/MenuGroup/VBox/Items/NewGroupInput
onready var OpenCoLa = $HSplit/MainPanel/UI/HUD/OpenCoLa
onready var MenuContainer = $Popups/MenuContainer
onready var SizeInput = $Popups/MenuContainer/VBox/Items/SizeInput
onready var Popups = $Popups
onready var Universe = $HSplit/MainPanel/Containers/Universe
onready var ConfigNameInput = $Popups/MenuStructure/VBox/Items/NameInput
onready var ConfigSizeInput = $Popups/MenuStructure/VBox/Items/SizeInput


var container_menu : String
var not_domains = ["structure", "size", "pos", "count", "not", "inter", "union", "in"]
var structure = [Distinct.NONE_SAME, SetFunction.ANY]
var domains = [] #Used for actual domains in visualizing

const ROOM_H = 600
const ROOM_W = 1024
const MAX_SET_SIZE = 10
const MAX_CONFIG_SIZE = 10


func _ready():
	
	randomize()
	init_children()
	init_menus()
	Popups.get_node("OpenFile").current_dir = ""
	Popups.get_node("OpenFile").current_path = ""
	#var file_path = "res://tests/paper/constrained/permutation_5_4.test"
	#var domains = get_domains(get_input(file_path))
	#print(domains)
	#set_diagram(get_venn_areas(domains.values()))


func _process(_delta):
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("reload"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("mouse_left"):
		Universe.toggle_menu(false)


func _on_cola_file_selected(path):
	
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	#if is_cola()
	CoLaInput.text = content
	print(parse(content))


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
	GroupInput.get_popup()
	var group_name : String
	if GroupInput.text == "-Select Group-":
		show_message("Please select a group")
		return false
	if GroupInput.text == "New group":
		if NewGroupInput.text == "New group" || NewGroupInput.text == "":
			show_message("Please enter a group name")
			return false
		group_name = NewGroupInput.text
		GroupInput.get_popup().add_item(group_name)
		GroupInput.get_popup().set_item_as_checkable(GroupInput.get_popup().get_item_count()-1,true)
		#set_item_as_checkable
	else:
		group_name = GroupInput.text
	
	Universe.group(group_name)
	toggle_menu_group(false)
	return true


func init_children() -> void:
	
	Universe.Main = self 
	Config.Main = self 


func init_menus() -> void:
	
	# structure menu
	FuncInput.get_popup().connect("id_pressed", self, "_pressed_mb_input", [FuncInput])
	DistInput.get_popup().connect("id_pressed", self, "_pressed_mb_input", [DistInput])
	ConfigSizeInput.get_popup().connect("id_pressed", self, "_pressed_mb_input", [ConfigSizeInput])
	
	# universe menu
	SizeInput.get_popup().connect("id_pressed", self, "_pressed_mb_input", [SizeInput])
	
	for i in range(MAX_SET_SIZE):
		#to add zero before single digits like 01, 02 instead of 1, 2
		var numberstr = "0" + str(i + 1) if i + 1 < 10 else str(i + 1)
		SizeInput.get_popup().add_item(numberstr)
	
	for i in range(MAX_CONFIG_SIZE):
		#to add zero before single digits like 01, 02 instead of 1, 2
		var numberstr = "0" + str(i + 1) if i + 1 < 10 else str(i + 1)
		ConfigSizeInput.get_popup().add_item(numberstr)
	
	# group menu
	GroupInput.get_popup().connect("id_pressed", self, "_pressed_mb_group")
	GroupInput.get_popup().set_item_as_checkable(GroupInput.get_popup().get_item_count()-1,true)
	GroupInput.get_popup().set_hide_on_checkable_item_selection(false)


func popup_import():
	Popups.get_node("OpenFile").popup()


func set_configuration() -> void:
	
	var _name = ConfigNameInput.text
	
	if ConfigSizeInput.text == "- -":
		show_message("Please choose a size")
		return
	var size = int(ConfigSizeInput.text)
	
	
	
	Config.init(size,_name)
#	var distinct = structure[0]
#	var set_function = structure[1]
#
#	for I in Containers.get_children():
#
#		var is_distinct : bool
#		if I.name == "N":
#			is_distinct = (distinct == Distinct.X_SAME || distinct == Distinct.NONE_SAME)
#		else:
#			is_distinct = (distinct == Distinct.N_SAME || distinct == Distinct.NONE_SAME)
#		I.init_distinct(is_distinct)
	
	Universe.is_distinct = true
	toggle_menu_structure(false)
#	$Structure.text = "Structure = " + STRUCTURE_NAMES[distinct][set_function]


func set_container() -> void:
	
	var new_name = MenuContainer.get_node("VBox/Items/NameInput").text
	if new_name == "":
		show_message("Please specify a name")
		return
	
	var new_size = MenuContainer.get_node("VBox/Items/SizeInput").text
	if new_size == "- -":
		show_message("Please choose a size")
		return
		
	Containers.get_node(container_menu).init(int(new_size), new_name)
	
	CoLaInput.text += new_name + "{[1," + str(new_size) + "]}"
	toggle_menu_container(false)


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


# ref = N or X
func toggle_menu_container(is_opened : bool, ref : String = "Universe") -> void:
	
	if is_opened:
		container_menu = ref
		if ref == "Universe":
			$Popups/MenuContainer/VBox/Title.text = "Set Universe"
		else:
			$Popups/MenuContainer/VBox/Title.text = "Set Variables"
		$Popups/MenuContainer.popup()
	else:
		#$Popups/MenuContainer/VBox/Items/NameInput.text = ""
		#SizeInput.text = "- -"
		$Popups/MenuContainer.hide()


func toggle_menu_group(is_opened : bool) -> void:
	
	if is_opened:
		NewGroupInput.hide()
		NewGroupInput.text = ""
		GroupInput.text = "-Select Group-"
		Popups.get_node("MenuGroup").popup()
	else:
		Universe.deselect_elements()
		Popups.get_node("MenuGroup").hide()


func toggle_menu_structure(is_opened : bool) -> void:
	
	if is_opened:
		DistInput.text = DistInput.get_popup().get_item_text(structure[0])
		FuncInput.text = FuncInput.get_popup().get_item_text(structure[1])
		$Popups/MenuStructure.popup()
	else:
		$Popups/MenuStructure.hide()


func _pressed_mb_group(id):
	GroupInput.get_popup().toggle_item_checked(id)
	var selected_group = GroupInput.get_popup().get_item_text(id)
	if selected_group == "New group":
		NewGroupInput.show()
		GroupInput.text = selected_group
	else:
		NewGroupInput.hide()
		#GroupInput.text = selected_group


# Parse CoLa input
func parse(cola_string : String) -> Dictionary:

	var parsed_dict = {}
	var commands = cola_string.replace(";","").replace("\t","").split("\n")
	for command in commands:
		
		if "%" in command or command.replace(" ","").length() <= 1:
			continue
		var expression = Expression.new()
		var tmp = CoLaExpression.new(command)
		var c = tmp.translate() # Returns string in func form
		var error = expression.parse(c,[])
		if error != OK:
			push_error(expression.get_error_text())
		
		var result = expression.execute([], self)
		if not expression.has_execute_failed():
			var key = tmp.get_global_type()
			if parsed_dict.has(key):
				parsed_dict[key].append(result)
			else:
				parsed_dict[key] = [result]
	
	return parsed_dict

# Returns a domain (interval)
func domain_interval(_name, interval_string, distinguishable  = true):
	
	return Domain.new(_name,IntervalString.new(interval_string).get_values(),distinguishable)
