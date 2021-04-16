extends Control


const CONFIG_NAMES = [ \
	["sequence", "permutation", "composition"],
	["multisubset",  "subset", "integer composition"],
	["partition", "partition", "partition", "partition"],
	["integer partition", "integer partition", "integer partition", "integer partition"]]
const MAX_CONFIG_SIZE = 10
const MAX_UNI_SIZE = 10
const NOT_DOMAINS = ["structure", "size", "pos", "count", "not", "inter", "union", "in"]
const SET = preload("res://Scenes/Universe.tscn")
const STEPBUTTON = preload("res://Scenes/StepButton.tscn")

enum Distinct {NONE_SAME, N_SAME, X_SAME, NX_SAME}
enum Mode {EDIT, STEPS}
enum SetFunction {ANY, INJ, SUR}

onready var CoLaInput = $HSplit/CoLaPanel/CoLaInput
onready var CoLaPanel = $HSplit/CoLaPanel
onready var Config = $HSplit/VSplit/MainPanel/Containers/Config
onready var ConfigFuncInput = $Popups/MenuConfig/VBox/Items/FuncInput
onready var ConfigNameInput = $Popups/MenuConfig/VBox/Items/NameInput
onready var ConfigSizeInput = $Popups/MenuConfig/VBox/Items/SizeInput
onready var Containers = $HSplit/VSplit/MainPanel/Containers
onready var DistInput = $Popups/MenuGroup/VBox/Items/DistInput
onready var DomainInput = $Popups/MenuPosConstraint/VBox/Items/DomainInput
onready var FuncInput = $Popups/MenuConfig/VBox/Items/FuncInput
onready var GroupInput = $Popups/MenuGroup/VBox/Items/GroupInput
onready var GroupsLabel = $Popups/MenuGroup/VBox/GroupsLabel
onready var HSplit = $HSplit
onready var IntInput = $Popups/MenuSizeConstraint/VBox/Items/IntInput
onready var NewGroupInput = $Popups/MenuGroup/VBox/Items/NewGroupInput
onready var OpenCoLa = $HSplit/MainPanel/UI/HUD/OpenCoLa
onready var OperatorInput = $Popups/MenuSizeConstraint/VBox/Items/OperatorInput
onready var Popups = $Popups
onready var SizeDomainInput = $Popups/MenuSizeConstraint/VBox/Items/DomainInput
onready var UnivSizeInput = $Popups/MenuUniverse/VBox/Items/SizeInput
onready var Universe = $HSplit/VSplit/MainPanel/Containers/Universe
onready var Steps = $HSplit/VSplit/StepPanel/ScrollBox/Steps

var config = [Distinct.NONE_SAME, SetFunction.ANY]
var container_menu : String
var current_step: int
var groups_selection = {} # key : idx, value : bool selected, is reset when group is called
var mode: int
var running_problem
var steps: Array


func _ready():
	
	randomize()
	init_children()
	init_menus()
	Popups.get_node("OpenFile").current_dir = ""
	Popups.get_node("OpenFile").current_path = ""
	#var file_path = "res://tests/paper/constrained/permutation_5_4.test"
	#var domains = get_domains(get_input(file_path))
	#set_diagram(get_venn_areas(domains.values()))


func _process(_delta):
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("reload"):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("rebuild"):
		Universe.update_element_positions()
	if Input.is_action_pressed("mouse_left"):
		Universe.toggle_menu(false)
	if Input.is_action_just_pressed("enter"):
		check_config()
		check_group()
		check_pos_constraint()
		check_size_constraint()
		check_universe()


func _on_cola_file_selected(path):
	
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	#if is_cola()
	CoLaInput.text = content
	parse(content)
	g.problem.calculate_universe()
	g.problem._print()


func _pressed_mb_group(id):
	
	var popup = GroupInput.get_popup()
	popup.toggle_item_checked(id)
	groups_selection[id] = popup.is_item_checked(id)
	#var selected_group = popup.get_item_text(id)
	
	if is_checked("New group"):
		NewGroupInput.show()
		DistInput.show()
		GroupInput.text = "New group"
	else:
		NewGroupInput.hide()
		DistInput.hide()
		GroupInput.text = "-Select Groups-"
#	if selected_group == "New group":
#		if popup.is_item_checked(id):
#			NewGroupInput.show()
#			GroupInput.text = selected_group
#		else:
#			NewGroupInput.hide()
#			GroupInput.text = "-Select Groups-"
#	else:
#		if !popup.is_item_checked(id):
#			NewGroupInput.show()
#			GroupInput.text = selected_group
#		else:
#			NewGroupInput.hide()
		#GroupInput.text = selected_group
	GroupsLabel.text = "Selected: " + get_selected_group_names_as_string()


func _pressed_mb_input(index, TypeInput):
	
	var InputMenu = TypeInput.get_popup()
	TypeInput.text = InputMenu.get_item_text(index)
	
	#if TypeInput == DistInput: config[0] = index
	if TypeInput == FuncInput: config[1] = index


func add_step(problem : g.Problem):
	
	running_problem = problem
	steps.append(running_problem)
	var new_step = STEPBUTTON.instance()
	new_step.init(problem)
	new_step.set_nb(len(steps))
	new_step.update_text()
	Steps.add_child(new_step)


func check_config() -> void:
	
	if $Popups/MenuConfig.visible:
		
		if ConfigSizeInput.text == "- -":
			show_message("Please choose a size")
			return
		
		var custom_name = ConfigNameInput.text
		var size = int(ConfigSizeInput.text)
		var type = ConfigFuncInput.text
		
		g.problem.set_config(type.to_lower(), size, custom_name)
		Config.set_problem(g.problem)
		toggle_menu_config(false)


func check_universe() -> void:
	
	if $Popups/MenuUniverse.visible:
		
		var new_name = $Popups/MenuUniverse/VBox/Items/NameInput.text
		var new_size = UnivSizeInput.text
		if new_size == "- -":
			show_message("Please choose a size")
			return
		
		g.problem.set_universe(range(int(new_size)), new_name)
		Universe.set_problem(g.problem, true, true)
		
		CoLaInput.text += new_name + "{[1," + str(new_size) + "]}"
		toggle_menu_universe(false)


func check_pos_constraint() -> void:
	
	if $Popups/MenuPosConstraint.visible:
		
		if DomainInput.text == "-Select Domain-":
			show_message("Please choose a domain")
			return
		
		var domain_name = DomainInput.get_text()
		if domain_name == "Universe":
			g.problem.add_pos_constraint(Config.index_selected, "universe")
		else:
			g.problem.add_pos_constraint(Config.index_selected, domain_name)
		
		Config.update()
		toggle_menu_pos_constraint(false)


func check_size_constraint() -> void:
	
	if $Popups/MenuSizeConstraint.visible:
		
		if SizeDomainInput.text == "-Select Domain-":
			show_message("Please choose a domain")
			return
		
		var domain_name = SizeDomainInput.text
		var operator = OperatorInput.text
		var size = int(IntInput.text)
		
		g.problem.set_size_constraint(domain_name, operator, size)
		
		Universe.update_domain_names()
		toggle_menu_size_constraint(false)


func check_group() -> void:
	
	if $Popups/MenuGroup.visible:
		group()


func create_cola_file() -> void:
	
	var file = File.new()
	file.open("input.pl", File.WRITE)
	file.store_string(g.problem.to_cola())
	file.close()


func fetch(function_name: String, arguments: Array = []) -> PoolStringArray:
	
	var command = "lib\\fetch\\fetch.exe" # path structure os dependent
	var args = [function_name.left(1)] + arguments
	var output = []
	print(">terminal call {} {}".format([command, str(args)], "{}"))

	var exit_code = OS.execute(command, args, true, output)

	print(">exit_code: " + str(exit_code))
	return output[0].rstrip("\n").split("\n")
	
#	var command = "lib/fetch_osx/fetch" # path structure os dependent
#	var args = [function_name.left(1)] + arguments
#	var output = []
#	print(">terminal call {} {}".format([command, str(args)], "{}"))
#
#	var exit_code = OS.execute(command, args, true, output)
#
#	print(">exit_code: " + str(exit_code))
#	return str(output[0]).split("\n")


func get_input(file_path):
	
	var file = File.new()
	file.open(file_path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content.replace("\n", "").split(".")


func get_path_os(godot_path: String, os: String):
	
	if os == "win":
		return godot_path.replace("/", "\\")


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
		for j in NOT_DOMAINS:
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
	var group_dist : bool
	
	var selected_ids = get_selected_group_ids()
	
	if len(selected_ids) == 0:
		print("Exception in group(): no elements selected")
		return false
	
	for i in get_selected_group_names():
		if i == "New group":
			if NewGroupInput.text == "New group" || NewGroupInput.text == "":
				show_message("Please enter a group name")
				return false
				
			group_name = NewGroupInput.text
			group_dist = DistInput.pressed
			GroupInput.get_popup().add_item(group_name)
			GroupInput.get_popup().set_item_as_checkable(GroupInput.get_popup().get_item_count()-1,true)
			Universe.group(group_name, group_dist)
		else:
			group_name = i
			Universe.group(group_name)
	
	for id in selected_ids:
		GroupInput.get_popup().set_item_checked(id,false)
		groups_selection[id] = false
	toggle_menu_group(false)
	return true


func init_children() -> void:
	
	Config.Main = self 
	Universe.Main = self


func is_checked(group_name : String) -> bool:
	
	var checked = false
	for id in groups_selection:
		if group_name == GroupInput.get_popup().get_item_text(id):
			checked = groups_selection[id]
	return checked


func is_editable() -> bool:
	return mode == Mode.EDIT


func init_menus() -> void:
	
	# config menu
	FuncInput.get_popup().connect("id_pressed", self, "_pressed_mb_input", [FuncInput])
	ConfigSizeInput.get_popup().connect(
		"id_pressed", self, "_pressed_mb_input", [ConfigSizeInput])
	
	# universe menu
	UnivSizeInput.get_popup().connect(
		"id_pressed", self, "_pressed_mb_input", [UnivSizeInput])
	
	# constraint menu
	DomainInput.get_popup().connect(
		"id_pressed", self, "_pressed_mb_input", [DomainInput])
	
	SizeDomainInput.get_popup().connect(
		"id_pressed", self, "_pressed_mb_input", [SizeDomainInput])
	
	OperatorInput.get_popup().connect(
		"id_pressed", self, "_pressed_mb_input", [OperatorInput])
	
	OperatorInput.get_popup().add_item("")
	for op in g.OPERATORS:
		OperatorInput.get_popup().add_item(op)
	
	for i in range(MAX_UNI_SIZE):
		#to add zero before single digits like 01, 02 instead of 1, 2
		var numberstr = "0" + str(i + 1) if i + 1 < 10 else str(i + 1)
		UnivSizeInput.get_popup().add_item(numberstr)
	
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


func run():
	
	if is_editable():
		
		if Config.get_size() ==  0:
			show_message("Config not defined!")
			return
		if Universe.get_size() ==  0:
			show_message("Universe not defined!")
			return
		
		create_cola_file()
		add_step(g.problem)
		# interpret coso output
		var function_steps: PoolStringArray = fetch("coso")
		print(function_steps)
		for i in range(1, len(function_steps)):
			eval(function_steps[i])
		set_mode(Mode.STEPS)
		update_step_panel(g.problem)


# pos_contraint is an Array of domains repr as a list of ints
# size_constraint is an Array of size constraints repr as a list containing domain elements and a list of possible sizes
func run_child(type: String, vars: Array, pos_cs: Array, size_cs: Array) -> void:
	
	var child_problem = g.Problem.new(type, vars, pos_cs, size_cs) # add parameters
		
	child_problem.set_parent(running_problem)
	running_problem.add_child(child_problem)
	add_step(child_problem)


func run_parent(solution: int) -> void:
	
	var parent_problem = running_problem.get_parent()
	running_problem.solution = solution
	get_step_from_problem(running_problem).update_text()
	
	if !g.is_null(parent_problem):
		running_problem = parent_problem


func get_step_from_problem(problem : g.Problem):
	for step in Steps.get_children():
		if step.problem == problem:
			return step
	return 0


func set_mode(mode: int) -> void:
	
	self.mode = mode
	$HSplit/VSplit/StepPanel.visible = !is_editable()
	
	var steps: String
	var current_problem = g.problem
	var current_step = 1
#	while (!g.is_null(current_problem)):
#		steps += "{}. {}\n".format([current_step, current_problem], "{}")
#		current_problem = current_problem.next()
#		current_step += 1
#	$HSplit/VSplit/StepPanel/HBoxContainer/Steps.text = steps


func get_step(problem) -> int:
	
	var current_problem = g.problem
	var current_step = 1
	while (!g.is_null(current_problem)):
		if current_problem == problem:
			return current_step
		current_problem = current_problem.next()
		current_step += 1
	return -1


func set_step(step: int) -> void:
	
	if mode == Mode.STEPS:
		if step >= 0 && step < len(steps):
			
			current_step = step
			var problem = steps[current_step]
			Config.set_problem(problem)
			Universe.set_problem(problem, true, true)
			update_step_panel(problem)


func set_step_next() -> void:
	set_step(current_step + 1)


func set_step_prev() -> void:
	set_step(current_step - 1)


func show_message(message : String) -> void:
	
	$Popups/Message/Label.text = message
	$Popups/Message.popup()


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
		NewGroupInput.hide()
		DistInput.pressed = true
		DistInput.hide()
		NewGroupInput.text = ""
		GroupInput.text = "-Select Groups-"
		Popups.get_node("MenuGroup").popup()
	else:
		Universe.deselect_elements()
		
		Popups.get_node("MenuGroup").hide()


# ref = N or X
func toggle_menu_universe(is_opened : bool) -> void:
	
	if is_opened:
		$Popups/MenuUniverse/VBox/Title.text = "Set Universe"
		$Popups/MenuUniverse.popup()
	else:
		$Popups/MenuUniverse.hide()


func toggle_menu_config(is_opened : bool) -> void:
	
	if is_opened:
		FuncInput.text = FuncInput.get_popup().get_item_text(config[1])
		$Popups/MenuConfig.popup()
	else:
		$Popups/MenuConfig.hide()


func toggle_menu_pos_constraint(is_opened : bool) -> void:
	
	var Menu = Popups.get_node("MenuPosConstraint")
	if is_opened:
		DomainInput.text = "-Select Domain-"
		DomainInput.get_popup().clear()
		DomainInput.get_popup().add_item("Universe")
		for domain in g.problem.get_domains():
			DomainInput.get_popup().add_item(domain.get_name())
		Menu.popup()
	else:
		Menu.hide()


func toggle_menu_size_constraint(is_opened : bool) -> void:
	
	var Menu = Popups.get_node("MenuSizeConstraint")
	if is_opened:
		SizeDomainInput.text = "-Select Domain-"
		SizeDomainInput.get_popup().clear()
		#SizeDomainInput.get_popup().add_item("Universe")
		for domain in g.problem.get_domains():
			SizeDomainInput.get_popup().add_item(domain.get_name())
		Menu.popup()
	else:
		Menu.hide()


func undo_menu(ref : String) -> void:
	
	var container = Containers.get_node(ref)
	container.deselect_elements()
	container.toggle_menu(false)


func update_step_panel(problem) -> void:
	
	$HSplit/VSplit/StepPanel/HBoxContainer/CurrentStep.text = \
		"Current step: " + str(get_step(problem))
	$HSplit/VSplit/StepPanel/HBoxContainer/Solution.text = \
		"Solution: " + str(problem.solution)


func get_selected_group_names_as_string() -> String:
	
	var group_names = ""
	for id in groups_selection:
		if groups_selection[id] == true:
			if group_names == "":
				group_names += GroupInput.get_popup().get_item_text(id)
			else:
				group_names += ", "+GroupInput.get_popup().get_item_text(id)
	
	return group_names


func get_selected_group_ids() -> String:
	
	var group_ids = []
	for id in groups_selection:
		if groups_selection[id] == true:
			group_ids.append(id)
	return group_ids


func get_selected_group_names() -> String:
	
	var group_names = []
	for id in groups_selection:
		if groups_selection[id] == true:
			group_names.append(GroupInput.get_popup().get_item_text(id))
	return group_names


# Parse CoLa input
func parse(cola_string : String) -> Dictionary:
	
	g.problem.reset()

	var parsed_dict = {}
	var commands = cola_string.replace(";","").replace("\t","").split("\n")
	for command in commands:
		# Ignore comments
		if "%" in command or command.replace(" ","").length() <= 1:
			continue
		
		
		var tmp = g.CoLaExpression.new(command)
		var c = tmp.translate() # Returns string in func form
		var expression = Expression.new()
		var error = expression.parse(c,[])
		if error != OK:
			push_error(expression.get_error_text())
		
		var result = expression.execute([], self)
		if not expression.has_execute_failed():
			pass
	
	return parsed_dict


func domain_interval(_name, interval_string, distinguishable  = true):
	
	g.problem.add_domain(g.Domain.new(_name, g.IntervalString.new(interval_string).get_values(), bool(distinguishable)))


func domain_enum(_name, array_string, distinguishable  = true):
	
	var int_array = []
	var list = array_string.replace("[","").replace("]","").split(",")
	for i in range(len(list)):
		int_array.append(int(i))
	
	g.problem.add_domain(g.Domain.new(_name, int_array, bool(distinguishable)))


func config(type, size, _name, domain_name):
	
	var domain = g.problem.get_domain(domain_name)
	g.problem.set_config(type, int(size), _name, domain)


func config_size(size):
	
	g.problem.get_config().set_size(size)


func size_constraint(_name, op, size):
	
	if g.problem.get_config().get_name() == _name && op == "=":
		g.problem.get_config().set_size(int(size))
	
	else:
		g.problem.set_size_constraint(_name, op, int(size))
	

func pos_constraint(position, domain_name):
	
	g.problem.add_pos_constraint(int(position), domain_name)


func toggle_menu_constraint_pos(extra_arg_0):
	pass # Replace with function body.


func eval(string : String) -> bool:
	
	var expression = Expression.new()
	var error = expression.parse(string,[])
	if error != OK:
		push_error(expression.get_error_text())
		
	var result = expression.execute([], self)
	if not expression.has_execute_failed():
		return true
	else:
		return false
