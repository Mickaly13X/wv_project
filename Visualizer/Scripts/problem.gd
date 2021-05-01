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
		# Don't support too large combinations
		if problem.solution > 20:
			return
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
		var solutions = get_solutions()
		#print(solutions)
		var no_elems = problem.get_no_elements()
		var no_vars = problem.get_no_vars()
		var config_type = problem.get_type()
		var flag = 0
		
		for point in distri:
			
			var new_box = g.ELEMENT.instance()
			new_box.init(null, 0, new_box.Type.BOX)
			new_box.position = point
			#new_box.size = g.ELEMENT_RADIUS * Vector2.ONE
			$Combinations/Scroll/Elements.add_child(new_box)
			var pos = 0
			for el_id in solutions[flag]:
				add_ball_to_box(el_id-1, new_box, pos)
				pos += 1
			flag += 1
	else:
		if is_shifted:
			position += 100 * Vector2.RIGHT
		for i in $Combinations/Scroll/Elements.get_children():
			remove_child(i)
			i.queue_free()


func get_ball_position(pos : int, no_elements : int) -> Vector2:
	
	var box_r = g.ELEMENT_RADIUS
	var border_width = g.ELEMENT_BORDER_WIDTH
	var positions = []
	var length = 2*box_r - border_width - box_r/5 - box_r/10
	var offset = length/no_elements # -10 for border width*2, - 2 for margin 1 px - 4 for element
	return Vector2(0, box_r - border_width - box_r/5 - box_r/5*2 - pos*offset)
	

func add_ball_to_box(ball_id : int, box, pos) -> void:
	
	var no_elems = g.problem.get_no_elements()
	var new_ball = g.ELEMENT.instance()
	new_ball.init(null, ball_id, new_ball.Type.BALL)
	new_ball.position = get_ball_position(pos, no_elems)
	new_ball.scale = 0.2 * Vector2.ONE
	new_ball.z_index = 1
	new_ball.set_color(g.ELEMENT_COLORS[ball_id])
	box.add_child(new_ball)


func get_solutions() -> Array:
	
	if problem.solution > 20:
		return []
	var solutions = []
	var no_elems = problem.get_no_elements()
	var no_vars = problem.get_no_vars()
	var config_type = problem.get_type()
	var elems = problem.get_universe().get_elements()
	
	match config_type:
		
		"sequence":
			solutions = get_sequences(no_elems, no_vars)
		
		"permutation":
			solutions = get_permutations(no_elems, no_vars)
		
		"subset":
			solutions = get_subsets(elems, no_vars)
		
		"multisubset":
			solutions = get_all_subsets(elems)
		
		_:
			pass # no support for partitions or compositions
	return solutions


func get_sequence_successor(arr, k, n):
	
	var p = k - 1
	while (arr[p] == n and 0 <= p and p < k):
		p -= 1
	
	if (p < 0):
		return 0

	arr[p] = arr[p] + 1
	var i = p + 1
	while(i < k):
		arr[i] = 1
		i += 1
	return 1


func get_sequences(n, k):
	
	var tmp = []
	var arr = []
	for i in range(k):
		arr += [0]
	
	for i in range(k):
		arr[i] = 1
	
	while(1):
		tmp.append(arr.duplicate(true))
		if(get_sequence_successor(arr, k, n) == 0):
			break
	return tmp


func get_permutations(n, k):
	
	var sequences = get_sequences(n, k)
	for i in sequences:
		if g.check_duplicates(i):
			sequences.remove(sequences.find(i))
	
	return sequences


func get_all_subsets(elems : Array):
	
	if len(elems) == 0:
		return [[]]

	var subsets = []
	var first_element = elems[0]
	var remaining_list = elems.slice(1,len(elems))
	
	for partial_subset in get_all_subsets(remaining_list):
		subsets.append(partial_subset)
		subsets.append(partial_subset.duplicate() + [first_element])

	return subsets


func get_subsets(elems : Array, size : int):
	
	var tmp = get_all_subsets(elems)
	for i in tmp:
		if len(i) != size:
			tmp.remove(tmp.find(i))
	# repeat because for some stupid reason it doesn't delete everything??
	# ex: config = 2, elems = 3
	for i in tmp:
		if len(i) != size:
			tmp.remove(tmp.find(i))
	return tmp
