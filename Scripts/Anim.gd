class_name Anim extends Node
# Anim
var function = func(time): print("Animation without function! Time: ",time)

func _init(_function: Callable) -> void:
	function = _function
