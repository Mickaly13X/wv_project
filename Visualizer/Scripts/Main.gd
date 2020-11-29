extends Node2D

var not_domains = ["structure","size","pos","count","not","inter","union","in"]


func _ready():
	var domains = get_domains(get_input())
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

#Returns a dictionary with name(of domain):value
func get_domains(input):
	var domain = {} #the dict to be returned
	var domain_strings = []
	for i in input:
		var is_domain = true
		for j in not_domains:
			if j in i or i == "":
				is_domain = false
				break
		if is_domain:
			domain_strings.append(i)
	#print(domains)
	for i in domain_strings:
		var key = get_domain_name(i)
		var value = get_domain_value(i)
		domain[key] = value
	print(domain)
	#return
func get_domain_name(domain_string):
	var regex = RegEx.new()
	regex.compile("^\\w*") #regex: ^\w*
	var result = regex.search(domain_string)
	if result:
		return result.get_string()
	return -1

#Only works for intervals for now
func get_domain_value(domain_string):
	var regex = RegEx.new()
	regex.compile("\\[.*\\]") #regex: [.*]
	var result = regex.search(domain_string)
	if result:
		var values
	#	var val = result.get_string()
	#	var regex2 = RegEx.new()
	#	regex2.compile("\\(\\[.*\\]\\)") #regex: ([.*])
	#	var result2 = regex2.search(val)
		var val = result.get_string()
		values = val.replace("[","").replace("]","").replace(" ","").split(",")
		return range(int(values[0]),int(values[1])+1)
	return -1








