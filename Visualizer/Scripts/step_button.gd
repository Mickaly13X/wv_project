extends Button


var selected = false
var problem
var number


func init(problem : g.Problem) -> void:
	self.problem = problem
	

func set_nb(nb : int) -> void:
	self.number = nb


#func set_solution(solution : int):
#	self.solution = solution


func toggle_selected(toggle : bool) -> void:
	selected = false


func update_text() -> void:
	
	var tabulation = "\t".repeat(problem.get_level())
	self.text = "{}{}. Solution: {}".format([tabulation, number, problem.solution], "{}")
