# Interval class
class Interval:
	
	var values = []
	var str_interval
	
	func _init(start, end):
		for i in range(start, end+1):
			self.values.append(i)
		self.str_interval = "[%s,%s]"%start%end
	
	func list():
		return self.values
	
	
	func string():
		return self.str_interval


# Class domain.gd
class Domain:
	
	var domain_name
	var interval

	func _init(_name : String, _interval : Interval):
		self.domain_name = _name
		self.interval = _interval


	func get_elements():
		return self.interval.list()
	
	
	func get_size():
		return len(self.elements)
	

	# Translates to cola definition
	func to_cola():
		var cola = "%s = %s"%domain_name%interval.string()
		return cola
	
	
	func inter(domain : Domain):
		pass
