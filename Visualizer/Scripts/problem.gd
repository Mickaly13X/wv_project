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
		if problem.solution > g.MAX_COMBINATIONS:
			Main.show_message("Visualization of combinations is not support when the solution exeeds " + str(g.MAX_COMBINATIONS))
			return
		
		$Combinations/Label.text = "Combinations (" + str(problem.solution) + ")"
		is_shifted = true
		position += 160 * Vector2.LEFT
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
		remove_size_cs_conflicts(solutions)
		solutions.sort_custom(CustomSort, "sort_int_array_2d")
		var no_elems = problem.get_no_elements()
		var no_vars = problem.get_no_vars()
		var config_type = problem.get_type()
		var flag = 0
		
		if len(solutions) != problem.solution:
			Main.show_message("Oops! Something went wrong in the solver")
			return
			
		for i in range(len(distri)):
			var new_box = g.ELEMENT.instance()
			new_box.init(null, 0, new_box.Type.BOX)
			new_box.position = distri[i]
			$Combinations/Scroll/Elements.add_child(new_box)
			var pos = 0
			add_balls_to_box(solutions[i], new_box)
			flag += 1
	else:
		$Combinations/Label.text = "Combinations"
		if is_shifted:
			position += 160 * Vector2.RIGHT
			is_shifted = false
		for i in $Combinations/Scroll/Elements.get_children():
			remove_child(i)
			i.queue_free()


func remove_size_cs_conflicts(arrangements: Array) -> void:
	
	var delete = []
	for i in arrangements:
		var domain_counts = g.repeat([0], problem.get_no_domains())
		for element_id in i:
			for domain_index in problem.calc_element_domains(element_id):
				domain_counts[domain_index] += 1
		for j in range(len(domain_counts)):
			if problem.get_domains()[j].has_size_cs():
				if !domain_counts[j] in problem.get_domains()[j].get_size_cs().calc_sizes():
					delete.append(i)
		
	for i in delete:
		arrangements.erase(i)


func get_ball_position(pos : int, no_elements : int) -> Vector2:
	
	var box_r = g.ELEMENT_RADIUS
	var border_width = g.ELEMENT_BORDER_WIDTH
	var positions = []
	var length = 2*box_r - border_width - box_r/5 - box_r/10
	var offset = 10#length/no_elements # -10 for border width*2, - 2 for margin 1 px - 4 for element
	return Vector2(0, box_r - border_width - box_r/5 - box_r/5*2 - pos*offset)
	

func add_balls_to_box(ball_ids: PoolIntArray, box) -> void:
	
	for i in range(len(ball_ids)):
		
		var no_elems = g.problem.get_no_elements()
		var new_ball = g.ELEMENT.instance()
		new_ball.init(null, ball_ids[i], new_ball.Type.BALL)
		new_ball.position = get_ball_position(i, no_elems)
		new_ball.scale = 0.3 * Vector2.ONE
		new_ball.z_index = 1
		new_ball.set_color(g.ELEMENT_COLORS[ball_ids[len(ball_ids) - i - 1] - 1])
		box.add_child(new_ball)


func get_solutions() -> Array:
	
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
			solutions = get_multi_subsets(elems, no_vars)
		
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
		arr += [1]
	
	while(1):
		tmp.append(arr.duplicate(true))
		if get_sequence_successor(arr, k, n) == 0:
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
	
	var multisubsets = get_all_subsets(elems)
	var delete = []
	for i in multisubsets:
		if len(i) != size:
			delete.append(i)
	for i in delete:
		multisubsets.erase(i)
	for i in multisubsets:
		i.sort()
	return multisubsets


func get_multi_subsets(elems : Array, size : int):
	
	var tmp = get_subsets(elems, size)
	tmp = tmp + get_sequences(len(elems), size)
	var multisets = []
	for i in tmp:
		if !(i in multisets):
			multisets.append(i.duplicate())
	return multisets


class CustomSort:
	
	static func sort_int_array_2d(a, b):
		
		var sorted = false
		var i = 0
		while (i < len(a)):
			if a[i] == b[i]:
				sorted = true
			elif a[i] < b[i]:
				sorted = true
				break
			elif a[i] > b[i]:
				sorted = false
				break
			i += 1
		return sorted

