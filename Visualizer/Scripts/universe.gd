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

var circles = []
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
	
	_draw_self()
	
	for i in range(len(circles)):
		_draw_circle_custom(circles[i].radius, circles[i].pos, Color.white)


func _draw_self():
	draw_style_box(shape, Rect2(Vector2(0, 0), $Mask.rect_size))


func _draw_circle_custom(radius: float, pos: Vector2, \
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


func _pressed(button_name : String) -> void:
	
	match button_name:
		
		"Add": 
			add_element()
		
		"Group":
			var MenuGroup = get_parent().get_parent().get_parent().get_parent().get_node("Popups").get_node("MenuGroup")
			MenuGroup.popup()
			
	
	$Menu.hide()


func _pressed_global() -> void:
	
	$Menu.position = get_local_mouse_position()
	$Menu.show()


#TODO add ability to add names to elements -> adv settings
func add_element(approx : Rect2 = get_boundry(), pos_constraints = []):
	
	var new_pos = approx.position + element_size + \
		g.randomVect(approx.size - element_size)

	var new_element = ELEMENT.instance()
	new_element.uni_name = name
	new_element.position = new_pos
	if is_distinct:
		new_element.set_color(ELEMENT_COLORS[get_size()])
		#	Color(0.33 * (i%3), 0.33 * ((i/3)%3), 0.33 * ((i/9)%3))
	else:
		new_element.set_color(Color.white)
	$Elements.add_child(new_element)


func init(size : int, custom_name = get_name()) -> void:
	
	for I in $Elements.get_children():
		 I.queue_free()
	
	set_name(custom_name)
	call_deferred("set_size", size)
	#set_diagram(get_venn_areas(domains.values()))


func init_distinct(is_distinct : bool) -> void:
	
	self.is_distinct = is_distinct
	init(get_size())


func get_boundry() -> Rect2:
	return Rect2($Mask.rect_position, $Mask.rect_size)


func get_name() -> String:
	
	return custom_name


func get_size() -> int:
	return len($Elements.get_children())

# for 2-part venns, use 'venn_areas' = [A, B, AB]
# for 3-part venns, use 'venn_areas' = [A, B, C, AB, BC, AC, ABC]
#func set_diagram(venn_areas: Array) -> void:
#
#	var venn_size = 2 + int(len(venn_areas) > 3)
#	var args = ["fetch.py", str(venn_size)]
#	for i in venn_areas:
#		args.append(str(i))
#	var output = []
#	var exit_code = OS.execute("python", args, true, output)
#	output = str(output[0]).split("\n")
#
#	for i in range(venn_size):
#		var new_diagram = {}
#		new_diagram.pos = (
#			(Vector2(float(output[2 * i]), float(output[2 * i + 1]))) * 100
#			+ Vector2(ROOM_W, ROOM_H) / 2
#		)
#		new_diagram.radius = float(output[venn_size * 2 + i]) * 100
#		circles.append(new_diagram)
#
#	print("exit_code " + str(exit_code))

func set_name(custom_name : String = get_name()) -> void:
	
	if custom_name == "": $Label.text = name
	else: $Label.text = name + " (" + custom_name + ")"


func set_size(size : int) -> void:
	
	print(get_size())
	for _i in range(size):
		add_element()
