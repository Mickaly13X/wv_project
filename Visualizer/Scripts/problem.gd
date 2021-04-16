extends Node2D


var problem


func _draw() -> void:
	
	$Config.update()
	$Universe.update()
	var constraints = problem.pos_constraints
	#var x_rel = (Universe.position.x - position.x) * Vector2.RIGHT
	for i in constraints:
		var elem = $Config.get_element(int(i))
		draw_line(elem.global_position + $Config.ELEMENT_SIZE * Vector2.RIGHT,
				  $Universe.get_domain_left_side(constraints[i]) + $Universe.position,
				  Color.white, 5)


func close_menus(except: String) -> void:
	
	for I in get_children():
		
		if I.name != except:
			I.deselect_elements()
			I.toggle_menu(false)


func set_self(problem, Main: Node = null) -> void:
	
	if !g.is_null(Main):
		$Config.Main = Main
		$Universe.Main = Main
	$Config.Problem = self
	$Universe.Problem = self
	
	self.problem = problem
	$Config.set_problem(problem)
	$Universe.set_problem(problem, true, true)
	update()
