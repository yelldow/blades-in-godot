class_name AnimGroup extends Node
# AnimGroup
var duration: float = 0
var elapsed: float = 0
var anims = []
var finished = false
var type = "AnimGroup"

func _init(_anims, _duration):
	anims = _anims
	duration = _duration

func add_anim(_anim):
	anims.append(_anim)

func add_group(_group): # Add a group's animations, discarding that group's duration
	for anim in _group.anims:
		add_anim(anim)

func update(delta):
	if duration <=0: # Handle 0-length animations
		for _anim in anims:
			_anim.function.call(1)
		finished = true
	
	if finished: return
	elapsed += delta
	if elapsed > duration:
		for _anim in anims:
			_anim.function.call(1)
		finished = true
	else:
		for _anim in anims:
			_anim.function.call(elapsed / duration)
