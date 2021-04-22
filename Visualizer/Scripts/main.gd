extends Control


const CONFIG_NAMES = [ \
	["sequence", "permutation", "composition"],
	["multisubset",  "subset", "integer composition"],
	["partition", "partition", "partition", "partition"],
	["integer partition", "integer partition", "integer partition", "integer partition"]]
const MAX_DOMAINS = 3
const MAX_CONFIG_SIZE = 10
const MAX_UNI_SIZE = 10
const NOT_DOMAINS = ["structure", "size", "pos", "count", "not", "inter", "union", "in"]
const PROBLEM = preload("res://Scenes/Problem.tscn")
const STEPBUTTON = preload("res://Scenes/StepButton.tscn")

enum Distinct {NONE_SAME, N_SAME, X_SAME, NX_SAME}
enum Mode {EDIT, STEPS}
enum SetFunction {ANY, INJ, SUR}

onready var CoLaInput = $HSplit/CoLaPanel/CoLaInput
onready var CoLaPanel = $HSplit/CoLaPanel
onready var Config = $HSplit/VBox/MainPanel/Problems/Problem0/Config
onready var ConfigFuncInput = $Popups/MenuConfig/VBox/Items/FuncInput
onready var ConfigNameInput = $Popups/MenuConfig/VBox/Items/NameInput
onready var ConfigSizeInput = $Popups/MenuConfig/VBox/Items/SizeInput
onready var DistInput = $Popups/MenuGroup/VBox/Items/DistInput
onready var DomainInput = $Popups/MenuPosConstraint/VBox/Items/DomainInput
onready var FuncInput = $Popups/MenuConfig/VBox/Items/FuncInput
onready var GroupInput = $Popups/MenuGroup/VBox/Items/GroupInput
onready var GroupsLabel = $Popups/MenuGroup/VBox/GroupsLabel
onready var HSplit = $HSplit
onready var IntInput = $Popups/MenuSizeConstraint/VBox/Items/IntInput
onready var NewGroupInput = $Popups/MenuGroup/VBox/Items/NewGroupInput
onready var OpenCoLa = $HSplit/VBox/MainPanel/UI/HUD/OpenCoLa
onready var OperatorInput = $Popups/MenuSizeConstraint/VBox/Items/OperatorInput
onready var Popups = $Popups
onready var Problem = $HSplit/VBox/MainPanel/Problems/Problem0
onready var Problems = $HSplit/VBox/MainPanel/Problems
onready var SizeDomainInput = $Popups/MenuSizeConstraint/VBox/Items/DomainInput
onready var Steps = $HSplit/VBox/StepPanel/ScrollBox/Steps
onready var Universe = $HSplit/VBox/MainPanel/Problems/Problem0/Universe
onready var UnivSizeInput = $Popups/MenuUniverse/VBox/Items/SizeInput
onready var FileMenu = $HSplit/VBox/MainPanel/UI/HUD/Main/File
onready var EditMenu = $HSplit/VBox/MainPanel/UI/HUD/Main/Edit
onready var ProblemMenu = $HSplit/VBox/MainPanel/UI/HUD/Main/Problem

var config = [Distinct.NONE_SAME, SetFunction.ANY]
var container_menu : String
var current_step: int
var groups_selection = {} # key : idx, value : bool selected, is reset when group is called
var mode: int
var running_problem


func _ready():
	
	randomize()
	Problem.set_self(self, g.problem)
	init_menus()
	Popups.get_node("OpenFile").current_dir = ""
	Popups.get_node("OpenFile").current_path = ""


func _process(_delta):
	
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("ctrl_R"):
		clear()
	
	if is_editable():
		if Input.is_action_just_pressed("ctrl_B"):
			Universe.update_element_positions()
		if Input.is_action_just_pressed("enter"):
			check_config()
			check_group()
			check_pos_constraint()
			check_size_constraint()
			check_universe()


func _gui_input(event):
	
	if is_editable():
		if event.is_pressed():
			Problem.lose_focus()


func _import(file_path):
	
	var file = File.new()
	file.open(file_path, File.READ)
	var content = file.get_as_text()
	#if is_cola()
	CoLaInput.text = content #TODO
	parse(content)
	Problem.set_self(self, g.problem)


func _export():
	
	var file = File.new()
	var file_path = Popups.get_node("SaveFile").current_path
	file.open(file_path, File.WRITE)
	file.store_string(g.problem.to_cola())
	file.close()
	#show_message("Succesfully exported to " + str(file_path))


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


func _pressed_mb_main(index, TypeInput):
	
	Problem.lose_focus()
	var PUMenu = TypeInput.get_popup()
	var SelectedText = PUMenu.get_item_text(index)
	match SelectedText:
		
		"Import":
			popup_import()
		
		"Export":
			popup_export()
		
		"Clear":
			clear()
		
		"New Universe":
			toggle_menu_universe(true)
		
		"New Configuration":
			toggle_menu_config(true)
		
		"Add Element":
			Universe._pressed("Add")
		
		"Group":
			toggle_menu_group(true)
		
		"Add Position Constraint":
			toggle_menu_pos_constraint(true, true)
		
		"Add Size Constraint":
			toggle_menu_size_constraint(true)


func add_step(problem : g.Problem):
	
	var no_steps = len(Steps.get_children())
	
	# order matters
	if problem != g.problem:
		var new_problem = PROBLEM.instance()
		new_problem.set_self(self, problem)
		new_problem.name = "Problem" + str(no_steps)
		new_problem.hide()
		Problems.add_child(new_problem)
	
	running_problem = problem
	var new_step = STEPBUTTON.instance()
	new_step.init(problem, no_steps, (problem == g.problem))
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
		var position = Config.get_elements_selected()[0].get_id()
		if $Popups/MenuPosConstraint/VBox/Items/Position.visible:
			if $Popups/MenuPosConstraint/VBox/Items/PositionInput.text == "":
				show_message("Please specify a position")
				return
			position = int($Popups/MenuPosConstraint/VBox/Items/PositionInput.text)
#			if position != OK:
#				show_message("Size must be an integer")
#				return
			
		
		var domain_name = DomainInput.get_text()
		if domain_name == "Universe":
			g.problem.add_pos_constraint(position, "")
		else:
			g.problem.add_pos_constraint(position, domain_name)
		
		Config.deselect_elements()
		Problem.update()
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
		
		Universe.set_domain_tags()
		toggle_menu_size_constraint(false)


func check_group() -> void:
	
	if $Popups/MenuGroup.visible:
		group()


func clear() -> void:
	
	g.problem = g.Problem.new()
	get_tree().reload_current_scene()


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


func get_item_idx_from_string(PUMenu : PopupMenu, item_name : String) -> int:
	
	for i in range(PUMenu.get_item_count()):
		if PUMenu.get_item_text(i) == item_name:
			return i
	return -1


func get_input(file_path):
	
	var file = File.new()
	file.open(file_path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content.replace("\n", "").split(".")


func get_path_os(godot_path: String, os: String):
	
	if os == "win":
		return godot_path.replace("/", "\\")


##Returns a dictionary with name(of domain):value
#func get_domains(input):
#
#	var domain = {}  #the dict to be returned
#	var domain_strings = []
#	for i in input:
#		var is_domain = true
#		for j in NOT_DOMAINS:
#			if j in i or i == "":
#				is_domain = false
#				break
#		if is_domain:
#			domain_strings.append(i)
#	for i in domain_strings:
#		var key = get_domain_name(i)
#		var value = get_domain_value(i)
#		domain[key] = value
#	#delete domain with highest length -> universe
#	var highest = [0, ""]
#	for key in domain:
#		if len(domain[key]) > highest[0]:
#			highest[0] = len(domain[key])
#			highest[1] = key
#		domain.erase(highest[1])
#
#	return domain


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


func group() -> void:
	
	var selected_ids = get_selected_group_ids()
	if len(selected_ids) == 0:
		print("Exception in group(): no elements selected")
		return
	
	for selected_name in get_selected_group_names():
		
		if selected_name == "New group":
			
			if len(g.problem.get_domains()) >= MAX_DOMAINS:
				show_message("There cannot be more than " + str(MAX_DOMAINS) + " groups")
				return
			
			var group_name: String = NewGroupInput.text
			var group_dist: bool = DistInput.pressed
			if group_name == "New group" || group_name == "":
				show_message("Please enter a group name")
				return
			
			#TODO: duplicate groups
			GroupInput.get_popup().add_item(group_name)
			GroupInput.get_popup().set_item_as_checkable(GroupInput.get_popup().get_item_count() - 1,true)
			Universe.group(group_name, group_dist)
			
		else: Universe.group(selected_name)
	
	for id in selected_ids:
		GroupInput.get_popup().set_item_checked(id,false)
		groups_selection[id] = false
	toggle_menu_group(false)
	return


func is_checked(group_name : String) -> bool:
	
	var checked = false
	for id in groups_selection:
		if group_name == GroupInput.get_popup().get_item_text(id):
			checked = groups_selection[id]
	return checked


func is_editable() -> bool:
	return mode == Mode.EDIT


func init_menus() -> void:
	
	# MAIN
	
	# file
	FileMenu.get_popup().connect("id_pressed", self, "_pressed_mb_main", [FileMenu])
	FileMenu.get_popup().add_item("Import")
	FileMenu.get_popup().add_item("Export")
	
	# edit
	EditMenu.get_popup().connect("id_pressed", self, "_pressed_mb_main", [EditMenu])
	EditMenu.get_popup().add_item("Clear")
	
	#problem
	ProblemMenu.get_popup().connect("id_pressed", self, "_pressed_mb_main", [ProblemMenu])
	ProblemMenu.get_popup().add_item("New Universe")
	ProblemMenu.get_popup().add_item("New Configuration")
	ProblemMenu.get_popup().add_item("",100)
	ProblemMenu.get_popup().add_item("Add Element")
	ProblemMenu.get_popup().add_item("Group")
	ProblemMenu.get_popup().add_item("",101)
	ProblemMenu.get_popup().add_item("Add Position Constraint")
	ProblemMenu.get_popup().add_item("Add Size Constraint")
	ProblemMenu.get_popup().set_item_as_separator(ProblemMenu.get_popup().get_item_index(100), true)
	ProblemMenu.get_popup().set_item_as_separator(ProblemMenu.get_popup().get_item_index(101), true)
	
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


func popup_export():
	Popups.get_node("SaveFile").popup()


func run():
	
	if is_editable():
		
		if Config.get_no_elements() ==  0:
			show_message("Config not defined!")
			return
		if Universe.get_no_elements() ==  0:
			show_message("Universe not defined!")
			return
		
		create_cola_file()
		add_step(g.problem)
		# interpret coso output
		var function_steps: PoolStringArray = fetch("coso")
		for i in range(1, len(function_steps)):
			eval(function_steps[i])
		
		for I in Config.get_elements():
			I.toggle_selected(false)
		for I in Universe.get_elements():
			I.toggle_selected(false)
		set_mode(Mode.STEPS)


# pos_contraint is an Array of domains repr as a list of ints
# size_constraint is an Array of size constraints repr as a list containing domain elements and a list of possible sizes
func run_child(type: String, vars: Array, pos_cs: Array, size_cs: Array) -> void:
	
	var child_problem = g.Problem.new(type, vars, pos_cs, size_cs) # add parameters
	
	running_problem.add_child(child_problem)
	add_step(child_problem)


func run_parent(solution: int) -> void:
	
	running_problem.solution = solution
	get_step_button(running_problem).update_text()
	
	var parent_problem = running_problem.get_parent()
	if !g.is_null(parent_problem):
		running_problem = parent_problem


func get_step(problem) -> int:
	return Steps.get_children().find(get_step_button(problem))


func get_step_button(problem: g.Problem) -> Node:
	
	for step_button in Steps.get_children():
		if step_button.problem == problem:
			return step_button
	return null


func set_mode(mode: int) -> void:
	
	if mode == Mode.EDIT:
		set_step(0)
		for I in Steps.get_children():
			I.free()
		for I in Problems.get_children():
			if I.name != "Problem0":
				I.free()
	
	self.mode = mode
	$HSplit/VBox/StepPanel.visible = (mode == Mode.STEPS)
	$HSplit/VBox/MainPanel/UI/HUD.visible = (mode == Mode.EDIT)
	$Edit.visible = (mode == Mode.STEPS)
	toggle_main_panel(mode == Mode.STEPS)


func set_step(step: int) -> void:
	
	if mode == Mode.STEPS:
		if step >= 0 && step < len(Steps.get_children()):
			
			for i in range(len(Steps.get_children())):
				Problems.get_node("Problem" + str(i)) \
					.visible = (i == step)
				Steps.get_child(i).toggle_selected(i == step)


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


func toggle_main_panel(is_opened : bool) -> void:
	
	if is_opened:
		Problems.rect_position.y -= $HSplit/VBox/MainPanel/UI/HUD.rect_size[1] + 60

	else:
		Problems.rect_position.y += $HSplit/VBox/MainPanel/UI/HUD.rect_size[1] + 60


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


func toggle_menu_problem_button(button_name : String, is_pressable : bool):
	
	ProblemMenu.get_popup().set_item_disabled(get_item_idx_from_string(ProblemMenu.get_popup(), button_name), !is_pressable)


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


func toggle_menu_pos_constraint(is_opened : bool, ask_position : bool = false) -> void:
	
	var Menu = Popups.get_node("MenuPosConstraint")
	if is_opened:
		DomainInput.text = "-Select Domain-"
		DomainInput.get_popup().clear()
		DomainInput.get_popup().add_item("Universe")
		for domain in g.problem.get_domains():
			DomainInput.get_popup().add_item(domain.get_name())
		if ask_position:
			Menu.get_node("VBox/Items/Position").show()
			Menu.get_node("VBox/Items/PositionInput").show()
		else:
			Menu.get_node("VBox/Items/Position").hide()
			Menu.get_node("VBox/Items/PositionInput").hide()
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
func parse(cola_string : String) -> void:
	
	g.problem.reset()
	
	var commands = cola_string.replace(";","").replace("\t","").split("\n")
	for command in commands:
		# Ignore comments
		if "%" in command or command.replace(" ","").length() <= 1:
			continue
		
		var tmp = g.CoLaExpression.new(command)
		eval(tmp.translate())


func parse_domain_interval(domain_name, interval_string, is_dist = true):
	
	var elements = g.IntervalString.new(interval_string).get_values()
	g.problem.add_domain(g.Domain.new(domain_name, elements, is_dist))


func parse_domain_enum(domain_name: String, elem_liststr: String, is_dist = true):
	
	var elem_names: PoolStringArray = \
		elem_liststr.replace("[", "").replace("]", "").split(",")
	
	var new_domain = g.Domain.new(domain_name, [], is_dist)
	g.problem.add_domain(new_domain)
	g.problem.add_strlist_to_domain(new_domain, elem_names)


func parse_config(type, size: int, custom_name: String, domain_name: String):
	
	var domain = g.problem.get_domain(domain_name)
	g.problem.set_config(type, size, custom_name, domain)


func parse_size_cs(_name, op, size: int):
	
	if _name == g.problem.get_config().get_name() && op == "=":
		g.problem.get_config().set_size(size)
	else:
		g.problem.set_size_constraint(_name, op, size)
	

func parse_pos_cs(position, domain_name):
	g.problem.add_pos_constraint(int(position), domain_name)


func eval(func_str : String) -> bool:
	
	var expression = Expression.new()
	var error = expression.parse(func_str, [])
	if error != OK:
		push_error(expression.get_error_text())
		
	expression.execute([], self)
	if not expression.has_execute_failed():
		return true
	else:
		return false


func _update_item_disabled():
	
	toggle_menu_problem_button("Add Elements", !(Universe.has_max_elements() || Universe.has_selected_elements()))
	#toggle_menu_problem_button("Delete", Universe.has_selected_elements)
	toggle_menu_problem_button("Group", Universe.has_selected_elements())
	toggle_menu_problem_button("Add Position Constraint", len(Config.get_elements()) != 0)
	
