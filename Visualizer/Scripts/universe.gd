extends "res://Scripts/container.gd"

const CIRCLE = preload("res://Scripts/circle.gd")
const ELEMENT = preload("res://Scenes/Element.tscn")
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
	Color(0.237456, 0.218878, 0.558594),
	
	Color(0.527344, 0.522786, 0.235667), 
	Color(0.641367, 0.497714, 0.730469), 
	Color(0.5625, 0.363865, 0.171343), 
	Color(0.09519, 0.371094, 0.325828),
	Color(0.25906, 0.075941, 0.425781), 
	Color(0.082449, 0.367188, 0.080207), 
	Color(0.402344, 0.104013, 0.15995), 
	Color(0.255135, 0.4375, 0.300726), 
	Color(0.515625, 0.322395, 0.485433), 
	Color(0.147169, 0.293623, 0.390625)]

onready var Buttons = $Menu/Buttons
var bruh = PoolVector2Array()
var broh = PoolVector2Array()
var brah = PoolVector2Array()

func _ready():
	
	shape = StyleBoxFlat.new()
	shape.bg_color = Color.transparent
	shape.set_border_width_all(3)
	shape.set_corner_radius_all(30)


func _draw():
	draw_self()
	#var bruh = Geometry.clip_polygons_2d(rect2polygon(Rect2(0, 0, 100, 100)), rect2polygon(Rect2(0, 00, 20, 20)))[0]
	#draw_colored_polygon(bruh, Color(1, 0, 0, 0.3))
	#draw_colored_polygon(broh, Color(0, 0, 1, 0.3))
	draw_colored_polygon(brah, Color(1, 0, 0, 0.5))


func _gui_input(event):
	
	if is_editable():
		if event.is_pressed():
			
			if event.button_index == BUTTON_LEFT:
				Problem.lose_focus()
			elif event.button_index == BUTTON_RIGHT:
				Problem.lose_focus(name)
				toggle_menu(true)


func _pressed(button_name : String) -> void:
	
	if is_editable():
		
		match button_name:
			
			"Add":
				var new_id = get_problem().get_free_ids(1)[0]
				get_problem().get_universe().add_elements([new_id])
				add_elements([new_id])
				update_element_positions([get_element(new_id)])
			
			"Delete":
				#TODO: popup confirmation
				var element_ids = get_element_ids(get_elements_selected())
				var needs_new_circles = delete_elements(element_ids)
				get_problem().erase_elements(element_ids)
				if needs_new_circles:
					update_circles()
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
		new_element.init(self, i)
		$Elements.add_child(new_element)
	
	update_element_colors()


# @return whether new circles need to be calculated
func delete_elements(element_ids: PoolIntArray = get_element_ids()) -> bool:
	
	var needs_new_circles = false
	for i in element_ids:
		var element = $Elements.get_node(str(i))
		if element != null:
			if get_problem().is_bound_elem(i):
				needs_new_circles = true
			element.free()
	return needs_new_circles


# @param 'domain_inter_sizes': list of (sub)set SIZES 
# @param 'smallest_size': scaling purposes
# @pre domain_intersections NOT EMPTY
# for 1-part venns, domain_inter_sizes = [A]
# for 2-part venns, domain_inter_sizes = [A, B, AB]
# for 3-part venns, domain_inter_sizes = [A, B, C, AB, BC, AC, ABC]
func fetch_venn_circles(domain_inter_sizes: Array, smallest_size: int) -> Array:
	
	var venn_circles = []
	
	if len(domain_inter_sizes) == 1: 
		venn_circles.append(CIRCLE.new(Vector2.ZERO, domain_inter_sizes[0]))
	else:
		# external fetch
		var venn_size = 2 + int(len(domain_inter_sizes) > 3)
		var arguments = [venn_size] + domain_inter_sizes
		var output: PoolStringArray = Main.fetch("venn", arguments)
		# interpret output
		for i in range(len(output) / 3):
			var center = Vector2(float(output[i*3]), float(output[i*3 + 1]))
			var radius = float(output[i*3 + 2])
			venn_circles.append(CIRCLE.new(center, radius))
	
	return fetch_venn_circles_formatted(venn_circles, smallest_size)


func fetch_venn_circles_formatted(venn_circles: Array, smallest_size: int) -> Array:
	
	var diagram_rect = $Venn.get_rect(venn_circles)
	var diagram_center = diagram_rect.position + diagram_rect.size / 2.0
	
	var dviations = []
	for i in venn_circles:
		dviations.append(i.center - diagram_center)
	
	var smallest_radius = g.lowest(venn_circles, "radius")
	
	# scaling
	var scalar = sqrt(smallest_size) * 140.0 / smallest_radius
	var venn_circles_formatted = []
	for i in range(len(venn_circles)):
		var new_center = get_center(dviations[i]  * scalar)
		var new_radius = venn_circles[i].radius * scalar
		venn_circles_formatted.append(CIRCLE.new(new_center, new_radius))
	
	return venn_circles_formatted


func get_circle(domain) -> CIRCLE:
	
	var index = get_problem().get_domains().find(domain)
	return get_circles()[index]


func get_circles() -> Array:
	return $Venn.circles


func get_domain(circle: CIRCLE):
	
	var index = get_circles().find(circle)
	return get_domains()[index]


func get_domains() -> Array:
	return get_problem().get_domains()


func get_element_ids(elements: Array = get_elements()) -> PoolIntArray:
	return PoolIntArray(g.getall_func(elements, "get_id"))


func get_perimeter() -> Rect2:
	return Rect2($Mask.rect_position, $Mask.rect_size)


func get_problem():
	return Problem.problem


func group(group_name: String, is_dist = true) -> void:
	
	var old_domain_size = get_problem().get_domain_size(group_name)
	var selected_elements = get_element_ids(get_elements_selected())
	get_problem().group(selected_elements, group_name, is_dist)
	var new_domain_size = get_problem().get_domain_size(group_name)
	
	var no_conflicts = (old_domain_size + len(selected_elements)) - new_domain_size
	if no_conflicts > 0:
		Main.show_message(
			"{} element(s) were not grouped because of conflicting distinguishabilities".format([no_conflicts], "{}")
		)
	
	# update visual elements
	update_problem(false)


func has_new_domains(new_problem) -> bool:
	
	if g.is_null(get_problem()):
		return true
	return !get_problem().equals_in_domains(new_problem)


func has_new_universe(new_problem) -> bool:
	
	if g.is_null(get_problem()):
		return true
	return !get_problem().equals_in_universe(new_problem)


func has_selected_elements() -> bool:
	
	for I in get_elements():
		if I.is_selected:
			return true
	return false


# high precision for custom exlusion function
func rect2polygon(rect: Rect2, no_points = 256) -> PoolVector2Array:
	
	var polygon = PoolVector2Array()
	# right
	for i in range(no_points / 4):
		var start = rect.position
		var step = rect.size.x / float(no_points / 4) * i
		polygon.append(start + step * Vector2.RIGHT)
	# down
	for i in range(no_points / 4):
		var start = rect.position + rect.size.x * Vector2.RIGHT
		var step = rect.size.y / float(no_points / 4) * i
		polygon.append(start + step * Vector2.DOWN)
	# left
	for i in range(no_points / 4):
		var start = rect.end
		var step = rect.size.x / float(no_points / 4) * i
		polygon.append(start + step * Vector2.LEFT)
	# up
	for i in range(no_points / 4):
		var start = rect.position + rect.size.y * Vector2.DOWN
		var step = rect.size.y / float(no_points / 4) * i
		polygon.append(start + step * Vector2.UP)
	
	return polygon


func scale_diagram() -> void:
	
	var diagram_size = $Venn.get_size()
	
	var scaling = 1
	if diagram_size.x > get_size().x && diagram_size.x != 0:
		scaling = get_size().x / float(diagram_size.x)
	if diagram_size.y > get_size().y && diagram_size.y != 0:
		scaling = min(scaling, get_size().y / float(diagram_size.y))
	
	var offset = Vector2.ZERO
	if scaling != 1:
		offset = get_size() * (1 - scaling) / (2.0)
#	print(get_size())
#	print(diagram_size)
#	print(offset)
	
	$Venn.position = offset
	$Elements.rect_position = offset
	$Venn.set_scale(scaling * Vector2.ONE)
	$Elements.set_scale(scaling * Vector2.ONE)


func set_circles_domain(venn_circles: Array, is_rebuilt = true, domains = []) -> void:
	
	$Venn.set_circles(venn_circles)
	if is_rebuilt && !venn_circles.empty():
		update_element_positions()
	
	set_domain_tags(domains)
	scale_diagram()
	Problem.update()


func set_domain_tags(domains: Array = get_domains()) -> void:
	
	for i in range(3):
		
		var DomainName = get_node("Venn/DomainName" + str(i))
		
		if i < len(domains):
			
			DomainName.text = domains[i].get_name()
			var size_constraint = domains[i].size_constraint
			if size_constraint.operator != "":
				DomainName.text += "\n(Size " + size_constraint.operator + \
								   " " + str(size_constraint.size) + ")"
			
			DomainName.rect_position = get_circles()[i].rect().position
			DomainName.show()
		else:
			DomainName.hide()


func set_elements(element_ids: PoolIntArray) -> void:
	
	delete_elements()
	add_elements(element_ids)


func set_name(custom_name : String) -> void:
	
	self.custom_name = custom_name
	if custom_name == "":
		$Label.text = "Universe"
	else:
		$Label.text = "Universe (" + custom_name + ")"


# @param 'ow_*': whether to ignore update optimizations
func set_problem(new_problem, ow_uni = false, ow_dom = false) -> void:
	
	var needs_repos = false
	if ow_uni || has_new_universe(new_problem):
		set_elements(new_problem.get_universe().get_elements())
		needs_repos = true
	
	if ow_dom || has_new_domains(new_problem):
		update_circles(new_problem, false)
		update_element_colors()
		needs_repos = true
	
	if needs_repos:
		update_element_positions()
	
	set_name(new_problem.get_universe().get_name())


func toggle_menu(is_visible : bool):
	
	$Menu.visible = is_visible
	if is_visible:
		$Menu.rect_position = get_local_mouse_position()
		var has_selected_elements = has_selected_elements()
		toggle_menu_button("Add", !(has_max_elements() || has_selected_elements))
		toggle_menu_button("Delete", has_selected_elements)
		toggle_menu_button("Group", has_selected_elements)


func toggle_menu_button(buttom_name: String, is_pressable : bool):
	Buttons.get_node(buttom_name).disabled = !is_pressable


func update_circles(problem = get_problem(), is_rebuilt = true):
	
	if problem.get_domains().empty():
		set_circles_domain([], is_rebuilt)
	else:
		set_circles_domain(
			fetch_venn_circles(
				g.lengths(problem.get_domain_intersections()),
				Array(problem.get_domain_sizes()).min()
			),
			is_rebuilt,
			problem.get_domains()
		)


func update_elements(element_ids: PoolIntArray = get_element_ids()) -> void:
	
	update_element_colors()
	update_element_positions()


func update_element_colors() -> void:
	
	var color_count = 0
	for I in get_elements():
		if get_problem().is_dist_elem(I.get_id()):
			I.set_color(ELEMENT_COLORS[color_count])
			color_count += 1
		else:
			I.set_color(Color.white)


func update_element_positions(elements = get_elements()) -> void:
	
	var assigned_positions = PoolVector2Array()
	for i in g.exclude(get_elements(), elements):
		assigned_positions.append(i.position)
	
	for Element in elements:
		
		var spawn_polygon = get_spawn_polygon(Element)
		var triangulation = Geometry.triangulate_polygon(spawn_polygon)
		var triangles = []
		for i in range(len(triangulation) / 3):
			var new_triangle = PoolVector2Array()
			new_triangle.append(spawn_polygon[triangulation[i * 3]])
			new_triangle.append(spawn_polygon[triangulation[i * 3 + 1]])
			new_triangle.append(spawn_polygon[triangulation[i * 3 + 2]])
			triangles.append(new_triangle)
		
		var triangle_areas = []
		for i in triangles:
			triangle_areas.append(
				0.5 * abs(i[0].x * (i[1].y - i[2].y) + i[1].x * (i[2].y - i[0].y) + i[2].x * (i[0].y - i[1].y))
			)
		
		var new_position: Vector2
		var flag = true
		var attempt = 1
		while flag == true:
			
			if attempt > 64:
				print ("[error] No valid position found. Defaulting to (0, 0)...")
				new_position = Vector2.ZERO
				break
			new_position = g.randomTriangle(triangles[g.choose_weighted(triangle_areas)])
			flag = false
			for i in assigned_positions:
				if new_position.distance_to(i) < 2*ELEMENT_RADIUS:
					flag = true
					break
			attempt += 1
		Element.position = new_position
		assigned_positions.append(new_position)


func get_spawn_polygon(Element: Node) -> PoolVector2Array:
	
	var inside_polygon = PoolVector2Array()
	var current_inside_union = []
	var current_inside_domains = []
	
	if Element.get_id() in get_problem().get_universe_strict():
		# account for element size
		inside_polygon = rect2polygon(Rect2(Vector2.ZERO, get_size()).grow(-ELEMENT_RADIUS))
		current_inside_union = Array(get_problem().get_universe().get_elements())
	else:
		for i in get_domains():
			if Element.get_id() in i.get_elements():
				current_inside_union = g.union_array(
					[current_inside_union, Array(i.get_elements())])
				current_inside_domains.append(i)
				# account for  element size
				var circle = get_circle(i)
				var new_polygon = CIRCLE.new(
					circle.center, circle.radius - ELEMENT_RADIUS).polygon(16)
				if inside_polygon.empty():
					inside_polygon = new_polygon
				else:
					inside_polygon = Geometry. \
						intersect_polygons_2d(inside_polygon, new_polygon)[0]
	for i in get_domains():
		if !i in current_inside_domains:
			var is_inside = (g.union_array(
				[current_inside_union, Array(i.get_elements())]
					) == current_inside_union)
				# account for  element size
			var circle = get_circle(i)
			var new_polygon = CIRCLE.new(
				circle.center, circle.radius + ELEMENT_RADIUS).polygon(16)
			inside_polygon = exclude_polygon_custom(inside_polygon, new_polygon, is_inside)
	
	return inside_polygon


func exclude_polygon_custom(
	a: PoolVector2Array, b: PoolVector2Array, is_inside = false) -> PoolVector2Array:
	
	if is_inside:
		
		if Geometry.is_polygon_clockwise(a): a.invert()
		if Geometry.is_polygon_clockwise(b): b.invert()
		var seg_a_i
		var seg_b_j
		var current_distance = -1
		for i in range(len(a) - 1):
			for j in range(len(b) - 1):
				var seg_a = [a[i], a[i + 1]]
				var seg_b = [b[j], b[j + 1]]
				var closest_pair = Geometry.get_closest_points_between_segments_2d(
					seg_a[0], seg_a[1], seg_b[0], seg_b[1]
				)
				var new_distance = closest_pair[0].distance_to(closest_pair[1])
				if new_distance < current_distance || current_distance == -1:
					current_distance = new_distance
					seg_a_i = i
					seg_b_j = j
		var new_polygon = PoolVector2Array()
		new_polygon += PoolVector2Array(Array(a).slice(0, seg_a_i))
		new_polygon += PoolVector2Array(g.reverse(Array(b).slice(0, seg_b_j)))
		new_polygon += PoolVector2Array(g.reverse(Array(b)).slice(0, len(b) - seg_b_j - 2))
		new_polygon += PoolVector2Array(Array(a).slice(seg_a_i + 1, len(a) - 1))
		return new_polygon
		
	return Geometry.clip_polygons_2d(a, b)[0]


func update_problem(ow_uni = true, ow_dom = true) -> void:
	set_problem(get_problem(), ow_uni, ow_dom)
