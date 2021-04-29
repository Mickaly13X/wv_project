extends Panel

var TITLES = [
	"n-sequence in x:",
	"n-permutation of x:",
	"n-subset of x:",
	"n-multisubset of x:",
	"composition of n with x subsets:",
	"partition of n into x subsets:"
]

onready var FORMULAS = [
	load("Textures/sequence.png"),
	load("Textures/permutation.png"),
	load("Textures/subset.png"),
	load("Textures/multisubset.png"),
	load("Textures/composition.png"),
	load("Textures/partition.png")
	
]

export var index = 0
var title


func _ready():
	set_index(index)
	$Scroll/VBox/Table.set_custom_minimum_size(Vector2(0,$Scroll/VBox/Table/sterling_table.get_texture().get_height()/2))

func set_image_index(idx : int) -> void:
	
	#$VBox/Formula.set_texture(FORMULAS[idx])
	$Scroll/VBox/Formula/Image.frame = idx
	var sep = $Scroll/VBox/Formula/Image.frames.get_frame("default",idx).get_height()/2
	$Scroll/VBox/Formula.set_custom_minimum_size(Vector2(0,sep))
	


func set_title(title : String) -> void:
	
	self.title = title
	$Scroll/VBox/Title.text = title


func set_index(idx : int) -> void:
	
	self.index = idx
	set_image_index(idx)
	set_title(TITLES[idx])
	if idx == 4 || idx == 5:
		$Scroll/VBox/Table.show()
	else:
		$Scroll/VBox/Table.hide()


func set_content(content : String) -> void:
	$Scroll/VBox/Content.text = content
