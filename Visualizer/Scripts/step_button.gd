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
	self.text = str(number) + ". " + "Solution: " + str(problem.solution)
