extends Control


var problem


func _draw() -> void:
	
	$Config.update()
	$Universe.update()
	# pos constraints
	var constraints = problem.pos_constraints
	for i in constraints:
		var elem = $Config.get_element(int(i))
		var elem_position = $Config.rect_position + elem.position
		draw_line(
			elem_position + $Config.ELEMENT_SIZE * Vector2.RIGHT,
			$Universe.get_circle(constraints[i]).get_left() + $Universe.rect_position,
			Color.white,
			5
		)


func lose_focus(except = "") -> void:
	
	for I in get_children():
		
		if I.name != except:
			I.lose_focus()


func has_open_menu() -> bool:
	return $Config/Menu.visible || $Universe/Menu.visible


func set_self(Main, problem) -> void:
	
	# parent Node refs
	if !g.is_null(Main):
		$Config.Main = Main
		$Universe.Main = Main
	$Config.Problem = self
	$Universe.Problem = self
	
	# problem class
	self.problem = problem
	$Config.set_problem(problem)
	$Universe.set_problem(problem, true, true)
	update()
