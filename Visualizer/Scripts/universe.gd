extends "res://Scripts/container.gd"


const CIRCLE_COLORS = [
	Color(0.244292, 0.300939, 0.367188, 0.33),
	Color(0.244292, 0.300939, 0.367188, 0.33),
	Color(0.244292, 0.300939, 0.367188, 0.33)]
const ELEMENT = preload("res://Scenes/Element.tscn")
const ELEMENT_SIZE = 20
const ELEMENT_COLORS = [
	Color(1, 0.406122, 0.406122), 
	Color(0.406122, 0.540673, 1), 
	Color(0.406122, 1, 0.554592), 
	Color(0.967522, 1, 0.406122),
	Color(0.675223, 0.406122, 1), 
	Color(1, 0.684503, 0.406122), 
	Color(1, 0.406122, 0.781936), 
	Color(0.406122, 0.958243, 1), 
	Color(0.558594, 0.218878, 0.218878), 
	Color(0.237456, 0.218878, 0.558594)]

onready var Buttons = $Menu/Buttons

var circles_domain = []

# element_object : Node, index : int
#var elements = {}

var is_distinct : bool
var problem


func _ready():
	
	shape = StyleBoxFlat.new()
	shape.bg_color = Color.transparent
	shape.set_border_width_all(3)
	shape.set_corner_radius_all(30)
	
	problem = g.problem


func _draw():
	
	draw_self()
	for i in range(len(circles_domain)):
		draw_circle_custom(
			circles_domain[i].radius, circles_domain[i].pos, CIRCLE_COLORS[i]
		)


func _gui_input(event):
	
	if is_editable():
		if event.is_pressed():
			
			if event.button_index == BUTTON_LEFT:
				deselect_elements()
				toggle_menu(false)
			elif event.button_index == BUTTON_RIGHT:
				deselect_elements()
				toggle_menu(true)


func _pressed(button_name : String) -> void:
	
	if is_editable():
		
		match button_name:
			
			"Add":
				var new_id = get_free_id()
				problem.universe.add_elements([new_id])
				add_elements([new_id])
				update_element_positions([get_element(new_id)])
			
			"Delete":
				#TODO: popup confirmation
				var element_ids = get_element_ids(get_elements_selected())
				problem.erase_elements(element_ids)
				delete_elements(element_ids)
				# TODO rebuilt only if venn changes
				update_elements()
			
			"Group":
				Main.toggle_menu_group(true)
			
			"SizeConstraints":
				Main.toggle_menu_size_constraint(true)
			
		$Menu.hide()


# @pre: 'element_ids' does not contain ids already present
func add_elements(element_ids: PoolIntArray) -> void:
	
	for i in element_ids:
	
		var new_element = ELEMENT.instance()
		new_element.init(self)
		new_element.set_id(i)
		$Elements.add_child(new_element)
	
	update_element_colors()


func clear_circles() -> void:
	circles_domain = []


func delete_elements(element_ids: PoolIntArray = get_element_ids()) -> void:
	
	for i in element_ids:
		var element = $Elements.get_node(str(i))
		if element != null:
			element.free()


func deselect_elements():
	
	for I in get_elements_selected():
		I.is_selected = false


func draw_circle_custom(radius: float, pos: Vector2, \
	color: Color = Color.white, maxerror = 0.25):
	
	if radius <= 0.0: return
	
	var maxpoints = 1024  # I think this is renderer limit
	var numpoints = ceil(PI / acos(1.0 - maxerror / radius))
	numpoints = clamp(numpoints, 3, maxpoints)
	var points = PoolVector2Array([])
	
	for i in numpoints:
		var phi = i * PI * 2.0 / numpoints
		var v = Vector2(sin(phi), cos(phi))
		points.push_back(v * radius + pos)
	
	draw_colored_polygon(points, color)


# @param 'domain_inter_sizes': list of (sub)set SIZES 
# @param 'smallest_size': scaling purposes
# @pre domain_intersections NOT EMPTY
# for 1-part venns, domain_intersections = [A]
# for 2-part venns, domain_intersections = [A, B, AB]
# for 3-part venns, domain_intersections = [A, B, C, AB, BC, AC, ABC]
func fetch_venn_circles(domain_inter_sizes: Array, smallest_size: int) -> Array:
	
	print(domain_inter_sizes)
	var venn_circles = []
	
	if len(domain_inter_sizes) == 1: 
		venn_circles.append([Vector2(0, 0), domain_inter_sizes[0]])
	else:
		# external fetch
		var venn_size = 2 + int(len(domain_inter_sizes) > 3)
		var arguments = [venn_size] + domain_inter_sizes
		var output: PoolStringArray = Main.fetch("venn", arguments)
		
		# convert to float[]
		for i in range(len(output) / 3):
			var pos = Vector2(float(output[i*3]), float(output[i*3 + 1]))
			var radius = float(output[i*3 + 2])
			venn_circles.append([pos, radius])
	
	return fetch_venn_circles_formatted(venn_circles, smallest_size)


# venn_circles = [pos, radius]
func fetch_venn_circles_formatted(venn_circles : Array, smallest_size: int) -> Array:
	
	var average_pos = Vector2.ZERO
	for i in venn_circles:
		average_pos += i[0]
	average_pos /= float(len(venn_circles))
	
	var dviations = []
	for i in venn_circles:
		dviations.append(i[0] - average_pos)
	
	var smallest_radius = venn_circles[0][1]
	for i in range(1, len(venn_circles)):
		if venn_circles[i][1] < smallest_radius:
			smallest_radius = venn_circles[i][1]
	
	# scaling
	var venn_circles_formatted = []
	for i in range(len(venn_circles)):
		var scalar = sqrt(smallest_size) * 140 #+ int(len(domains) == 3) * 32)
		var new_pos = get_center(dviations[i] / smallest_radius * scalar)
		var new_radius = venn_circles[i][1] / smallest_radius * scalar
		venn_circles_formatted.append([new_pos, new_radius])
	
	return venn_circles_formatted


func get_circle_approx(circle : Dictionary) -> Rect2:
	
	return Rect2(
		circle.pos - circle.radius * Vector2.ONE,
		2 * circle.radius * Vector2.ONE
	)


func get_domain_left_side(domain) -> Vector2:
	
	if domain == problem.universe:
		return $Mask.rect_size.y / 2.0 * Vector2.DOWN
	
	for i in circles_domain:
		if i.domain == domain:
			return i.pos + i.radius * Vector2.LEFT
	return Vector2.ZERO


func get_domains() -> Array:
	return problem.get_domains()


func get_element(element_id) -> Node:
	
	for I in get_elements():
		if I.get_id() == element_id:
			return I
	return null


func get_element_ids(elements: Array = get_elements()) -> PoolIntArray:
	
	var element_ids = PoolIntArray()
	for I in elements:
		element_ids.append(I.get_id())
	return element_ids


func get_elements_selected() -> Array:
	
	var elements_selected = []
	for I in get_elements():
		if I.is_selected:
			elements_selected.append(I)
	return elements_selected


func get_free_id() -> int:
	
	var count = get_elements().size()
	var _max = count + 2
	for i in range(1,_max):
		if !has_id(i):
			return i
	return 0


func get_perimeter() -> Rect2:
	return Rect2($Mask.rect_position, $Mask.rect_size)


func group(group_name : String, is_dist = true) -> void:
	
	var selected_elements = PoolIntArray()
	for i in get_element_ids(get_elements_selected()):
		selected_elements.append(i)
	problem.group(selected_elements, group_name, is_dist)
	
	# update visual elements
	update_problem(false)


func has_id(id : int):
	for el in get_elements():
		if el.name == str(id):
			return true
	return false


func has_max_elements() -> bool:
	
	if get_size() == 10:
		return true
	return false


func has_selected_elements() -> bool:
	
	for I in get_elements():
		if I.is_selected:
			return true
	return false


func is_editable() -> bool:
	return Main.is_editable()


func set_circles_domain(venn_circles: Array, domains = []) -> void:
	
	clear_circles()
	if venn_circles != []:
		for i in range(len(venn_circles)):
			
			var new_circle = {}
			new_circle.pos = venn_circles[i][0]
			new_circle.radius = venn_circles[i][1]
			new_circle.domain = domains[i]
			circles_domain.append(new_circle)
		
		update_element_positions()
	set_domain_names(domains)
	update()


func set_domain_names(domains: Array) -> void:
	
	for i in range(3):
		
		var DomainName = get_node("DomainName" + str(i))
		
		if i < len(domains):
			
			DomainName.text = domains[i].get_name()
			var size_constraint = domains[i].size_constraint
			if size_constraint.operator != "":
				DomainName.text += "\n(Size " + size_constraint.operator + \
								   " " + str(size_constraint.size) + ")"
			
			DomainName.rect_position = \
				circles_domain[i].pos - circles_domain[i].radius * Vector2.ONE
			DomainName.show()
		else:
			DomainName.hide()


func set_name(custom_name : String) -> void:
	
	self.custom_name = custom_name
	if custom_name == "":
		$Label.text = "Universe"
	else:
		$Label.text = "Universe (" + custom_name + ")"


# @param 'ow_*': whether to ignore update optimizations
func set_problem(new_problem, ow_uni = false, ow_dom = false) -> void:
	
	if ow_uni || !problem.equals_in_universe(new_problem):
		update_elements(new_problem.get_universe().get_elements())
	
	if ow_dom || !problem.equals_in_domains(new_problem):
		if new_problem.get_domains().empty():
			set_circles_domain([])
		else:
			set_circles_domain(
				fetch_venn_circles(
					g.lengths(new_problem.get_domain_intersections()),
					Array(new_problem.get_domain_sizes()).min()
				),
				new_problem.get_domains()
			)
		update_element_colors()
	
	self.problem = new_problem
	set_name(new_problem.get_universe().get_name())


func toggle_menu(is_visible : bool):
	
	$Menu.visible = is_visible
	if is_visible:
		Main.undo_menu("Config")
		$Menu.position = get_local_mouse_position()
		var has_selected_elements = has_selected_elements()
		toggle_menu_button("Add", !(has_max_elements() || has_selected_elements))
		toggle_menu_button("Delete", has_selected_elements)
		toggle_menu_button("Group", has_selected_elements)


func toggle_menu_button(buttom_name: String, is_pressable : bool):
	Buttons.get_node(buttom_name).disabled = !is_pressable


func update_element_colors() -> void:
	
	var color_count = 0
	for I in get_elements():
		if problem.is_dist_elem(I.get_id()):
			I.set_color(ELEMENT_COLORS[color_count])
			color_count += 1
		else:
			I.set_color(Color.white)


func update_elements(element_ids: PoolIntArray = get_element_ids()) -> void:
	
	delete_elements()
	add_elements(element_ids)
	update_element_positions()


func update_element_positions(elements = get_elements()) -> void:
	
	var assigned_positions = PoolVector2Array()
	for i in g.exclude(get_elements(), elements):
		assigned_positions.append(i.position)
	
	for Element in elements:
		
		var inside_circles = []
		var outside_circles = []
		
		for i in circles_domain:
			if Element.get_id() in i.domain.get_elements():
				inside_circles.append(i)
			else:
				outside_circles.append(i)
		
		var approx : Rect2
		if inside_circles == []:
			approx = get_perimeter()
		else:
			approx = get_circle_approx(inside_circles[0])
			for i in range(1, len(inside_circles)):
				# rect intersection
				approx = approx.clip(get_circle_approx(inside_circles[i]))
		
		var new_assigned_pos = Vector2.ZERO # invalid pos
		while new_assigned_pos == Vector2.ZERO:
			new_assigned_pos = update_element_positions_loop(
				approx, inside_circles, outside_circles, assigned_positions
			)
		Element.position = new_assigned_pos
		assigned_positions.append(new_assigned_pos)


# @return exit_code
func update_element_positions_loop(approx : Rect2, inside_circles : Array,
		outside_circles : Array, assigned_positions : PoolVector2Array
	) -> Vector2:
	
	var attempt = 0
	var new_pos : Vector2
	var flag = false
	while (flag == false):
		
		#print("Positioning Attempt " + str(attempt) + "...")
		flag = true
		new_pos = g.randomRect(approx.grow(-ELEMENT_SIZE))
		for i in assigned_positions:
			if new_pos.distance_to(i) < 2 * ELEMENT_SIZE:
				flag = false
				break
		# if further checking is needed
		if flag == true:
			for i in inside_circles:
				if new_pos.distance_to(i.pos) > i.radius - ELEMENT_SIZE:
					flag = false
					break
		# if further checking is needed
		if flag == true:
			for i in outside_circles:
				if new_pos.distance_to(i.pos) < i.radius + ELEMENT_SIZE:
					flag = false
					break
		
		if attempt < 32:
			attempt += 1
		else: return Vector2.ZERO
	
	return new_pos


func update_problem(ow_uni = true, ow_dom = true) -> void:
	set_problem(problem, ow_uni, ow_dom)
