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
	draw_colored_polygon(bruh, Color(1, 0, 0, 0.3))


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
				update_element_positions([new_id])
			
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


# @return always <= 1
func calc_scaling() -> float:
	
	var diagram_size = $Venn.get_size()
	# adjust to prevent weird polygon exclusion behavior
	diagram_size.x += 5*ELEMENT_RADIUS
	diagram_size.y += 5*ELEMENT_RADIUS
	
	var scaling = 1
	if diagram_size.x > get_size().x && diagram_size.x != 0:
		scaling = get_size().x / float(diagram_size.x)
	if diagram_size.y > get_size().y && diagram_size.y != 0:
		scaling = min(scaling, get_size().y / float(diagram_size.y))
	
	return scaling


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
			"{} element(s) were not grouped because of conflicting distinguishabilities" \
				.format([no_conflicts], "{}")
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


func rect2polygon(rect: Rect2, no_points = 12) -> PoolVector2Array:
	
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
	
	var scaling = calc_scaling()
	var offset = Vector2.ZERO
	if scaling != 1:
		offset = get_size() * (1 - scaling) / 2.0
	
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
	$Label.text = "Universe" + (" (" + custom_name + ")").repeat(int(bool(custom_name)))


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


func update_elements() -> void:
	
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

#####################################################

func update_element_positions(universe_elems = []) -> void:
	
	var venn_divisions: Array
	if universe_elems.empty():
		venn_divisions = get_venn_divisions()
	else:
		# for optimalization only universe is considered
		venn_divisions = [get_problem().get_universe_strict()]
	
	for element_ids in venn_divisions:
		
		if element_ids.empty(): continue
		
		var spawn_polygon = get_spawn_polygon(element_ids)
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
		
		var assigned_positions = PoolVector2Array()
		# optimalization
		var new_elems = element_ids
		if !universe_elems.empty():
			for i in element_ids:
				if !i in universe_elems:
					assigned_positions.append(get_element(i).position)
			new_elems = universe_elems
		
		for i in new_elems:
			
			var new_position: Vector2
			var flag = true
			var attempt = 1
			while flag == true:
				if attempt > 64:
					print ("[error] No valid position found. Defaulting to (0, 0)...")
					new_position = Vector2.ZERO
					break
				new_position = randomTriangle(triangles[g.choose_weighted(triangle_areas)])
				flag = false
				for j in assigned_positions:
					if new_position.distance_to(j) < 2*ELEMENT_RADIUS:
						flag = true
						break
				attempt += 1
			
			get_element(i).position = new_position
			assigned_positions.append(new_position)


func calc_inner_exclusion(inner_domains: Array) -> PoolVector2Array:
	
	var inner_exlusion = PoolVector2Array()
	for domain in inner_domains:
		var circle = get_circle(domain)
		# account for  element size
		var new_polygon = CIRCLE.new(
			circle.center, circle.radius + ELEMENT_RADIUS).polygon(16)
		if inner_exlusion.empty():
			inner_exlusion = new_polygon
		else:
			inner_exlusion = merge_polygons_custom(inner_exlusion, new_polygon)
	return inner_exlusion


# @pre all elements given by 'element_ids' must share a common spawn polygon
func get_spawn_polygon(venn_division_ids: PoolIntArray) -> PoolVector2Array:
	
	var inside_polygon = PoolVector2Array()
	var current_inside_elements = []
	var current_inside_domains = []
	
	var repr = venn_division_ids[0]
	if repr in get_problem().get_universe_strict():
		# account for element size
		inside_polygon = rect2polygon(
			get_container_rect(1.0 / calc_scaling()).grow(-ELEMENT_RADIUS)
		)
		inside_polygon = exclude_polygon_custom(inside_polygon, calc_inner_exclusion(get_domains()))
	else:
		for i in get_domains():
			if repr in i.get_elements():
				current_inside_domains.append(i)
				if current_inside_elements.empty():
					current_inside_elements = i.get_elements()
				else:
					current_inside_elements = g.intersection(
						current_inside_domains, i.get_elements()
					)
				# account for  element size
				var circle = get_circle(i)
				var new_polygon = CIRCLE.new(
					circle.center, circle.radius - ELEMENT_RADIUS).polygon(16)
				if inside_polygon.empty():
					inside_polygon = new_polygon
				else:
					inside_polygon = Geometry. \
						intersect_polygons_2d(inside_polygon, new_polygon)[0]
		var inner_domains = []
		for i in get_domains():
			if !i in current_inside_domains:
				if g.has_list(current_inside_elements, i.get_elements()):
					if len(inner_domains) == 1:
						if g.has_list(inner_domains[0].get_elements(), i.get_elements()):
							continue
						elif g.has_list(i.get_elements(), inner_domains[0].get_elements()):
							inner_domains = [i]
							continue
					inner_domains.append(i)
				else:
					var circle = get_circle(i)
					# account for  element size
					var new_polygon = CIRCLE.new(
						circle.center, circle.radius + ELEMENT_RADIUS).polygon(16)
					inside_polygon = exclude_polygon_custom(inside_polygon, new_polygon)
		inside_polygon = exclude_polygon_custom(inside_polygon, calc_inner_exclusion(inner_domains))
	
	return inside_polygon


func get_venn_divisions() -> Array:
	
	var no_domains = len(get_domains())
	var no_divisions = pow(2, no_domains)
	var divisions = g.repeat([[]], no_divisions)
	
	for element_id in get_problem().get_universe().get_elements():
		var count = 0
		var division_index = 0
		for domain_index in range(no_domains):
			if element_id in get_domains()[domain_index].get_elements():
				count += 1
				division_index += \
					domain_index + (1 + int(no_domains == 3)) * int(count == 2) + int(count == 3)
		if count == 0:
			division_index = -1
		divisions[division_index].append(element_id)
	
	return divisions


func exclude_polygon_custom(a: PoolVector2Array, b: PoolVector2Array) -> PoolVector2Array:
	
	var exclusion = Geometry.clip_polygons_2d(a, b)
	
	# if default polygon exclusion fails
	# custom implementation
	if len(exclusion) != 1:
		# force different orientation
		if Geometry.is_polygon_clockwise(a) == Geometry.is_polygon_clockwise(b):
			return stitch(a, g.reverse(b))
		return stitch(a, b)
		
	return exclusion[0]


func merge_polygons_custom(a: PoolVector2Array, b: PoolVector2Array) -> PoolVector2Array:
	
	var merge = Geometry.merge_polygons_2d(a, b)
	# if default polygon merge fails
	# custom implementation
	if len(merge) != 1:
		# force same orientation
		if Geometry.is_polygon_clockwise(a) != Geometry.is_polygon_clockwise(b):
			return stitch(a, g.reverse(b))
		return stitch(a, b)
		
	return merge[0]


# returns a random Vector2 point inside a given triangle
# @pre 'triangle' contains exactly 3 points
func randomTriangle(triangle: PoolVector2Array) -> Vector2:
	
	var r1 = g.randomf(1)
	var r2 = g.randomf(1)
	return (1 - sqrt(r1)) * triangle[0] \
		  + sqrt(r1) * (1 - r2) * triangle[1] \
		  + r2 * sqrt(r1) * triangle[2]


func stitch(a: PoolVector2Array, b: PoolVector2Array) -> PoolVector2Array:
	
	var a_i
	var b_j
	var shortest_distance = -1
	for i in range(len(a)):
		for j in range(len(b)):
			var new_distance = a[i].distance_to(b[j])
			if new_distance < shortest_distance || shortest_distance == -1:
				shortest_distance = new_distance
				a_i = i
				b_j = j
	var new_polygon = PoolVector2Array()
	new_polygon += PoolVector2Array(Array(a).slice(0, a_i))
	new_polygon += PoolVector2Array(Array(b).slice(b_j, len(b) - 1))
	new_polygon += PoolVector2Array(Array(b).slice(0, b_j))
	new_polygon += PoolVector2Array(Array(a).slice(a_i, len(a) - 1))
	return new_polygon

#####################################################

func update_problem(ow_uni = true, ow_dom = true) -> void:
	set_problem(get_problem(), ow_uni, ow_dom)
