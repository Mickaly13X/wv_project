extends Panel

var DESCRIPTIONS = [
	"Right click to anywhere in Universe or Config to open a quick menu of options",
	"Left click on elements to select them. You can then delete these elements or group them into a new or existing set."
]

onready var IMAGES = [
	load("Textures/tut_menu.png"),
	load("Textures/tut_select.png")
]

export var index = 0


func _ready():
	set_index(index)
	#$Scroll/VBox/Table.set_custom_minimum_size(Vector2(0,$Scroll/VBox/Table/sterling_table.get_texture().get_height()/2))

func set_image_index(idx : int) -> void:
	
	$HBox/VBox/HBox/Image.set_texture(IMAGES[idx])


func set_index(idx : int) -> void:
	
	self.index = idx
	set_image_index(idx)
	set_description(DESCRIPTIONS[idx])


func set_description(content : String) -> void:
	$HBox/VBox/Description.text = content


func prev():
	var Main = get_parent().get_parent().get_parent().get_parent().get_parent()
	Main.prev_tut_tab()


func next():
	var Main = get_parent().get_parent().get_parent().get_parent().get_parent()
	Main.next_tut_tab()
