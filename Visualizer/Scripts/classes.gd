class Problem:
	
	var domains: Array
	var config = g.Configuration.new()
	var elem_counter: int
	var entity_map: Dictionary
	var count_formulas: Array
	var universe = g.Domain.new("_universe")
	
	
	func _init():
		
		domains = []
		entity_map = {}
		count_formulas = []
	
	
	func add_domain(domain : Domain) -> void:
		domains.append(domain)
	
	
	func add_to_universe(element : int):
		universe.add_element(element)
	
	
	func remove_from_universe(_element : int):
		
		universe.remove_element(_element)
		for domain in domains:
			domain.remove_element(_element)

	func add_elements(no_elements : int):
		
		universe.add_elements(range(no_elements))
		elem_counter += no_elements
	
	
	func add_to_domain(domain_name, _element : int) -> void:
		
		for dom in domains:
			if dom.get_name() == domain_name:
				dom.add_element(_element)
	
	
	func check_empty_domains() -> void:
		
		var no_domains = len(get_domains())
		if no_domains > 1:
			
			var queue_delete = []
			var domains_strict = get_domains_strict()
			for i in range(no_domains):
				if Array(domains_strict[i]) == []:
					queue_delete.append(i)
			
			for i in queue_delete:
				remove_domain(i)
	
	
	func clear_domains():
		domains = []
		universe.clear()
	
	
	func get_config() -> Configuration:
		return config
	
	
	func get_domain(domain_name: String) -> Domain:
		
		for i in get_domains():
			if i.get_name() == domain_name:
				return i
		return null
	
	
	func get_domain_elements() -> Array:
		
		var domains_elements = []
		for i in get_domains():
			domains_elements.append(i.get_elements())
		return domains_elements
	
	
	# no_domains == 1, return = [A]
	# no_domains == 2, return = [A, B, AB]
	# no_domains == 3, return = [A, B, C, AB, BC, AC, ABC]
	func get_domain_intersections() -> PoolIntArray:
		
		var domain_elements = get_domain_elements()
		var intersections = []
		for i in domain_elements:
			intersections.append(i)
		
		# intersections if there are at least 2 domains
		match len(domain_elements):
			2:
				intersections.append(g.intersection(domain_elements[0], domain_elements[1]))
			3:
				intersections.append(g.intersection(domain_elements[0], domain_elements[1]))
				intersections.append(g.intersection(domain_elements[0], domain_elements[2]))
				intersections.append(g.intersection(domain_elements[1], domain_elements[2]))
				intersections.append(g.intersection(
					g.intersection(domain_elements[0], domain_elements[1]), domain_elements[2])
				)
		return intersections
	
	
	func get_domain_sizes() -> PoolIntArray:
		return g.lengths(get_domain_elements())
	
	
	func get_domains():
		return domains
	
	
	func get_domains_strict() -> Array:
	
		var domains_strict = get_domain_elements()
		var intersections = get_domain_intersections()
		for i in domains_strict:
			for j in range(len(domains), len(intersections)):
				i = g.exclude(i, intersections[j])
		return domains_strict
	
	
	func get_universe():
		return universe
	
	
	func group(elements: PoolIntArray, group_name: String) -> void:
		
		if !is_domain(group_name):
			var new_domain = g.Domain.new(group_name, elements)
			domains.append(new_domain)
		else:
			get_domain(group_name).add_elements(elements)
		
		check_empty_domains()
	
	
	func is_dist_elem(elem_id: int) -> bool:
		
		for i in get_domains():
			if elem_id in i && !i.is_distinct:
				return false
		return true
	
	
	func is_domain(group_name) -> bool:
		return get_domain(group_name) != null
	
	
	func set_config(config : Configuration) -> void:
		self.config = config
	
	
	func set_universe(size: int) -> void:
		
		g.problem.clear_domains()
		add_elements(size)
	
	
	func to_cola() -> String:
		
		var cola = ""
		for dom in domains:
			cola += dom.to_cola()
			cola += "\n"
		
		cola += config.to_cola()
		
		return cola
	
	
	func remove_domain(index : int) -> void:
		domains.remove(index)
	
	
	func reset():
		
		entity_map = {}
		count_formulas = []
		config = null
		clear_domains()
	
	
#	func _print():
#		return [universe.get_elements(), domains, configuration]


# Domain class
class Domain:

	var domain_name: String
	var elements: Array
	var is_distinct: bool

	
	func _init(_name : String, _elements = [], _is_distinct = true):
		
		domain_name = _name
		elements = _elements
		is_distinct = _is_distinct
	
	
	func clear() -> void:
		elements = Array()
	
	
	func get_name() -> String:
		return domain_name
	
	
	func set_name(_name) -> void:
		domain_name = _name
	
	
	# Get a list containing all elements
	func get_elements() -> Array:
		return elements
	
	
	func add_elements(new_elements : Array) -> void:
		elements = g.union(elements, new_elements)
	
	
	func remove_element(_element : int):
		elements.erase(_element)
		
	
	
	# Get domain size
	func get_size():
		return len(self.elements)
	

	# Translates to cola expression
	func to_cola() -> String:
		
		var tmp = str(elements).replace("[","{").replace("]","}").replace(" ","")
		if is_interval():
			tmp = get_interval().string().replace(",",":").replace(" ","")
		var cola = "{d} = {e};".format({"d" : domain_name, "e" : tmp})
		return cola
	
	
	# Returns the intersection with the specified domain
	func inter(domain : Domain) -> Domain:
		return domain
	
	
	# Returns the union with the specified domain
	func union(domain : Domain) -> Domain:
		return domain
	
	
	# Checks if this domain is an interval
	func is_interval() -> bool:
		
		Array(elements).sort()
		for i in range(len(elements)):
			if elements[i] != elements[0] + i:
				return false 
		return true
	
	
	# Return interval object
	func get_interval() -> Interval:
		
		if is_interval():
			# sorted by is_interval()
			var lo = elements[0]
			var hi = elements[-1]
			return Interval.new(lo, hi)
		return null
	
	
	func is_distinct() -> bool:
		return is_distinct


class Configuration:
	
	var size
	var config_name
	var type
	var type_string_list = []
	var domain
	
	func _init(_name = "", _size = 1, _type = "", _domain = null):
		
		config_name = _name
		size = _size
		type = _type
		domain = _domain
		
		match type:
			
			"sequence":
				
				type_string_list = ["[", "|| ", "]"]
				
			"permutation":
				
				type_string_list = ["[", "| ", "]"]
				
			"subset":
				
				type_string_list = ["{", "| ", "}"]
			
			"multisubset":
				
				type_string_list = ["{", "|| ", "}"]
			
			"partition":
				
				type_string_list = ["partitions", "(", ")"]
			
			"composition":
				
				type_string_list = ["compositions", "(", ")"]
	
	
	func set_size(_size: int):
		size = _size
	
	
	func get_size() -> int:
		return size
	
	
	func get_name():
		return config_name
	
	
	func set_name(_name : String):
		config_name = _name
	
	
	func get_type():
		return type
	
	
	func set_type(_type : String):
		type = _type
	
	
	func get_domain():
		return domain
	
	
	func set_domain(_domain : Domain):
		domain = _domain
	
	
	func to_cola() -> String:
		
		var cola = "{c} in {h0}{h1}{d}{h2};".format({"c":config_name,"d":domain, "h0":type_string_list[0], "h1":type_string_list[1], "h2":type_string_list[2]})
		cola += "\n#{c} = {s};".format({"c":config_name, "s":size})
		
		return cola


class Constraint:
	
	func _init():
		pass


class PosConstraint extends Constraint:
	
	var configuration
	var domain
	var position
	
	func _init(_config : Configuration, _position : int, _domain : Domain).():
		
		configuration = _config
		position = _position
		domain = _domain
	
	
	
	

class SizeConstraint extends Constraint:
	
	var domain
	var op
	var size
	
	func _init(_domain : Domain, _op : String, _size : int).():
		
		domain = _domain
		op = _op
		size = _size


# Class for CoLa Expressions
class CoLaExpression:
	
	var type = ""
	var global_type
	var cola_string
	
	func _init(expression : String):
		
		cola_string = expression
		
		# Comment
		if "%" in expression:
			type = "comment"
		
		#Counts
		elif "#" in expression:
			if "(" in expression:
				type = "constraint_count"
			else:
				type = "config_size"
		
		# Domain or  positionconstraint
		elif "=" in expression:
			# Domain
			if "[" in expression:
				type = "domain_interval"
			elif "{" in expression:
				type = "domain_enum"
		
		# Coniguration
		elif "in" in expression:
			
			if "[" in expression:
				
				if "||" in expression:
					type = "config_sequence"
				elif "|" in expression:
					type = "config_permutation"
					
			elif "{" in expression:
				
				if "||" in expression:
					type = "config_multisubset"
				elif "|" in expression:
					type = "config_subset"
			
			elif "partitions" in  expression:
				type = "config_partition"
			
			elif "compositions" in expression:
				type = "config_composition"
		
		global_type = type.split("_")[0] + "s"
	
	
	func get_type() -> String:
		return type
	
	
	func is_type(string : String) -> bool:
		return type == string
	
	
	func get_global_type() -> String:
		return global_type
	
	
	func is_global_type(string : String) -> bool:
		return global_type == string
	
		
	func get_string() -> String:
		return cola_string
	
	
	#translates CoLa string to func string
	func translate() -> String:
		
		var tmp = "0"
		
		match type:
			
			"comment":
				pass
			
			"domain_interval":
				
				var dist = true
				var list = cola_string.split("=")
				if "ïndist" in list[0]:
					dist = false
					list[0].replace("indist","")
					list[0].replace(" ","")
				list[1].replace(" ","")
				var _name = list[0]
				var interval_string = list[1].replace(":",",")
				tmp = "domain_interval('{n}','{s}','{d}')".format({"n" : _name, "s" : interval_string,"d" : dist})
			
			"domain_enum":
				
				tmp = "1"
			
			"config_sequence":
				
				tmp = "seq"
			
			"config_permutation":
				tmp = "perm"
			
			"config_mulitsubset":
				tmp = "msubset"
			
			"config_subset":
				tmp = "subset"
			
			"config_partition":
				tmp = "part"
				
			"config_composition":
				tmp = "composition"
			
			"config_size":
				tmp = "config_size"
			
			"constraint_count":
				tmp = "constraint_count"
				
		return tmp

# Interval class
class Interval extends IntervalString:
	
	func _init(start, end).("[{s},{e}]".format({"s" : start, "e" : end})):
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

