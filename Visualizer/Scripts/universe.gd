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
onready var Main : Node

var circles_domain = []

# element_object : Node, index : int
#var elements = {}

var is_distinct : bool


func _ready():
	
	shape = StyleBoxFlat.new()
	shape.bg_color = Color.transparent
	shape.set_border_width_all(3)
	shape.set_corner_radius_all(30)
	
	set_name("")


func _draw():
	
	draw_self()
	for i in range(len(circles_domain)):
		draw_circle_custom(
			circles_domain[i].radius, circles_domain[i].pos, CIRCLE_COLORS[i]
		)


func _gui_input(event):
	
	if event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			deselect_elements()
			toggle_menu(false)
		elif event.button_index == BUTTON_RIGHT:
			deselect_elements()
			toggle_menu(true)


func _pressed(button_name : String) -> void:
	
	match button_name:
		
		"Add": 
			add_elements(1)
			print(g.problem._print())
		
		"Delete":
			#TODO: popup confirmation
			delete_elements(get_element_ids(get_elements_selected()))
			print(g.problem._print())
		
		"Group":
			Main.toggle_menu_group(true)
		
		"SizeConstraint":
			Main.toggle_menu_size_constraint(true)
		
	$Menu.hide()


func add_elements(no_elements : int):
	
	var counter = g.problem.get_elem_count()
	
	g.problem.add_elements(no_elements)
	
	var flag = false
	
	for i in range(no_elements):
		
		var new_element = ELEMENT.instance()
		new_element.init(self)
		
		new_element.set_id(get_new_id())
		$Elements.add_child(new_element)
		
		if no_elements == 1: 
			update_element_positions([new_element])
			flag = true
	
	update_dist()
	if flag == false:
		update_element_positions()


func clear_circles() -> void:
	circles_domain = []


func delete_elements(element_ids: PoolIntArray = get_element_ids()) -> void:
	
	g.problem.erase_elements(element_ids)
	for i in element_ids:
		var element = $Elements.get_node(str(i))
		if element != null:
			element.free()
	if !element_ids.empty():
		init(get_size(), false)


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


func draw_self():
	draw_style_box(shape, Rect2(Vector2(0, 0), $Mask.rect_size))


# @param domain_inter_sizes = list of (sub)set SIZES 
# @pre domain_intersections NOT EMPTY
# for 1-part venns, domain_intersections = [A]
# for 2-part venns, domain_intersections = [A, B, AB]
# for 3-part venns, domain_intersections = [A, B, C, AB, BC, AC, ABC]
func fetch_venn_circles(domain_inter_sizes : Array) -> Array:
	
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
	
	return fetch_venn_circles_formatted(venn_circles)


# venn_circles = [pos, radius]
func fetch_venn_circles_formatted(venn_circles : Array) -> Array:
	
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
	var smallest_domain_size = Array(g.problem.get_domain_sizes()).min()
	var venn_circles_formatted = []
	for i in range(len(venn_circles)):
		var scalar = sqrt(smallest_domain_size) * 140 #+ int(len(domains) == 3) * 32)
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
	
	if domain == g.problem.universe:
		return $Mask.rect_size.y / 2.0 * Vector2.DOWN
	
	for i in circles_domain:
		if i.domain == domain:
			return i.pos + i.radius * Vector2.LEFT
	return Vector2.ZERO


func get_domains() -> Array:
	return g.problem.get_domains()


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


func get_new_id() -> int:
	var count = get_elements().size()
	var _max = count + 2
	for i in range(1,_max):
		if !has_id(i):
			print("new id ",i)
			return i
	return 0


func get_perimeter() -> Rect2:
	return Rect2($Mask.rect_position, $Mask.rect_size)


func group(group_name : String, is_dist = true) -> void:
	
	var selected_elements = PoolIntArray()
	for i in get_element_ids(get_elements_selected()):
		selected_elements.append(i)
	
	g.problem.group(selected_elements, group_name, is_dist)	
	
	if is_dist:
		for e in get_elements_selected():
			e.set_color(ELEMENT_COLORS[int(e.name)-1])
	else:
		for e in get_elements_selected():
			e.set_color(Color(1, 1, 1))
	# update visible structure
	init(get_size(), false)


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


func init(size : int, is_rebuild = true, custom_name = get_name()) -> void:
	
	if is_rebuild:
		delete_elements()
		add_elements(size)
	
	set_name(custom_name)
	
	if get_domains().size() == 0:
		update_circles_domain([])
	else:
		update_circles_domain(
			fetch_venn_circles(g.lengths(g.problem.get_domain_intersections()))
		)


func set_name(custom_name : String) -> void:
	
	self.custom_name = custom_name
	if custom_name == "":
		$Label.text = "Universe"
		g.problem.get_universe().set_name("_universe")
	else:
		$Label.text = "Universe (" + custom_name + ")"
		g.problem.get_universe().set_name(custom_name)


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


func update_circles_domain(venn_circles : Array) -> void:
	
	clear_circles()
	if venn_circles != []:
		for i in range(len(venn_circles)):
			
			var new_circle = {}
			new_circle.pos = venn_circles[i][0]
			new_circle.radius = venn_circles[i][1]
			new_circle.domain = get_domains()[i]
			circles_domain.append(new_circle)
		
		update_element_positions()
	update_domain_names()
	update()


func update_dist() -> void:
	
	var color_counter = 0
	for i in get_elements():
		if g.problem.is_dist_elem(i.get_id()):
			i.set_color(ELEMENT_COLORS[int(i.name)-1])
			color_counter += 1
		else:
			i.set_color(Color.white)


func update_domain_names() -> void:
	
	var domains = get_domains()
	for i in range(3):
		
		var DomainName = get_node("DomainName" + str(i))
		
		if i < len(domains):
			
			DomainName.text = domains[i].get_name()
			var size_constraint = domains[i].size_constraint
			if size_constraint.operator != "":
				DomainName.text += "\n Size " + size_constraint.operator + \
								   " " + str(size_constraint.size)
			
			DomainName.rect_position = \
				circles_domain[i].pos - circles_domain[i].radius * Vector2.ONE
			DomainName.show()
		else:
			DomainName.hide()


func update_element_positions(elements = get_elements()) -> void:
	
	var assigned_positions = []
	for i in g.exclude(get_elements(), elements):
		assigned_positions.append(i.position)
	
	for element in elements:
		
		var inside_circles = []
		var outside_circles = []
		
		for i in circles_domain:
			if element.get_id() in i.domain.get_elements():
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
				element, approx, inside_circles, outside_circles, assigned_positions
			)
		assigned_positions.append(new_assigned_pos)


# @return exit_code
func update_element_positions_loop(element : Node, approx : Rect2,
	inside_circles : Array, outside_circles : Array, assigned_positions : Array
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
	
	element.position = new_pos
	assigned_positions.append(new_pos)
	return new_pos
