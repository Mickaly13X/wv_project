extends Node

# GLOBAL-DEFINITIONS #

const ELEMENT = preload("res://Scenes/Element.tscn")
const ELEMENT_RADIUS = 20
const ELEMENT_BORDER_WIDTH = 5
const MAX_DOMAINS = 3
const MAX_CONFIG_SIZE = 18
const MAX_ELEMENTS = 30
const Problem = preload("res://Scripts/classes.gd").Problem
const Domain = preload("res://Scripts/classes.gd").Domain
const Configuration = preload("res://Scripts/classes.gd").Configuration
const Interval = preload("res://Scripts/classes.gd").Interval
const IntervalString = preload("res://Scripts/classes.gd").IntervalString
const CoLaExpression = preload("res://Scripts/classes.gd").CoLaExpression
const SizeConstraint = preload("res://Scripts/classes.gd").SizeConstraint
const OPERATORS = [
		">",
		">=",
		"=",
		"<",
		"<="
	]
const ELEMENT_COLORS = [
	Color(1, 0.406122, 0.406122), 
	Color(0.406122, 0.540673, 1), 
	Color(0.406122, 1, 0.554592), 
	Color(0.967522, 1, 0.406122),
	Color(0.675223, 0.406122, 1), 
	Color(1, 0.684503, 0.406122), 
	Color(1, 0.406122, 0.781936), 
	Color(0.406122, 0.958243, 1), 
	Color(0.558594, 0.218878, 0.218878), 
	Color(0.237456, 0.218878, 0.558594),
	
	Color(0.527344, 0.522786, 0.235667), 
	Color(0.641367, 0.497714, 0.730469), 
	Color(0.5625, 0.363865, 0.171343), 
	Color(0.09519, 0.371094, 0.325828),
	Color(0.25906, 0.075941, 0.425781), 
	Color(0.082449, 0.367188, 0.080207), 
	Color(0.402344, 0.104013, 0.15995), 
	Color(0.255135, 0.4375, 0.300726), 
	Color(0.515625, 0.322395, 0.485433), 
	Color(0.147169, 0.293623, 0.390625),
	
	Color(0.235667, 0.527344, 0.452146), 
	Color(0.509753, 0.141312, 0.738281), 
	Color(0.5625, 0.363865, 0.171343), 
	Color(0.148863, 0.089767, 0.433594),
	Color(0.425781, 0.075941, 0.34652), 
	Color(0.330711, 0.523438, 0.329193), 
	Color(0.261719, 0.198653, 0.089966),
	Color(0.826383, 0.752792, 0.988281), 
	Color(0.972656, 0.661102, 0.923976), 
	Color(0.667969, 0.391388, 0)
	]

onready var problem = Problem.new()


#---------------------------GENERAL-FUNCTION-LIBRARY-------------------------------#


# returns true if all members of 'group' have 'value' assigned to their 'attr'
func all(group: Array, attr: String, value = true) -> bool:
	
	for i in group:
		if i.get(attr) != value:
			return false
	return true


# returns copy of 'array' without any duplicates
func array2set(array: Array) -> Array:
	
	var set = []
	for i in array:
		if !(i in set):
			set.append(i)
	return set


# returns -1 for false; 1 for true
func bool2sign(b: bool) -> int:
	
	if b: return 1
	else: return -1


# returns representations of 'links', seperated by 'seperator'
func chain(links: Array, seperator: String) -> String:
	
	var chain = String()
	for i in range(len(links)):
		chain += str(links[i])
		if i != len(links) - 1:
			chain += seperator
	return chain


# returns true with a chance of 1 / n
func chance(n: int) -> bool:
	return random(n - 1) == 0


func check_duplicates(a):
	var is_dupe = false
	var found_dupe = false 

	for i in range(a.size()):
		if is_dupe == true:
			break
		for j in range(a.size()):
			if a[j] == a[i] && i != j:
				is_dupe = true
				found_dupe = true
				return is_dupe
				break


# returns random value from given list
# @pre 'list' is NOT empty
func choose(list: Array): 
	return list[random(len(list)) - 1]


# returns a random index number from 'weights', where
# 	| higher weight -> higher chance to be picked
# @pre 'weights' is NOT empty
func choose_weighted(weights: Array) -> int:
	
	var x = random(sum(weights) - 1)
	var cumsum = 0
	for i in range(len(weights)):
		cumsum += weights[i]
		if x < cumsum:
			return i
	return -1


# returns decibel value of given percentage, relative to a given 'full' (db)
func db(percentage: float, full_volume: float) -> float: 
	return -20 + (full_volume + 20) * percentage


# returns a / b
func exclude(a: Array, b: Array) -> Array:
	
	var exclude = a
	for element in b:
		if a.has(element):
			exclude.erase(element)
	return exclude


# returns a / b
# @param 'b': 2D Array
func exclude_list(a: Array, b: Array) -> Array:
	
	var exclude = a
	for b_sub in b:
		if exclude.empty():
			break
		exclude = exclude(a, b_sub)
	return exclude


# returns the value of 'attr' for each member of 'group'
func getall(group: Array, attr: String) -> Array:
	
	var values = []
	for i in group:
		values.append(i.get(attr))
	return values


# returns the value of 'func_name' for each member of 'group'
func getall_func(group: Array, func_name: String) -> Array:
	
	var values = []
	for i in group:
		values.append(i.call(func_name))
	return values


func has_list(a: Array, list: Array) -> bool:
	return a == union(a, list)


# returns highest value of 'attr' between members of 'group'
# @pre 'group' not empty
func highest(group: Array, attr: String):
	
	var highest = group[0].get(attr)
	for i in range(1, len(group)):
		if group[i].get(attr) > highest:
			highest = group[i].get(attr)
	return highest


# returns highest value of 'func_name' between members of 'group'
# @pre 'group' not empty
func highest_func(group: Array, func_name: String):
	
	var highest = group[0].call(func_name)
	for i in range(1, len(group)):
		var func_value = group[i].call(func_name)
		if func_value > highest:
			highest = func_value
	return highest


# returns the intersection of 2 arrays
func intersection(a: Array, b: Array) -> Array:
	
	var intersection = []
	for element in a:
		if b.has(element):
			intersection.append(element)
	return intersection


func is_null(x) -> bool:
	return typeof(x) == 0


func lengths(array2D: Array) -> PoolIntArray:
	
	var lengths = PoolIntArray()
	for i in array2D:
		lengths.append(len(i))
	return lengths


# returns lowest value of 'attr' between members of 'group'
# @pre 'group' not empty
func lowest(group: Array, attr: String):
	
	var lowest = group[0].get(attr)
	for i in range(1, len(group)):
		if group[i].get(attr) < lowest:
			lowest = group[i].get(attr)
	return lowest


# returns lowest value of 'func_name' between members of 'group'
# @pre 'group' not empty
func lowest_func(group: Array, func_name: String):
	
	var lowest = group[0].call(func_name)
	for i in range(1, len(group)):
		var func_value = group[i].call(func_name)
		if func_value < lowest:
			lowest = func_value
	return lowest


# returns the maximum value from a given list
# NOTE: only positive numbers will be considered
func max_list(list):
	
	var max_value = 0
	for i in list:
		if i > max_value: max_value = i
	return max_value


# returns true if no member of 'group' has 'value' assigned to their 'attr'
func none(group: Array, attr: String, value = true) -> bool:
	
	for i in group:
		if i.get(attr) == value:
			return false
	return true


# returns 'value' if value is between [low, high]
# returns 'low' if value < low
# returns 'high' if value > high
func normal(value: float, low: float, high: float) -> float:
	
	if value < low: return low
	if value > high: return high
	return value


# returns an integer between [0, n]
func random(n: int) -> int:
	return randi() % (n + 1)


# returns a float between [0, n]
func randomf(n: float) -> float: 
	return randf() * n


# returns a random Vector2 point inside a given rect
func randomRect(rect: Rect2) -> Vector2:
	return rect.position + randomVect(rect.size)


# returns a Vector2 with as values 2 integer between [0, n]
func randomVect(vect: Vector2) -> Vector2:
	return Vector2(random(vect.x), random(vect.y))


# returns an array containing the elements of 'a', but duplicated with respect 
# 	to the order 'n' times 
func repeat(a: Array, n: int) -> Array:
	
	var a_repeated = Array()
	for i in range(n):
		a_repeated += a.duplicate(true)
	return a_repeated


# returns an array with the elements from 'a', reversed in order
func reverse(a: Array) -> Array:
	
	var a_reverse = Array(a)
	a_reverse.invert()
	return a_reverse


# returns the sum of all elements from the given list
func sum(list: Array):
	
	if list.empty():
		return null
	var sum = list[0]
	for i in range(1, len(list)):
		sum += list[i]
	return sum


# returns the union of 2 arrays
# Note: result = set
func union(a: Array, b: Array) -> Array:
	return array2set(a + b)


# returns the union of multiple arrays
# Note: result = set
func union_list(arrays: Array) -> Array:
	
	var sum = sum(arrays)
	if is_null(sum):
		return []
	return array2set(sum)
