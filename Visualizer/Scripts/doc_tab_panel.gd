extends Panel

var TITLES = [
	"n-sequence in x:",
	"n-permutation of x:",
	"n-subset of x:",
	"n-multisubset of x:",
	"composition of n with x subsets:",
	"partition of n into x subsets:"
]

export var index = 0
var title


func _ready():
	set_image_index(index)
	set_title(TITLES[index])

func set_image_index(idx : int) -> void:
	
	$VBox/Formula/Image.frame = idx


func set_title(title : String) -> void:
	
	self.title = title
	$VBox/Title.text = title


func set_index(idx : int) -> void:
	
	self.index = idx
	set_image_index(idx)
	set_title(TITLES[idx])
	

func set_content(content : String) -> void:
	$VBox/Content.text = content

