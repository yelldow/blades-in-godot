extends Control

@onready
var shadow = $shadow
@onready
var shadow_gradient = $shadow.texture.gradient
@onready
var shine = $shine

var gradient_positions_initial = [0.0,0.64,0.99,1.0]
var gradient_positions_final = [0.84,0.94,0.99,1.0]
var initial_end_alpha = 0
var final_end_alpha = 0.188

func set_time(time):
	time = clamp(time,0,1)
	for i in range(shadow_gradient.offsets.size()):
		shadow_gradient.offsets[i] = gradient_positions_final[i] + (gradient_positions_initial[i] - gradient_positions_final[i]) * time
	shadow_gradient.colors[0].a = initial_end_alpha + (final_end_alpha - initial_end_alpha) * time
	shine.modulate.a = time

func set_y_pos(pos:int):
	position.y = pos - 6
