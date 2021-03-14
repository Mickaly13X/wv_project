extends Node2D


const CIRCLE_COLORS = [
	Color(0.244292, 0.300939, 0.367188, 0.33),
	Color(0.244292, 0.300939, 0.367188, 0.33),
	Color(0.244292, 0.300939, 0.367188, 0.33)]
const ELEMENT = preload("res://Scenes/Element.tscn")
const ELEMENT_SIZE = 20
const Domain = preload("res://Scripts/classes.gd").Domain
const Interval = preload("res://Scripts/classes.gd").Interval
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

onready var Main : Node

var circles_domain = []
var custom_name
var domains : Dictionary
var is_distinct : bool
var shape


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
			toggle_menu(false)
			deselect_elements()
		elif event.button_index == BUTTON_RIGHT:
			var has_selected_elements = has_selected_elements()
			toggle_group_button(has_selected_elements)
			toggle_add_button(!(has_max_elements() || has_selected_elements))
			toggle_menu(true)


func _pressed(button_name : String) -> void:
	
	match button_name:
		
		"Add": 
			add_elements(1)
		"Group":
			Main.toggle_menu_group(true)
	
	$Menu.hide()


func add_elements(no_elements : int):
	
	var flag = false
	
	for _i in range(no_elements):
		
		var new_element = ELEMENT.instance()
		var color : Color
		if is_distinct:
			color = ELEMENT_COLORS[get_size()]
		else:
			color = Color.white
		new_element.init("uni", color)
		$Elements.add_child(new_element)
	
		if no_elements == 1: 
			update_element_positions([new_element])
			flag = true
	
	if flag == false:
		update_element_positions()


func check_empty_domains(exclude_domain : String) -> void:
	
	if len(domains) > 1:
		
		var queue_delete = []
		for i in range(len(domains)):
			if get_domains_strict()[i] == []:
				queue_delete.append(domains.values()[i])
		
		for domain in queue_delete:
			var domain_name = get_domain_name(domain)
			#if domain_name != exclude_domain:
			delete_domain(domain_name)


# @post circles rebuilt needed (invalid refs)
func delete_domain(domain_name : String) -> void:
	
	domains.erase(domain_name)
#	for i in range(len(domains)):
#		if Main.GroupInput.get_popup().get_item_text(i) == domain_name:
#			Main.GroupInput.get_popup().remove_item(i)


func deselect_elements():
	
	for I in $Elements.get_children():
		if I.selected:
			I.selected = false


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
	
	var venn_circles = []
	
	if len(domain_inter_sizes) == 1: 
		venn_circles.append([Vector2(0, 0), len(domains.keys()[0])])
	else:
		# external fetch
		var venn_size = 2 + int(len(domain_inter_sizes) > 3)
		var arguments = [venn_size] + domain_inter_sizes
		var output: Array = Main.fetch("venn", arguments)
		
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
	var smallest_domain_size = get_lengths(domains.values()).min()
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


func get_center(offset = Vector2.ZERO) -> Vector2:
	return $Mask.rect_position + $Mask.rect_size / 2 + offset


# for 1-part venns, return = [A]
# for 2-part venns, return = [A, B, AB]
# for 3-part venns, return = [A, B, C, AB, BC, AC, ABC]
func get_domain_intersections() -> Array:
	
	var _domains = domains.values()
	var domain_intersections = []
	for i in _domains:
		domain_intersections.append(i)
	
	# intersections if there are at least 2 domains
	match len(_domains):
		2:
			domain_intersections.append(g.intersection(_domains[0], _domains[1]))
		3:
			domain_intersections.append(g.intersection(_domains[0], _domains[1]))
			domain_intersections.append(g.intersection(_domains[0], _domains[2]))
			domain_intersections.append(g.intersection(_domains[1], _domains[2]))
			domain_intersections.append(
				g.intersection(g.intersection(_domains[0], _domains[1]), _domains[2])
			)
	return domain_intersections


func get_domain_name(domain : Array) -> String:
	
	for i in domains:
		if domains[i] == domain:
			return i
	return ""


func get_domains_strict() -> Array:
	
	var domains_strict = domains.values().duplicate(true)
	var intersections = get_domain_intersections()
	for i in domains_strict:
		for j in range(len(domains), len(intersections)):
			i = g.exclude(i, intersections[j])
	return domains_strict


func get_elements() -> Array:
	return $Elements.get_children()


func get_lengths(arrays : Array) -> Array:
	
	var lengths = []
	for i in arrays:
		lengths.append(len(i))
	return lengths


func get_name() -> String:
	return custom_name


func get_perimeter() -> Rect2:
	return Rect2($Mask.rect_position, $Mask.rect_size)


func get_size() -> int:
	return len(get_elements())


# @return exit_code
func group(group_name : String) -> void:
	
	var new_domain_name = ""
	if !domains.has(group_name):
		domains[group_name] = []
		var new_domain = g.Domain.new(group_name)
		g.problem.add_domain(new_domain)
		new_domain_name = group_name
	
	for I in get_elements():
		var i = 1
		var added_elements = []
		if I.selected && !domains[group_name].has(I):
			domains[group_name].append(I)
			g.problem.add_to_domain(group_name,i)
		i += 1
	
	
	
	check_empty_domains(new_domain_name)
	# update visible structure
	init(get_size(), false)


func has_max_elements() -> bool:
	
	if get_size() == 10:
		return true
	return false


func has_selected_elements() -> bool:
	
	for I in get_elements():
		if I.selected:
			return true
	return false


func init(size : int, is_rebuild = true, custom_name = get_name()) -> void:
	
	if is_rebuild:
		for I in get_elements():
			 I.free()
		add_elements(size)
	set_name(custom_name)
	
	if domains.size() > 0:
		update_circles_domain(
			fetch_venn_circles(get_lengths(get_domain_intersections()))
		)
		update_domain_names()


func init_distinct(is_distinct : bool) -> void:
	
	self.is_distinct = is_distinct
	init(get_size())


func set_name(custom_name : String) -> void:
	
	self.custom_name = custom_name
	if custom_name == "":
		$Label.text = "Universe"
	else:
		$Label.text = "Universe (" + custom_name + ")"


func toggle_menu(is_visible : bool):
	
	$Menu.visible = is_visible
	if is_visible:
		$Menu.position = get_local_mouse_position()


func toggle_add_button(is_pressable : bool):
	$Menu/Buttons/Add.disabled = !is_pressable


func toggle_group_button(is_pressable : bool):
	$Menu/Buttons/Group.disabled = !is_pressable


func update_circles_domain(venn_circles : Array) -> void:
	
	circles_domain = [] # remove existing circles
	for i in range(len(venn_circles)):
		
		var new_circle = {}
		new_circle.pos = venn_circles[i][0]
		new_circle.radius = venn_circles[i][1]
		new_circle.domain = get_domain_name(domains.values()[i])
		circles_domain.append(new_circle)
	
	update_element_positions()
	update()


func update_domain_names() -> void:
	
	for i in range(3):
		var DomainName = get_node("DomainName" + str(i))
		if i < len(domains):
			DomainName.text = circles_domain[i].domain
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
			if element in domains[i.domain]:
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
		
		print("Positioning Attempt " + str(attempt) + "...")
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
