extends Control

@onready
var shine = $shine
@onready
var shadow = $shadow

func set_time(time: float) -> void:
	time = clamp(time,0,1)
	shadow.scale.y = time
	shine.modulate.a = time

func set_y_pos(pos:int) -> void:
	position.y = pos - 3
