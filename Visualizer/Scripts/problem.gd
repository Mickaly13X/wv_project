extends Node2D


const ELEMENT_OFFSET = 24

var is_shifted = false
var problem

onready var Main: Node


func _draw() -> void:
	
	# pos constraints
	$Universe/Venn.update()
	var constraints = problem.pos_constraints
	for i in constraints:
		
		var elem = $Config.get_element(int(i))
		var elem_position = $Config.rect_position + elem.position
		
		var line_start = elem_position + g.ELEMENT_RADIUS * Vector2.RIGHT
		
		var line_end = $Universe.rect_position \
			+ $Universe.get_size().y / 2.0 * Vector2.DOWN
		if constraints[i] != problem.get_universe():
			var circle_pos_scaled = $Universe.get_circle(constraints[i]).left() * $Universe/Venn.scale
			line_end = circle_pos_scaled + $Universe/Venn.global_position
		line_end -= global_position
		
		draw_line(line_start, line_end, Color.white, 5)


func calc_v_distri(origin: Vector2, no_elements: int, center = true) -> PoolVector2Array:
	
	if center == true:
		var column_size = min(no_elements, 9)
		var total_length = (column_size - 1) * (2*g.ELEMENT_RADIUS + ELEMENT_OFFSET)
		origin += (total_length / 2.0) * Vector2.UP
	var points = PoolVector2Array()
	for i in range(no_elements):
		points.append(origin + (2*g.ELEMENT_RADIUS + ELEMENT_OFFSET) * i * Vector2.DOWN)
	return points


func lose_focus(except = "") -> void:
	
	for I in [$Config, $Universe]:
		
		if I.name != except:
			I.lose_focus()


func has_open_menu() -> bool:
	return $Config/Menu.visible || $Universe/Menu.visible


func init(Main, problem) -> void:
	
	# parent Node refs
	if !g.is_null(Main):
		self.Main = Main
		$Config.Main = Main
		$Universe.Main = Main
	$Config.Problem = self
	$Universe.Problem = self
	
	# problem class
	self.problem = problem
	$Config.set_problem(problem)
	$Universe.set_problem(problem, true, true)
	update()


func toggle_combinations(show = problem.get_children().empty()) -> void:
	
	$Combinations.visible = show
	if show:
		is_shifted = true
		position += 100 * Vector2.LEFT
		var distri: PoolVector2Array
		if problem.solution < 10:
			distri = calc_v_distri($Combinations.get_center(), problem.solution)
		else:
			distri = calc_v_distri(
				$Combinations.get_center() + 250 * Vector2.UP, problem.solution, false
			)
			$Combinations/Scroll/Elements.set_custom_minimum_size(
				Vector2($Combinations/Scroll.rect_min_size.x, distri[0].distance_to(distri[-1]) + 20)
			)
		for point in distri:
			
			var new_box = g.ELEMENT.instance()
			new_box.init(null, 0, new_box.Type.BOX)
			new_box.position = point
			#new_box.size = g.ELEMENT_RADIUS * Vector2.ONE
			$Combinations/Scroll/Elements.add_child(new_box)
			
			for j in range(1):
				var new_ball = g.ELEMENT.instance()
				new_ball.init(null, 0, new_ball.Type.BALL)
				#new_ball.position = Vector2.ZERO
				new_ball.scale = 0.2 * Vector2.ONE
				new_ball.z_index = 1
				new_box.add_child(new_ball)
	else:
		if is_shifted:
			position += 100 * Vector2.RIGHT
		for i in $Combinations/Scroll/Elements.get_children():
			remove_child(i)
			i.queue_free()
