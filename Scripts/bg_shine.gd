extends Control

var queue = AnimQueue.new()
var screen = ScreenData.nil
var peek_amount = 20 # How much extra height the shine should gain when animating before going to its normal size

func animate():
	queue.skip()
	pivot_offset.y = size.y*0.5
	scale.y = 0
	queue.add_anim(Anim.new(func(_time):pass),ScreenData.get_data(screen,"animation","sweep_time"))
	queue.add_anim(Anim.new(func(_time):scale.y = _time*((size.y+peek_amount)/size.y)),ScreenData.get_data(screen,"animation","shine_expand_time"))
	queue.add_anim(Anim.new(func(_time):scale.y = (size.y+(peek_amount*(1-_time)))/size.y),ScreenData.get_data(screen,"animation","shine_shrink_time"))

func _process(delta: float) -> void:
	queue.update(delta)
