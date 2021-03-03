extends Node2D

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
	Color(0.237456, 0.218878, 0.558594)]

onready var Main : Node

var circles_domain = []
var custom_name = ""
var domains : Dictionary
var element_size = Vector2(16, 16)
var is_distinct : bool
var shape


func _ready():
	
	shape = StyleBoxFlat.new()
	shape.bg_color = Color.transparent
	shape.set_border_width_all(3)
	shape.set_corner_radius_all(30)
	
	$Label.text = name


func _draw():
	
	draw_self()
	for i in circles_domain:
		draw_circle_custom(i.radius, i.pos, Color.white)


func _on_gui_input(event):
	
	if event.is_pressed() and event.button_index == BUTTON_LEFT:
		toggle_menu(false)
		deselect_elements()
	if event.is_pressed() and event.button_index == BUTTON_RIGHT:
		toggle_group_button(has_selected_elements())
		toggle_add_button(has_max_elements())
		toggle_menu(true)


func _pressed(button_name : String) -> void:
	
	match button_name:
		
		"Add": 
			add_element()
		"Group":
			Main.toggle_menu_group(true)
	
	$Menu.hide()


#TODO add ability to add names to elements -> adv settings
func add_element(approx : Rect2 = get_boundary(), pos_constraints = []):
	
	var new_pos = approx.position + element_size + \
			g.randomVect(approx.size - element_size * 2)
	while(is_element_at_pos(new_pos)):
		new_pos = approx.position + element_size + \
			g.randomVect(approx.size - element_size * 2)

	var new_element = ELEMENT.instance()
	new_element.uni_name = name
	new_element.position = new_pos
	if is_distinct:
		new_element.set_color(ELEMENT_COLORS[get_size()])
		#	Color(0.33 * (i%3), 0.33 * ((i/3)%3), 0.33 * ((i/9)%3))
	else:
		new_element.set_color(Color.white)
	$Elements.add_child(new_element)


func deselect_elements():
	
	for I in $Elements.get_children():
		if I.selected:
			I.selected = false


func draw_self():
	draw_style_box(shape, Rect2(Vector2(0, 0), $Mask.rect_size))


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


func fetch_venn_circles(domain_intersections : Array) -> Array:
	
	if len(domain_intersections) == 1: return [get_center(), 1]
	
	# external fetch
	var venn_size = 2 + int(len(domain_intersections) > 3)
	var args = ["fetch.py", str(venn_size)]
	for i in domain_intersections:
		args.append(str(i))
	var output = []
	var exit_code = OS.execute("python", args, true, output)
	print("exit_code " + str(exit_code))
	output = str(output[0]).split("\n")
	
	# formatting
	var venn_circles = []
	for i in range(len(output) / 3):
		venn_circles.append([Vector2(output[i*3], output[i*3 + 1]), \
							 output[i*3 + 2]])
	return venn_circles


func get_boundary() -> Rect2:
	return Rect2($Mask.rect_position, $Mask.rect_size)


func get_center() -> Vector2:
	return $Mask.rect_position + $Mask.rect_size / 2


# returns a list of all domain and intersection sizes
# for 1-part venns, return = [A]
# for 2-part venns, return = [A, B, AB]
# for 3-part venns, return = [A, B, C, AB, BC, AC, ABC]
func get_domain_intersections(domains : Array) -> Array:
	
	var domain_intersections = []
	for i in domains:
		domain_intersections.append(len(i))
	
	# intersections if there are at least 2 domains
	match len(domains):
		2:
			domain_intersections.append(len( \
				g.intersection(domains[0], domains[1])))
		3:
			domain_intersections.append(len( \
				g.intersection(domains[0], domains[1])))
			domain_intersections.append(len( \
				g.intersection(domains[0], domains[2])))
			domain_intersections.append(len( \
				g.intersection(domains[1], domains[2])))
			domain_intersections.append(len( \
				g.intersection(g.intersection(domains[0], domains[1]), domains[2])))
	
	return domain_intersections


func get_name() -> String:
	return custom_name


func get_size() -> int:
	return len($Elements.get_children())


# @return exit_code
func group(group_name : String) -> bool:
	
	if domains.has(group_name): return false
	
	domains[group_name] = []
	for i in $Elements.get_children():
		if i.selected == true:
			domains[group_name].append(i)
	return true


func has_max_elements() -> bool:
	
	if get_size() == 10:
		return true
	return false


func has_selected_elements() -> bool:
	
	for I in $Elements.get_children():
		if I.selected:
			return true
	return false


func init(size : int, custom_name = get_name()) -> void:
	
	for I in $Elements.get_children():
		 I.free()
	
	set_name(custom_name)
	set_size(size)
	print(domains)
	if domains.size() > 1:
		print("lol")
		set_circles_domain(fetch_venn_circles(get_domain_intersections(domains.values())))


func init_distinct(is_distinct : bool) -> void:
	
	self.is_distinct = is_distinct
	init(get_size())


func is_element_at_pos(pos : Vector2) -> bool:
	
	for I in $Elements.get_children():
		if pos.distance_to(I.position) <= element_size[0] * 2:
			return true
	return false


func set_circles_domain(venn_circles : Array) -> void:
	
	for i in venn_circles:
		
		var new_circle = {}
		new_circle.pos = i[0]
		new_circle.radius = i[1] * 100
		circles_domain.append(new_circle)
	
	print(circles_domain)
	update()

func set_name(custom_name : String = get_name()) -> void:
	
	if custom_name == "": $Label.text = name
	else: $Label.text = name + " (" + custom_name + ")"


func set_size(size : int) -> void:
	
	for _i in range(size):
		add_element()


func toggle_menu(is_visible : bool):
	
	$Menu.visible = is_visible
	if is_visible:
		$Menu.position = get_local_mouse_position()


func toggle_add_button(is_visible : bool):
	$Menu/Buttons/Add.disabled = is_visible


func toggle_group_button(is_visible : bool):
	$Menu/Buttons/Group.disabled = is_visible


func update_domains() -> void:
	init(get_size())
