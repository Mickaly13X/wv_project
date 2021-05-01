class Problem:
	
	
	const MAX_DOMAINS = 3
	const MIN_ELEM_ID = 1
	
	var children = Array()
	var config # static typing gives error
	var domains: Array
	var elem_map: Dictionary # used during import
	var parent: Problem
	var pos_constraints: Dictionary
	var solution: int
	var universe # static typing gives error
	
	
	func _init(type = "sequence", vars = [], pos_cs = [], size_cs = []):
		
		config = g.Configuration.new(type, len(vars))
		config.problem = self
		universe = g.Domain.new()
		universe.problem = self
		
		# Vars
		for domain_elements in vars:
			var domain = g.Domain.new("domain" + str(vars.find(domain_elements)), domain_elements)
			add_domain(domain)
		
		# Pos constraints with domain name from elems
		for i in pos_cs:
			var position = i[0]
			var domain_name = get_domain_name_from_elements(i[1])
			add_pos_constraint(position, domain_name)
		
		# Size constraint is an Array of size constraints repr as a list containing domain elements and a list of possible sizes
		for i in size_cs:
			var domain_elements = i[0]
			var sizes = i[1]
			set_size_constraint_array(get_domain_name_from_elements(domain_elements), sizes)
	
	
	func get_children() -> Array:
		return children
	
	
	func add_child(child: Problem) -> void:
		
		children.append(child)
		child.parent = self
	
	
	func set_parent(parent: Problem) -> void:
		self.parent = parent
	
	
	func add_domain(domain: Domain) -> void:
		
		if len(domains) >= MAX_DOMAINS:
			print("[Error] cannot add more than 3 domains")
			return
		for i in get_domains():
			if i.get_elements() == domain.get_elements():
				remove_domain(i)
		
		domain.set_problem(self)
		domains.append(domain)
		universe.set_elements(PoolIntArray(
			g.union(Array(universe.get_elements()), Array(domain.get_elements()))
		))
	
	
	func add_pos_constraint(pos: int, domain_name: String) -> void:
		
		var domain = get_domain(domain_name)
		if g.is_null(domain):
			print("[Error] '{}' is not a valid domain".format([domain_name], "{}"))
			return
		pos_constraints[pos] = domain
	
	
	func add_to_domain(domain: Domain, element_ids: PoolIntArray) -> void:
		
		domain.add_elements(element_ids)
		universe.elements = PoolIntArray(
			g.union(Array(universe.elements), Array(domain.elements))
		)
	
	
	func add_strlist_to_domain(domain: Domain, elem_names: PoolStringArray) -> void:
		
		if domain in domains:
			
			var elem_ids = PoolIntArray()
			var new_elem_names = PoolStringArray()
			for i in elem_names:
				if i.is_valid_integer():
					elem_ids.append(int(i))
				elif i in elem_map:
					elem_ids.append(elem_map[i])
				else:
					new_elem_names.append(i)
			
			var new_elem_ids = get_free_ids(len(new_elem_names))
			for i in range(len(new_elem_names)):
				elem_map[new_elem_names[i]] = new_elem_ids[i]
			add_to_domain(domain, elem_ids + new_elem_ids)
	
	
	func check_empty_domains() -> void:
	
		for i in domains:
			if i.get_elements().empty():
				remove_domain(domains.find(i))
	
	
	func clear_domains() -> void:
		
		domains = []
		universe.clear()
	
	
	func equals_in_domains(other: Problem) -> bool:
		
		var domain_elements_self = get_domain_elements()
		var domain_elements_other = other.get_domain_elements()
		if len(domain_elements_self) != len(domain_elements_other):
			return false
		for i in range(len(domain_elements_self)):
			if domain_elements_self[i] != domain_elements_other[i]:
				return false
		return true
	
	
	func equals_in_universe(other: Problem) -> bool:
		return get_universe().get_elements() == other.get_universe().get_elements()
	
	
	func erase_elements(elements_ids : PoolIntArray):
		
		universe.erase_elements(elements_ids)
		for domain in get_domains():
			domain.erase_elements(elements_ids)
		check_empty_domains()
	
	
	func get_config() -> Configuration:
		return config
	
	
	func get_domain(domain_name: String) -> Domain:
		
		if domain_name == "":
			return universe
		for i in get_domains():
			if i.get_name() == domain_name:
				return i
		return null
	
	
	func get_domain_elements() -> Array:
		return g.getall_func(get_domains(), "get_elements")
	
	
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
				intersections.append(g.intersection(domain_elements[1], domain_elements[2]))
				intersections.append(g.intersection(domain_elements[0], domain_elements[2]))
				intersections.append(g.intersection(
					g.intersection(domain_elements[0], domain_elements[1]), domain_elements[2])
				)
		return intersections
	
	
	func get_domain_name_from_elements(elements : Array) -> String:
		
		for domain in domains:
			if elements.sort() == Array(domain.get_elements()).sort():
				return domain.get_name()
		return ""
	
	
	func get_domain_size(domain_name: String) -> int:
		
		var domain = get_domain(domain_name)
		if g.is_null(domain):
			return 0
		return len(domain.get_elements())
	
	
	func get_domain_sizes() -> PoolIntArray:
		return g.lengths(get_domain_elements())
	
	
	func get_domains() -> Array:
		return domains
	
	
	# @return [intersecting domains, enclosed domains]
#	func get_domains_attached(to_domain: Domain) -> Array:
#
#		var intersecting_domains = []
#		var enclosed_domains = []
#		for i in get_domains():
#			if i != to_domain:
#				if g.has_list(to_domain.get_elements(), i.get_elements()):
#					for j in enclosed_domains:
#						if g.has_list(i.get_elements(), j.get_elements()):
#							break
#						elif g.has_list(j.get_elements(), i.get_elements()):
#							i = j
#							break
#				elif !g.intersection(to_domain.get_elements(), i).empty():
#					intersecting_domains.append(i)
#		return [intersecting_domains, enclosed_domains]
	
	
	func get_domains_strict() -> Array:
	
		var domains_strict = get_domain_elements()
		var intersections = get_domain_intersections()
		for i in domains_strict:
			for j in range(len(domains), len(intersections)):
				i = g.exclude(i, intersections[j])
		return domains_strict
	
	
	# returns a number of element id that are not in use
	func get_free_ids(no_ids: int) -> PoolIntArray:
		
		var free_ids = PoolIntArray()
		var current_id = MIN_ELEM_ID
		while (len(free_ids) < no_ids):
			if !current_id in universe.get_elements():
				free_ids.append(current_id)
			current_id += 1
		return free_ids
	
	
	func get_level() -> int:
		
		var level = 0
		var current_problem = self
		while (current_problem.parent != null):
			current_problem = current_problem.parent
			level += 1
		return level
	
	
	func get_no_domains() -> int:
		return len(domains)
	
	
	func get_no_elements() -> int:
		return universe.get_size()
	
	
	func get_no_vars() -> int:
		return config.get_size()
	
	
	func get_type() -> String:
		return config.type
	
	
	func get_universe():
		return universe
	
	
	func get_universe_strict() -> PoolIntArray:
		
		return PoolIntArray(
			g.exclude_list(universe.get_elements(), get_domain_elements())
		)
	
	
	func get_parent() -> Problem:
		return parent
	
	
	func get_relevant_domains() -> Array:
		
		if domains.empty():
			return [universe]
		if g.union_list(get_domain_elements()).size() == universe.get_size():
			return get_domains()
		return get_domains() + [universe]
	
	
	func get_universe_formula() -> String:
		
		var relevant_domains = get_relevant_domains()
		var universe_formula = relevant_domains[0].get_name_cola()
		for i in range(1, len(relevant_domains)):
			universe_formula += "+" + relevant_domains[i].get_name_cola()
		return universe_formula
	
	
	func get_vars() -> Array:
		
		var vars = Array()
		for i in range(config.size):
			if i in pos_constraints:
				vars.append(pos_constraints[i])
			else:
				vars.append(universe)
		return vars
	
	
	func group(elements: PoolIntArray, group_name: String, is_dist: bool) -> void:
		
		var elements_filtered = Array(elements)
		if !is_domain(group_name):
			for i in elements_filtered:
				if is_bound_elem(i):
					if is_dist_elem(i) != is_dist:
						elements_filtered.erase(i)
			elements_filtered = PoolIntArray(elements_filtered)
			if !elements_filtered.empty():
				var new_domain = g.Domain.new(group_name, elements_filtered, is_dist)
				add_domain(new_domain)
		else:
			var domain = get_domain(group_name)
			for i in elements_filtered:
				if is_bound_elem(i):
					if is_dist_elem(i) != domain.is_distinct:
						elements_filtered.erase(i)
			elements_filtered = PoolIntArray(elements_filtered)
			add_to_domain(domain, elements_filtered)
	
	
	func is_bound_elem(elem_id: int) -> bool:
		return elem_id in g.union_list(get_domain_elements())
	
	
	func is_dist_elem(elem_id: int) -> bool:
		
		for i in get_domains():
			if elem_id in i.get_elements() && !i.is_distinct:
				return false
		return true
	
	
	func is_domain(group_name) -> bool:
		return get_domain(group_name) != null
	
	
	func next(index = 0) -> Problem:
		
		if index > len(children) - 1:
			if g.is_null(parent):
				return null
			return parent.next(parent.children.find(self) + 1)
		else:
			return children[index]
	
	
	func prev(index = -2) -> Problem:
		
		if index == -1: return self
		if index < 0:
			if g.is_null(parent):
				return null
			return parent.prev(parent.children.find(self) - 1)
		else:
			return children[index]
	
	
	func remove_domain(index: int) -> void:
		
		for i in pos_constraints:
			if pos_constraints[i] == domains[index]:
				pos_constraints.erase(i)
		
		var deleted_elements = PoolIntArray()
		for i in domains[index].get_elements():
			var flag = true
			for domain_elements in get_domain_elements():
				if i in domain_elements:
					flag = false
					break
			if flag == true:
				deleted_elements.append(i)
		universe.erase_elements(deleted_elements)
		
		domains.remove(index)
	
	
	# TODO
	func reset():
		
		pos_constraints = {}
		solution = 0
		children = []
		config = g.Configuration.new()
		config.problem = self
		clear_domains()
	
	
	func set_config(type : String, size : int, custom_name : String, domain = get_universe()) -> void:
		
		config = g.Configuration.new(type, size, custom_name, domain)
		config.problem = self
		pos_constraints = Dictionary()
	
	
	func set_size_constraint(domain_name: String, operator: String, size: int) -> void:
		
		var domain = get_domain(domain_name)
		domain.set_size_constraint(operator, size)
	
	
	func set_size_constraint_array(domain_name: String, sizes : Array) -> void:
		
		var domain = get_domain(domain_name)
		domain.set_size_constraint_array(domain, sizes)
	
	
	func set_universe(element_ids: PoolIntArray, custom_name = "") -> void:
		
		clear_domains()
		universe.add_elements(element_ids)
		universe.set_name(custom_name)
	
	
	func to_cola() -> String:
		
		var cola = ""
		
		# Domains
		for domain in get_relevant_domains():
			cola += domain.to_cola()
			cola += "\n"
		
		# Configs
		cola += config.to_cola()
		
		# Pos Constraints
		for i in pos_constraints:
			if pos_constraints[i] != universe:
				cola += "\n{name}[{i}] = {domain};".format(
					{"name": config.get_name_cola(),
					 "i": int(i),
					 "domain": pos_constraints[i].get_name_cola()}
				)
		
		# Size Constraints
		for domain in domains:
			if domain.size_constraint.operator != "":
				cola += "\n#{d} {op} {i};".format(
					{"d": domain.get_name_cola(),
					 "op": domain.size_constraint.operator,
					 "i": domain.size_constraint.size}
				)
		
		cola += "\n"
		return cola
	
	
	func _print():
		
		print("universe: " + str(universe.get_elements()))
		for dom in domains:
			print(dom.get_name() + ": " + str(dom.get_elements()))
		print(config.get_type())


class Domain:
	
	
	var domain_name: String
	var elements: PoolIntArray
	var is_distinct: bool
	var size_constraint = g.SizeConstraint.new()
	var problem : Problem
	
	
	func _init(domain_name = "", _elements = PoolIntArray(), _is_distinct = true):
		
		self.domain_name = domain_name
		elements = _elements
		is_distinct = _is_distinct
	
	
	func get_elements() -> PoolIntArray:
		return elements
	
	
	func set_elements(elements: PoolIntArray) -> void:
		self.elements = elements
	
	
	func get_name() -> String:
		return domain_name
	
	
	func set_name(_name) -> void:
		domain_name = _name
	
	
	func get_name_cola() -> String:
		
		if not domain_name:
			return "uni"
		return domain_name.strip_edges().to_lower()
	
	
	func get_problem() -> Problem:
		return self.problem
	
	
	func set_problem(problem: Problem):
		self.problem = problem
	
	
	func get_size() -> int:
		return elements.size()
	
	
	func add_elements(new_elements : PoolIntArray) -> void:
		elements = g.union(elements, new_elements)
	
	
	func clear() -> void:
		elements = PoolIntArray()
	
	
	func erase_elements(elements: PoolIntArray) -> void:
		
		var cast = Array(get_elements())
		for i in elements:
			cast.erase(i)
		set_elements(PoolIntArray(cast))
	
	
	# return interval object
	func get_interval() -> Interval:
		
		if is_interval():
			# sorted by is_interval()
			var lo = elements[0]
			var hi = elements[-1]
			var interval = g.Interval.new(lo, hi)
			return interval
		return null
	
	
	func has_size_cs() -> bool:
		return size_constraint.operator != ""
	
	
	# Checks if this domain is an interval
	func is_interval() -> bool:
		
		Array(elements).sort()
		for i in range(len(elements)):
			if elements[i] != elements[0] + i:
				return false 
		return true
	
	
	func set_size_constraint(operator : String, size : int):
		size_constraint.init(self, operator, size)
	
	
	func set_size_constraint_array(domain : Domain, sizes : Array):
		size_constraint.init_array(domain, sizes)
	
	
	# translates to cola expression
	func to_cola() -> String:
		
		var dist = "indist ".repeat(int(!is_distinct))
		var elems = str(get_elements()).replace("[","{").replace("]","}").replace(" ","")
		if is_interval():
			elems = get_interval().string().replace(",",":").replace(" ","")
		var cola = "{}{} = {};".format([dist, get_name_cola(), elems], "{}")
		return cola


class Configuration:
	
	var size: int
	var custom_name: String
	var type: String
	var type_string_list = ["","",""]
	var problem : Problem
	var domain : Domain
	
	func _init(_type = "", _size = 0, _name = "", _domain = null):
		
		custom_name = _name
		size = _size
		domain = _domain
		set_type(_type)
	
	
	func get_size() -> int:
		return size
	
	
	func get_name() -> String:
		return custom_name
	
	
	func get_name_cola() -> String:
		
		if not custom_name:
			return "config"
		return custom_name.strip_edges().to_lower()
	
	
	func get_type():
		return type
	
	
	func set_type(_type : String):
		
		type = _type
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
	
	
	func get_domain():
		return domain
	
	
	func set_size(size: int) -> void:
		self.size = size
	
	
	func to_cola() -> String:
		
		var cola = "{c} in {h0}{h1}{u}{h2};".format(
			{"c": get_name_cola(),
			 "u": problem.get_universe_formula(),
			 "h0": type_string_list[0],
			 "h1": type_string_list[1],
			 "h2": type_string_list[2]}
		)
		cola += "\n#{c} = {s};".format({"c": get_name_cola(), "s": size})
		return cola


class PosConstraint:
	
	var configuration
	var domain
	var position
	
	func init(_config : Configuration, _position : int, _domain : Domain):
		
		configuration = _config
		position = _position
		domain = _domain
	
	
class SizeConstraint:
	
	
	var operator = ""
	var size = 0
	var domain : Domain
	var values : Array
	
	
	func _init():
		pass
	
	
	func init(domain : Domain, operator : String, size : int):
		
		self.domain = domain
		self.operator = operator
		self.size = size
	
	
	func init_array(domain : Domain, sizes : Array):
		
		self.domain = domain
		self.values = sizes
		var tmp = get_operator().split(" ")
		self.operator = tmp[0]
		self.size = tmp[1]
	
	
	func get_operator() -> String:
		
		if values.empty():
			return ""
		
		if len(values) == 1:
			return "= " + str(values[0])
		
		var no_vars = get_domain().get_problem().get_no_vars()
		
		if len(values) - 1 == no_vars:
			return ""
		if len(values) == no_vars:
			return "!= " + str(g.exclude(range(no_vars), values))
		
		var is_continious = true
		for i in range(values[0] + 1, values[0] + len(values)):
			if values[i] != i:
				is_continious = false
				break
		if is_continious:
			if values[0] == 0:
				return "< " + str(values[-1] + 1)
			if values[-1] == no_vars:
				return ">= " + str(values[0])
		
		return "in " + str(values)
	
	
	func get_domain() -> Domain:
		return domain


# Class for CoLa Expressions
class CoLaExpression:
	
	var type = ""
	var subtype = ""
	var cola_string
	
	func _init(cola_string : String):
		
		self.cola_string = cola_string
		
		# Comment
		if "%" in cola_string:
			set_type("comment")
		# Counts
		elif "#" in cola_string:
			set_type("constraint", "count")
		
		# Domain or PosConstraint
		elif "=" in cola_string:
			# Domain
			if "[" in cola_string:
				var list = cola_string.split("=")
				if "[" in list[0]:
					set_type("constraint", "position")
				else:
					set_type("domain", "interval")
			elif "{" in cola_string:
				set_type("domain", "enum")
		
		# Coniguration
		elif "in" in cola_string:
			
			if "[" in cola_string:
				if "||" in cola_string:
					set_type("config", "sequence")
				elif "|" in cola_string:
					set_type("config", "permutation")
					
			elif "{" in cola_string:
				if "||" in cola_string:
					set_type("config", "multisubset")
				elif "|" in cola_string:
					set_type("config", "subset")
			
			elif "partitions" in  cola_string:
				set_type("config", "partition")
			
			elif "compositions" in cola_string:
				set_type("config", "composition")
		
		else:
			set_type("newline")
	
	
	func set_type(type: String, subtype = "") -> void:
		
		self.type = type
		self.subtype = subtype
	
	
	# returns function string for eval() function
	func translate() -> String:
		
		var func_str = ""
		
		match type:
			
			"comment":
				pass
			
			"newline":
				pass
			
			"domain":
				var dist = "true"
				var list = cola_string.split("=")
				var _name = list[0].replace(" ", "")
				if "indist" in list[0]:
					dist = "false"
					_name = list[0].replace("indist", "").replace(" ", "")
				list[1] = list[1].replace(" ", "")
				
				if subtype == "interval":
					var interval_string = list[1].replace(":",",")
					func_str = "parse_domain_interval('{n}','{s}',{d})" \
						.format({"n" : _name, "s" : interval_string, "d" : dist})
				
				elif subtype == "enum":
					var array_string = list[1].replace("{", "[").replace("}", "]")
					func_str = "parse_domain_enum('{n}','{s}',{d})" \
						.format({"n" : _name, "s" : array_string, "d" : dist})
			
			"config":
				var list = cola_string.split(" in ")
				var name = list[0].replace(" ","")
				var domain_name = list[1].replace("partitions","").replace("compositions","").replace("(","").replace(")","").replace(" ","").replace("[","").replace("]","").replace("{","").replace("}","").replace("|","")
				var size = "0"
				func_str = "parse_config('{t}', {s}, '{n}', '{d}')" \
					.format({"t": subtype, "s": size, "n": name, "d": domain_name})
			
			"constraint":
				match subtype:
					
					"count":
						var args: Array
						var operator: String
						for i in g.OPERATORS:
							if i in cola_string: 
								args = cola_string.lstrip("#").replace(" ", "").split(i)
								operator = i
								break
						var name = args[0]
						var count = int(args[1])
						func_str = "parse_size_cs('{n}','{op}',{s})" \
							.format({"n" : name, "op" : operator, "s" : count})
					
					"position":
						var list = cola_string.split("=")
						var position = list[0].split("[")[1].replace(" ","").replace("]","")
						var domain_name = list[1].replace(" ","")
						func_str = "parse_pos_cs({p},'{d}')" \
							.format({"p" : position, "d" : domain_name})
		
		return func_str


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

