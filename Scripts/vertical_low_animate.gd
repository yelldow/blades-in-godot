extends Control

@onready
var shadow = $shadow
@onready
var shine = $shine

func set_time(time):
	time = clamp(time,0,1)
	shadow.scale.x = time * -1
	shine.modulate.a = time

func set_y_pos(bottom:int,top:int):
	position.y = top + 6
	size.y = bottom - (top + 6)
