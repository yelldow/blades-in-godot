extends Control

@onready
var shine = $shine

func set_time(time: float) -> void:
	time = clamp(time,0,1)
	shine.modulate.a = time

func set_y_pos(pos:int) -> void:
	position.y = pos
