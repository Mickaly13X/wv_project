extends Node2D

const ELEMENT = preload("res://Scenes/Element.tscn")

onready var center_point = self.position


var element_offset = 0
var elements = []
var sname
var size
var distinguishable

func _ready():
	pass


func set_name(new_name):
	sname = new_name
	$L_Name.text = new_name


#TODO add ability to add names to elements -> adv settings
func add_element():
	
	var new_element = ELEMENT.instance()
	new_element.position = Vector2(0,element_offset)
	element_offset += 32
	elements.append(new_element)
	
	$Elements.add_child(new_element)
	

func update_element_positions():
	
	pass
