extends Button


var is_selected = false
var problem
var number
const REFS = [
	"sequence",
	"permutation",
	"subset",
	"multisubset",
	"composition",
	"partition"
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
	set_doc_ref(REFS.find(problem.get_config().get_type()))
	


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
	
	var multiple_terms = []
	for i in problem.get_children():
		if i.solution != 0:
			multiple_terms.append(i.solution)
	var solution = str(problem.solution)
	if multiple_terms.size() >= 2:
		solution += " = " + g.chain(multiple_terms, " x ")
				
	$HBox/Text.text = tabulation + "Step {}) {}: {}".format(
		[number, solution_label, solution], "{}"
	)


func set_doc_ref(idx : int):
	
	$HBox/DocRef.text = "("+ str(REFS[idx]) + ")"
	doc_ref = idx
	$HBox/DocRef.show()
	
	
func open_doc_ref():
	
	var Main = get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
	Main.toggle_docs(true)
	Main._change_doc_tab(doc_ref)

