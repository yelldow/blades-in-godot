extends Control

@onready
var shine = $shine
@onready
var shadow = $shadow

func set_time(time: float) -> void:
	time = clamp(time,0,1)
	shine.modulate.a = time
	shadow.scale.x = time * -1

func set_y_pos(pos:int) -> void:
	position.y = pos - 5
