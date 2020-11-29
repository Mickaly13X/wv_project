extends Node2D

func _ready():
	get_domains(get_input())
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_input():
	var file = File.new()
	file.open("res://tests/paper/constrained/permutation_5_4.test", File.READ)
	var content = file.get_as_text()
	file.close()
	return content.replace("\n","").split(".")
	
func get_ouput():
	#TODO
	pass


func get_domains(input):
	var regex = RegEx.new()
	regex.compile(".*\\(\\[.*\\]\\)") #Finds anything with .*([.*])
	for i in input:
		var result = regex.search(str(i))
		if result:
			print(result.get_string())
	pass
