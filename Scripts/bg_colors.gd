extends Control

var queue = AnimQueue.new()
var screen = ScreenData.nil


@onready
var bgs = [$Red, $Orange, $Green, $Blue, $Purple]
@onready
var current_bg = bgs[0]

func set_bg(index):
	queue.skip()
	current_bg.visible = false
	current_bg = bgs[index]
	current_bg.visible = true

func animate_bg_right(index,leftmost,rightmost):
	queue.skip()
	
	var prev_bg = current_bg
	current_bg = bgs[index]
	prev_bg.visible = true
	current_bg.visible = true
	prev_bg.pivot_offset.x = prev_bg.size.x
	current_bg.pivot_offset.x = 0

	var cur_scale_initial = leftmost/size.x
	var cur_scale_final = rightmost/size.x
	var prev_scale_initial = (size.x - leftmost)/size.x
	var prev_scale_final = (size.x - rightmost)/size.x

	queue.add_group(AnimGroup.new([
			Anim.new(func(_time):
				current_bg.scale.x = cur_scale_initial + (cur_scale_final - cur_scale_initial) * _time
				if _time >= 1:
					current_bg.visible = true
					current_bg.scale.x = 1
					current_bg.pivot_offset.x = 0
				),
			Anim.new(func(_time):
				prev_bg.scale.x = prev_scale_initial + (prev_scale_final - prev_scale_initial) * _time
				if _time >= 1:
					prev_bg.visible = false
					prev_bg.scale.x = 1
					prev_bg.pivot_offset.x = 0
				)
		], ScreenData.get_data(screen,"animation","sweep_time")))


func animate_bg_left(index,leftmost,rightmost):
	queue.skip()

	var prev_bg = current_bg
	current_bg = bgs[index]
	prev_bg.visible = true
	current_bg.visible = true
	prev_bg.pivot_offset.x = 0
	current_bg.pivot_offset.x = current_bg.size.x

	var cur_scale_initial = (size.x - rightmost)/size.x
	var cur_scale_final = (size.x - leftmost)/size.x
	var prev_scale_initial = rightmost/size.x
	var prev_scale_final = leftmost/size.x

	queue.add_group(AnimGroup.new([
			Anim.new(func(_time):
				current_bg.scale.x = cur_scale_initial + (cur_scale_final - cur_scale_initial) * _time
				if _time >= 1 and 0==1:
					current_bg.visible = true
					current_bg.scale.x = 1
					current_bg.pivot_offset.x = 0
				),
			Anim.new(func(_time):
				prev_bg.scale.x = prev_scale_initial + (prev_scale_final - prev_scale_initial) * _time
				if _time >= 1 and 0==1:
					prev_bg.visible = false
					prev_bg.scale.x = 1
					prev_bg.pivot_offset.x = 0
				)
		], ScreenData.get_data(screen,"animation","sweep_time")))


func _process(delta: float) -> void:
	queue.update(delta)
