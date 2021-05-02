extends Panel

var DESCRIPTIONS = [
	"Right click anywhere in Universe or Config to open a quick menu of options",
	"Left click on elements to select them. You can then delete these elements or group them into a new or existing set.",
	"When you're done constructing a problem, click 'Run' to run the solver and see the solving steps.",
	"By clicking on basic solving steps, you can see all the arrangements that were considered for the solution."
]

onready var IMAGES = [
	load("Textures/tut_menu.png"),
	load("Textures/tut_select.png"),
	load("Textures/tut_run.png"),
	load("Textures/tut_combinations.png")
]

export var index = 0

onready var PrevButton = $HBox/PrevButton/Image
onready var NextButton = $HBox/NextButton/Image

func _ready():
	
	set_index(index)
	#$Scroll/VBox/Table.set_custom_minimum_size(Vector2(0,$Scroll/VBox/Table/sterling_table.get_texture().get_height()/2))

func set_image_index(idx : int) -> void:
	
	$HBox/VBox/HBox/Image.set_texture(IMAGES[idx])


func set_index(idx : int) -> void:
	
	self.index = idx
	set_image_index(idx)
	set_description(DESCRIPTIONS[idx])
	if idx == 0:
		toggle_prev_button(true)
	if idx == 3:
		toggle_next_button(true)

func set_description(content : String) -> void:
	
	$HBox/VBox/Description.text = content


func prev():
	
	var Main = get_parent().get_parent().get_parent().get_parent().get_parent()
	Main.prev_tut_tab()


func next():
	
	var Main = get_parent().get_parent().get_parent().get_parent().get_parent()
	Main.next_tut_tab()


func toggle_prev_button(disable : bool):
	
	PrevButton.disabled = disable


func toggle_next_button(disable : bool):
	
	NextButton.disabled = disable
