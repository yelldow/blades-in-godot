class_name AnimFunctions extends Node

func position(object, final_position):
	var initial_position = object.position
	return func(time): object.position = initial_position + (final_position - initial_position) * time

func scale(object, final_scale):
	var initial_scale = object.scale
	return func(time): object.scale = initial_scale + (final_scale - initial_scale) * time

func blade_alpha(object, final_alpha):
	var initial_alpha = object.opaque_blade.modulate.a
	return func(time): object.set_alpha(initial_alpha + (final_alpha - initial_alpha) * time)
