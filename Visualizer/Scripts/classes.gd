# Interval class
class Interval extends IntervalString:
	
	func _init(start, end).("[%s,%s]"%start%end):
		pass


# Base interval class
class IntervalString:
	
	var str_interval
	var values = []
	
	func _init(interval : String):
		
		str_interval = interval
		var tmp = interval.replace("[","").replace("]","")
		tmp = tmp.split_floats(",")
		for i in range(tmp[0],tmp[1]+1):
			values.append(i)
	
	
	# Get the string version of the interval 
	# --ex: "[0,1]"
	func string() -> String:
		return str_interval
	
	
	# Get a list of all values within the interval
	func get_values() -> Array:
		return values


# Domain class
class Domain:
	
	var domain_name
	var elements

	func _init(_name : String, _elements : Array):
		
		domain_name = _name
		elements = _elements

	
	# Get a list containing all elements
	func get_elements() -> Array:
		return elements
	
	
	# Get domain size
	func get_size():
		return len(self.elements)
	

	# Translates to cola expression
	func to_cola() -> String:
		
		var tmp = str(elements).replace("[","{").replace("]","}").replace(" ","")
		if is_interval():
			tmp = get_interval().string().replace(",",":").replace(" ","")
		var cola = "%s = %s"%domain_name%tmp
		return cola
	
	
	# Returns the intersection with the specified domain
	func inter(domain : Domain) -> Domain:
		return domain
	
	
	# Returns the union with the specified domain
	func union(domain : Domain) -> Domain:
		return domain
	
	
	# Checks if this domain is an interval
	func is_interval() -> bool:
		#UNFINISHED
		if typeof(elements) != TYPE_INT_ARRAY:# && typeof(elements) != TYPE_ARRAY:
			return false
		var hi = elements.max()
		var lo = elements.min()
		elements.sort()
		if elements == range(lo,hi+1):
			return true
		return false
	
	
	# Return interval object
	func get_interval():
		
		if is_interval():
			var hi = elements.max()
			var lo = elements.min()
			return Interval.new(lo,hi)
		return -1
