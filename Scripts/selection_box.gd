extends Control

@onready
var select_shine = $Select_Shine
var queue = AnimQueue.new()
var screen = ScreenData.nil
var selected = false

func set_select(_selected):
	if selected and not _selected:
		select_shine.modulate.a = 0
		selected = false
	if _selected and not selected:
		select_shine.modulate.a = 1
		selected = true
	

func animate_select(_selected):
	if selected and not _selected:
		queue.skip()
		queue.add_anim(Anim.new(func(time):select_shine.modulate.a = 1-time
		),ScreenData.get_data(screen,"animation","select_time"))
		selected = false
	elif _selected and not selected:
		queue.skip()
		queue.add_anim(Anim.new(func(time):select_shine.modulate.a = time
		),ScreenData.get_data(screen,"animation","select_time"))
		selected = true
	

func _process(delta: float) -> void:
	queue.update(delta)
