extends Button


var selected = false
var solution
var problem


func init(problem : g.Problem):
	self.problem = problem
	
	pass


func set_text(string : String):
	self.text = string
	

