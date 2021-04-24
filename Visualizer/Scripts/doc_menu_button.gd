extends Button


var selected = false
var incr = 0.1
var hover = false


func _ready():
	
	$Panel.modulate.a = 0


func _process(delta):
	
	update_style_box()


func toggle_hover(hvr : bool):
	
	hover = hvr


func toggle_select(select : bool) -> void:
	
	selected = select


func update_style_box() -> void:
	
	if selected == true:
		#modulate_towards(1.0)
		$Panel.modulate.a = 1
	elif hover == true:
		#modulate_towards(0.7)
		$Panel.modulate.a = 0.7
	else:
		#modulate_towards(0.0)
		$Panel.modulate.a = 0
	


func modulate_towards(a : float) -> void:
	
	if $Panel.modulate.a > a:
		$Panel.modulate.a -= incr
	elif $Panel.modulate.a < a:
		$Panel.modulate.a += incr
	else:
		$Panel.modulate.a = a


