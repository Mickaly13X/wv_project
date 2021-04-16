extends Button


var is_selected = false
var problem
var number


func _press():
	
	var Main = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	Main.set_step(Main.get_step(problem))


func init(problem : g.Problem) -> void:
	self.problem = problem
	

func set_nb(nb : int) -> void:
	self.number = nb


func toggle_selected(is_selected: bool) -> void:
	
	self.is_selected = is_selected
	var font_color = Color.white
	if is_selected:
		 font_color = Color.yellow
	set("custom_colors/font_color", font_color)


func update_text() -> void:
	
	var tabulation = "       ".repeat(3 + problem.get_level())
	var solution_label = "solution"
	if problem == g.problem:
		solution_label = "Total solution"
	self.text = tabulation + "Step {}) {}: {}".format(
		[number, solution_label, problem.solution], "{}"
	)
