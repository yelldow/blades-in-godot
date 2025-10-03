extends Control

@onready
var shadow = $shadow
@onready
var highlight_up = $highlight_up
@onready
var highlight_down = $highlight_down
@onready
var shine = $shine

func set_time(time):
	time = clamp(time,0,1)
	shadow.scale.y = time
	highlight_up.self_modulate.a = time
	highlight_down.self_modulate.a = time
	shine.self_modulate.a = time

func set_y_size(_size:int):
	size.y = _size
	shadow.position.y = _size
