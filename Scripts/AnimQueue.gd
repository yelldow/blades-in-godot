class_name AnimQueue extends Node
# AnimQueue
var groups = []
var debug = false

func _init(_enable_debug: bool = false):
	debug = _enable_debug
	if debug:
		print("Registered new animation queue")
		print("\t-debugging")

func update(delta):
	if debug: _debug()
	
	if groups.size()>0:
		if groups[0].duration<=0: # Handle 0-length animations. Code in AnimGroup ensures that these always return finished
			groups[0].update(delta)
			groups = groups.filter(func(group): return not group.finished)
		
		groups[0].update(delta)# / groups[0].duration) # This extra division doesn't seem right... We're already dividing in AnimGroup!!
		groups = groups.filter(func(group): return not group.finished)

func _debug():
	print("Animation Queue: \n\tQueue Size: ",groups.size())

func skip():
	if groups.size()>0:
		for group in groups:
			group.update(1)
		groups = groups.filter(func(group): return not group.finished)

func add_group(_AnimGroup: AnimGroup):
	groups.append(_AnimGroup)

func add_anim(_Anim: Anim, _duration):
	groups.append(AnimGroup.new([_Anim], _duration))
	
