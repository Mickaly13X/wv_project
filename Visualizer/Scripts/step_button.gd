extends Button


var is_selected = false
var problem
var number
const REFS = [
	"(sequence)",
	"(permutation)",
	"(subset)",
	"(multisubset)"
]
var doc_ref


func _press():
	
	var Main = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	Main.set_step(Main.get_step(problem))


func init(problem, number: int, is_selected: bool) -> void:
	
	self.problem = problem
	set_number(number)
	toggle_selected(is_selected)
	update_text()
	set_doc_ref(1)


func set_number(nb : int) -> void:
	self.number = nb


func toggle_selected(is_selected: bool) -> void:
	
	self.is_selected = is_selected
	var font_color = Color.white
	if is_selected:
		 font_color = Color.yellow
	set("custom_colors/font_color", font_color)


func update_text() -> void:
	
	var tabulation = "         ".repeat(2 + problem.get_level())
	var solution_label = "solution"
	if problem == g.problem:
		solution_label = "Total solution"
	$HBox/Text.text = tabulation + "Step {}) {}: {}".format(
		[number, solution_label, problem.solution], "{}"
	)


func set_doc_ref(idx : int):
	
	$HBox/DocRef.text = REFS[idx]
	doc_ref = idx
	$HBox/DocRef.show()
	
	
func open_doc_ref():
	
	var Main = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	Main.toggle_docs(true)
	Main._change_doc_tab(doc_ref)

