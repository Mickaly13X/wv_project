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

func set_image_index(idx : int) -> void:
	
	#$VBox/Formula.set_texture(FORMULAS[idx])
	$VBox/VBox/Formula/Image.frame = idx
	var sep = $VBox/VBox/Formula/Image.frames.get_frame("default",idx).get_height()/2 +32
	$VBox/VBox.set("custom_constants/separation", sep)
	


func set_title(title : String) -> void:
	
	self.title = title
	$VBox/Title.text = title


func set_index(idx : int) -> void:
	
	self.index = idx
	set_image_index(idx)
	set_title(TITLES[idx])
	if idx == 4 || idx == 5:
		$VBox/Table.show()
	else:
		$VBox/Table.hide()
	

func set_content(content : String) -> void:
	$VBox/Content.text = content

