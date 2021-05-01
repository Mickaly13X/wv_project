extends Control


const CONFIG_NAMES = [ \
	["sequence", "permutation", "composition"],
	["multisubset",  "subset", "integer composition"],
	["partition", "partition", "partition", "partition"],
	["integer partition", "integer partition", "integer partition", "integer partition"]]
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
onready var DocTabs = $Popups/Docs/VBox/HSplit/DocTabs
onready var TutTabs = $Popups/Tutorial/VBox/TutTabs

var config = [Distinct.NONE_SAME, SetFunction.ANY]
var container_menu : String
var current_step: int
var groups_selection = {} # key : idx, value : bool selected, is reset when group is called
var mode: int
var running_problem


func _ready():
	
	randomize()
	Problem.init(self, g.problem)
	init_docs()
	init_menus()
	Popups.get_node("OpenFile").current_dir = ""
	Popups.get_node("OpenFile").current_path = ""
	Popups.get_node("Tutorial").popup()


func init_docs() -> void:
	
	DocTabs.get_node("Sequence").set_content(
		"""This case counts the number of sequences/rows containing N elements. Elements may appear multiple times in the sequence/row and the order of a row matters, meaning the row (a, b) is a different case than the row (b, a).
		"""
	)
	DocTabs.get_node("Permutation").set_content(
		"""This case counts the number of sequences/rows containing N elements. Every element may only appear once in the sequence/row and the order of a row matters, meaning the row (a, b) is a different case than the row (b, a).
		"""
	)
	DocTabs.get_node("Subset").set_content(
		"""	Also known as a Combination. This case counts the number of subsets with N elements that can be selected from the total set (universe) of X elements. The order of elements in a given subset does not matter, meaning the set (a, b) is the same as the set (b, a). Contrary to a multi-subset configuration, every element may only appear once in a given subset.
			
			The solution is given by the binomial coefficient that is shown left of the equation.
		"""
	)
	DocTabs.get_node("MultiSubset").set_content(
		"""	Also known as a Multi-Combination. This case counts the number of subsets with N elements that can be selected from the total set (universe) of X elements. The order of elements in a given subset does not matter, meaning the set (a, b) is the same as the set (b, a). Contrary to a subset configuration, elements may appear multiple times in a given subset.
		"""
	)
	DocTabs.get_node("Partition").set_content(
		"""	This case is equivalent to counting partitions of N into x (non-empty) subsets, or counting equivalence relations on N with exactly x classes. Indeed, for any surjective function f : N → X, the relation of having the same image under f is such an equivalence relation, and it does not change when a permutation of X is subsequently applied; conversely one can turn such an equivalence relation into a surjective function by assigning the elements of X in some manner to the x equivalence classes.
			
			The solution is given by the sterling number of the second kind that is shown above. As this number cannot be expressed as a mathematical equation, we provide a table with some of its values.
		"""
	)
	DocTabs.get_node("Composition").set_content(
		"""	This case is equivalent to counting sequences of n elements of X with no restriction: a function f : N → X is determined by the n images of the elements of N, which can each be independently chosen among the elements of x. This gives a total of xn possibilities.
			
			The expression with curly brackets is called the sterling number of the second kind. As this number cannot be expressed as a mathematical equation, we provide a table with some of its values.
		"""
	)


func init_menus() -> void:
	
	# MAIN
	
	# file
	FileMenu.get_popup().connect("id_pressed", self, "_pressed_mb_main", [FileMenu])
	FileMenu.get_popup().add_item("Import")
	FileMenu.get_popup().add_item("Export")
	
	# edit
	EditMenu.get_popup().connect("id_pressed", self, "_pressed_mb_main", [EditMenu])
	EditMenu.get_popup().add_item("Clear")
	
	# problem
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
	
	for i in range(g.MAX_ELEMENTS):
		#to add zero before single digits like 01, 02 instead of 1, 2
		var numberstr = "0" + str(i + 1) if i + 1 < 10 else str(i + 1)
		UnivSizeInput.get_popup().add_item(numberstr)
	
	for i in range(g.MAX_CONFIG_SIZE):
		#to add zero before single digits like 01, 02 instead of 1, 2
		var numberstr = "0" + str(i + 1) if i + 1 < 10 else str(i + 1)
		ConfigSizeInput.get_popup().add_item(numberstr)
	
	# group menu
	GroupInput.get_popup().connect("id_pressed", self, "_pressed_mb_group")
	#GroupInput.get_popup().set_item_as_checkable(GroupInput.get_popup().get_item_count()-1,true)
	GroupInput.get_popup().set_hide_on_checkable_item_selection(false)
	
	update_name_caches()


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
	Problem.init(self, g.problem)
	update_name_caches()


func _export():
	
	var file = File.new()
	var file_path = Popups.get_node("SaveFile").current_path
	if !("." in file_path):
		file_path += ".pl"
	
	file.open(file_path, File.WRITE)
	file.store_string(g.problem.to_cola())
	file.close()
	#show_message("Succesfully exported to " + str(file_path))


func _pressed_mb_group(id):
	
	var popup = GroupInput.get_popup()
	popup.toggle_item_checked(id)
	groups_selection[id] = popup.is_item_checked(id)
	
	if is_checked("New group"):
		NewGroupInput.show()
		DistInput.show()
		GroupInput.text = "New group"
	else:
		NewGroupInput.hide()
		DistInput.hide()
		GroupInput.text = "-Select Groups-"
	GroupsLabel.text = "Selected: " + get_selected_group_names_as_string()


func _pressed_mb_input(index, TypeInput):
	
	var InputMenu = TypeInput.get_popup()
	TypeInput.text = InputMenu.get_item_text(index)
	
	#if TypeInput == DistInput: config[0] = index
	if TypeInput == FuncInput: config[1] = index


func _pressed_mb_main(index, TypeInput):
	
	var selected_text = TypeInput.get_popup().get_item_text(index)
	match selected_text:
		
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
	
	#Problem.lose_focus()


func add_step(problem : g.Problem):
	
	var no_steps = len(Steps.get_children())
	
	# order matters
	if problem != g.problem:
		var new_problem = PROBLEM.instance()
		new_problem.init(self, problem)
		new_problem.name = "Problem" + str(no_steps)
		new_problem.hide()
		Problems.add_child(new_problem)
		new_problem.update()
	
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
		Problem.update()
		toggle_menu_config(false)


func check_universe() -> void:
	
	if $Popups/MenuUniverse.visible:
		
		var new_name = $Popups/MenuUniverse/VBox/Items/NameInput.text
		var new_size = UnivSizeInput.text
		if new_size == "- -":
			show_message("Please choose a size")
			return
		
		g.problem.set_universe(range(1, int(new_size) + 1), new_name)
		Universe.set_problem(g.problem, true, true)
		
		CoLaInput.text += new_name + "{[1," + str(new_size) + "]}"
		toggle_menu_universe(false)


func check_pos_constraint() -> void:
	
	if $Popups/MenuPosConstraint.visible:
		
		if DomainInput.text == "-Select Domain-":
			show_message("Please choose a domain")
			return
		var position
		if $Popups/MenuPosConstraint/VBox/Items/Position.visible:
			if $Popups/MenuPosConstraint/VBox/Items/PositionInput.text == "":
				show_message("Please specify a position")
				return
			position = int($Popups/MenuPosConstraint/VBox/Items/PositionInput.text)
			if position < 1:
				show_message("Position must be an positive integer")
				return
			if position > g.problem.get_no_vars():
				show_message("This position doesn't exist in your configuration")
				return
#			if position != OK:
#				show_message("Size must be an integer")
#				return
		else:
			position = Config.get_elements_selected()[0].get_id()
			
		
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
	Problem.init(self, g.problem)


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
	if exit_code != 0:
		return PoolStringArray()
		
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


#func get_domain_name(domain_string):
#
#	var regex = RegEx.new()
#	regex.compile("^\\w*")  #regex: ^\w*
#	var result = regex.search(domain_string)
#	if result:
#		return result.get_string()
#	return -1


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
		print("[Error] no elements selected")
		return
	
	for selected_name in get_selected_group_names():
		if selected_name == "New group":
			
			if len(g.problem.get_domains()) >= g.MAX_DOMAINS:
				show_message("There cannot be more than " + str(g.MAX_DOMAINS) + " groups")
				return
			
			var group_name: String = NewGroupInput.text
			var group_dist: bool = DistInput.pressed
			if group_name == "New group" || group_name == "":
				show_message("Please enter a group name")
				return
			
			Universe.group(group_name, group_dist)
			update_name_caches()
			
		else: Universe.group(selected_name)
	
	for id in selected_ids:
		GroupInput.get_popup().set_item_checked(id,false)
		groups_selection[id] = false
	toggle_menu_group(false)


func is_checked(group_name : String) -> bool:
	
	var checked = false
	for id in groups_selection:
		if group_name == GroupInput.get_popup().get_item_text(id):
			checked = groups_selection[id]
	return checked


func is_editable() -> bool:
	return mode == Mode.EDIT


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
		if g.problem.get_type() == "partition" || g.problem.get_type() == "composition":
			show_message(g.problem.get_type().capitalize() + "s are not yet supported by the solver")
			return
		
		create_cola_file()
		add_step(g.problem)
		# interpret coso output
		var function_steps: PoolStringArray = fetch("coso")
		for i in range(1, len(function_steps)):
			eval(function_steps[i])
		
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
	
	if mode == Mode.STEPS:
		for i in $HSplit/VBox/MainPanel/Problems.get_children():
			i.toggle_combinations()
		Problem.lose_focus()
	elif mode == Mode.EDIT:
		set_step(0)
		for I in Steps.get_children():
			I.free()
		for I in Problems.get_children():
			if I.name != "Problem0":
				I.free()
		g.problem.children = []
		g.problem.solution = 0
		Problem.toggle_combinations(false)
	
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
				Problems.get_node("Problem" + str(step)).update()


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


func toggle_docs(show : bool):
	Popups.get_node("Docs").visible = show


func toggle_main_panel(show : bool) -> void:
	
	if show:
		Problems.rect_position.y -= $HSplit/VBox/MainPanel/UI/HUD.rect_size[1] + 60

	else:
		Problems.rect_position.y += $HSplit/VBox/MainPanel/UI/HUD.rect_size[1] + 60


func toggle_menu_group(show : bool) -> void:
	
	if show:
		if !Universe.has_selected_elements():
			show_message("No elements selected to group.")
			return
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


func toggle_menu_universe(show : bool) -> void:
	
	if show:
		$Popups/MenuUniverse.popup()
	else:
		$Popups/MenuUniverse.hide()


func toggle_menu_config(show : bool) -> void:
	
	if show:
		FuncInput.text = FuncInput.get_popup().get_item_text(config[1])
		$Popups/MenuConfig.popup()
	else:
		$Popups/MenuConfig.hide()


func toggle_menu_pos_constraint(show : bool, ask_position : bool = false) -> void:
	
	var Menu = Popups.get_node("MenuPosConstraint")
	if show:
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


func toggle_menu_size_constraint(show : bool) -> void:
	
	var Menu = Popups.get_node("MenuSizeConstraint")
	if show:
		SizeDomainInput.text = "-Select Domain-"
		Menu.popup()
	else:
		Menu.hide()


func toggle_tutorial(show : bool):
	Popups.get_node("Tutorial").visible = show


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
	toggle_menu_problem_button("Group", g.problem.get_no_elements() > 0)
	toggle_menu_problem_button("Add Position Constraint", len(Config.get_elements()) != 0)
	toggle_menu_problem_button("Add Size Constraint", len(g.problem.get_domains()) > 0)


func update_name_caches():
	
	GroupInput.get_popup().clear()
	SizeDomainInput.get_popup().clear()
	
	GroupInput.get_popup().add_item("New group")
	GroupInput.get_popup().set_item_as_checkable(0, true)
	
	for i in g.problem.get_domains():
		SizeDomainInput.get_popup().add_item(i.get_name())
		GroupInput.get_popup().add_item(i.get_name())
		GroupInput.get_popup().set_item_as_checkable(
			GroupInput.get_popup().get_item_count() - 1, true)


func _change_doc_tab(idx : int):
	
	var buttons = Popups.get_node("Docs/VBox/HSplit/Index/Scroll/Buttons").get_children()
	for i in range(len(buttons)):
		if i == idx:
			buttons[i].toggle_select(true)
		else:
			buttons[i].toggle_select(false)
	
	DocTabs.current_tab = idx


func next_tut_tab() -> void:
	TutTabs.current_tab = TutTabs.current_tab + 1


func prev_tut_tab() -> void:
	TutTabs.current_tab = TutTabs.current_tab - 1
