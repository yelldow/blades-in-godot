extends Control

@onready
var opaque_blade = $Rotation_Controller/OpaqueBlade
@onready
var transparent_blade = $Rotation_Controller/TransparentBlade
@onready
var transparent_blade_bg = $Rotation_Controller/TransparentBlade/BG_Colors
@onready
var blank_blade = $Rotation_Controller/BlankBlade
@onready
var rotation_controller = $Rotation_Controller
@onready
var label = $Label
@onready
var bg_colors = $Rotation_Controller/TransparentBlade/BG_Colors/BG_Colors

func set_bg(index):
	bg_colors.set_bg(index)

var flip = false
var text_left = Vector2(32,145)
var text_right = Vector2(11,145)
var scale_deselected = Vector2(0.9,1.0)
var scale_selected = Vector2(1.0, 1.05)
var blank = false
var queue = AnimQueue.new()
var af = AnimFunctions.new()
var selected = false
var rot_pivot = -3000
var scale_object = self
var rotation_div = 2800
var menu_position = Vector2(48,0)
var menu_size = Vector2(985,0)

var z_offset = 0
var z_offset_amount = 10

var selected_index = -1
var next_selected_index = -1
var unique_index = -1
var next_unique_index = -1
var screen = ScreenData.nil
var next_screen = -1


func _process(delta):
	queue.update(delta)


var screen_transitions = { # Unique functions that determine the path this blade takes based on selected index, unique index, and screen
	[ScreenData.intro,ScreenData.blades]:func():
		print("intro to blades")
		initialize(),
	[ScreenData.blades,ScreenData.blades_maximized]:func():
		print("blades to blades maximized")
		initialize()
}


func set_selected_index(index: int): # Set new selected index. Current selected remains the same
	next_selected_index = index
	
func set_unique_index(index: int): # Set new unique index. Current remains the same
	next_unique_index = index

func set_screen(screen_index: int): # Set new screen. Current remains the same
	next_screen = screen_index

func set_menu_position(_position:Vector2,_size:Vector2):
	menu_position = _position
	menu_size = _size

func check():
	# Check if anything is invalid
	var valid = true
	
	if next_selected_index<0:
		valid = false
	if next_unique_index<0:
		valid = false
	if next_screen<0 or next_screen>=ScreenData.num_screens:
		valid = false
	return valid


func animate(): # If an animation exists from the current screen to the next, play it and set current to new
	if not check():return
	if screen==next_screen:
		if screen == ScreenData.blades:

			if next_selected_index == selected_index + 1: # Selecting the blade to the right
				selected_index = next_selected_index

				if unique_index < selected_index - 1: # Leftmost blades
					animate_to_position()
					z_offset = unique_index * z_offset_amount
					z_index = ScreenData.get_data(screen,"blade","selected_z_base") + z_offset
				elif unique_index == selected_index - 1: # Previously active left blade that deselects
					animate_to_position_and_select(false)
					z_offset = unique_index * z_offset_amount
					z_index = ScreenData.get_data(screen,"blade","selected_z_base") + z_offset
				elif unique_index == selected_index: # Right blade that moves left and selects
					animate_to_left_and_select()
					z_offset = unique_index * z_offset_amount
					z_index = ScreenData.get_data(screen,"blade","selected_z_base") + z_offset
				else: # Rightmost blades
					animate_to_position()
					z_offset = unique_index * z_offset_amount
					z_index = ScreenData.get_data(screen,"blade","deselected_z_base") - z_offset

			elif next_selected_index == selected_index - 1: # Selecting the blade to the left
				selected_index = next_selected_index

				if unique_index < selected_index: # Leftmost blades
					animate_to_position()
					z_offset = unique_index * z_offset_amount
					z_index = ScreenData.get_data(screen,"blade","selected_z_base") + z_offset
				elif unique_index == selected_index: # Now-Active left blade that selects
					animate_to_position_and_select(true)
					z_offset = unique_index * z_offset_amount
					z_index = ScreenData.get_data(screen,"blade","selected_z_base") + z_offset
				elif unique_index == selected_index + 1: # Blade that moves to the right
					animate_to_right_and_deselect()
					z_offset = unique_index * z_offset_amount
					z_index = ScreenData.get_data(screen,"blade","deselected_z_base") - z_offset
				else: # Rightmost blades
					animate_to_position()
					z_offset = unique_index * z_offset_amount
					z_index = ScreenData.get_data(screen,"blade","deselected_z_base") - z_offset

		else:
			initialize()
	else:
		if screen_transitions.has([screen,next_screen]):
			screen_transitions[[screen,next_screen]].call()
		else:
			initialize()


func skip():
	queue.skip()


func initialize(): # Set current to new, wipe all animations, go to the current target position
	if not check(): return
	selected_index = next_selected_index
	unique_index = next_unique_index
	screen = next_screen

	if unique_index < selected_index:
		rot_pos(get_left_position())
		set_flip_time(0)
		set_select(false)
		modulate.a = ScreenData.get_data(screen,"blade","deselected_alpha")
		z_offset = unique_index * z_offset_amount
		z_index = ScreenData.get_data(screen,"blade","deselected_z_base") + z_offset
	elif unique_index == selected_index:
		rot_pos(get_left_position())
		set_flip_time(0)
		set_select(true)
		modulate.a = ScreenData.get_data(screen,"blade","selected_alpha")
		z_offset = unique_index * z_offset_amount
		z_index = ScreenData.get_data(screen,"blade","selected_z_base") + z_offset
	else:
		rot_pos(get_right_position())
		set_flip_time(1)
		set_select(false)
		modulate.a = ScreenData.get_data(screen,"blade","deselected_alpha")
		z_offset = unique_index * z_offset_amount
		z_index = ScreenData.get_data(screen,"blade","deselected_z_base") - z_offset


func get_unified_position():
	if unique_index <= selected_index:
		return get_left_position()
	else:
		return get_right_position()

func get_left_position():
	if not check(): return
	var spacing = ScreenData.get_data(screen,"general","spacing")
	return Vector2(menu_position.x,0) + Vector2(
		spacing.x * (unique_index - selected_index),
		spacing.y * (selected_index - unique_index)
	)

func get_right_position():
	if not check(): return
	var spacing = ScreenData.get_data(screen,"general","spacing")
	return Vector2(menu_position.x,0) + Vector2(menu_size.x,0) + Vector2(
		spacing.x * (-1 + unique_index - selected_index),
		spacing.y * (-1 + unique_index - selected_index)
	)


func rot_pos(_position) -> void:
	rotation_controller.rotation = (_position.y / rotation_div ) * (func(_flip):
		if _flip: return -1
		else: return 1
		).call(flip)
	if flip: rotation_controller.pivot_offset.x = rot_pivot * -1
	else: rotation_controller.pivot_offset.x = rot_pivot
	if flip:
		label.position = Vector2(text_right.x,text_right.y+_position.y)
	else:
		label.position = Vector2(text_left.x,text_left.y+_position.y)
	position.x = _position.x

func animate_rot_pos(final_position) -> Callable:
	var initial_position = Vector2(position.x, rotation_controller.rotation * rotation_div * (func(_flip):
		if _flip: return -1
		else: return 1
		).call(flip))
	var rot_pos_anim = func(time):
		rot_pos(initial_position + (final_position - initial_position) * time)
	return rot_pos_anim

func set_alpha(alpha):
	opaque_blade.modulate.a = clamp(alpha,0,1)

func set_text(_text):
	label.text = _text

func animate_to_position():
	queue.add_anim(Anim.new(animate_rot_pos(get_unified_position())), ScreenData.get_data(screen,"animation","sweep_time"))


func animate_to_position_and_select(_selected): # Staying on same side and (de)selecting
	var _group = AnimGroup.new([
		Anim.new(animate_rot_pos(get_unified_position()))
		],ScreenData.get_data(screen,"animation","sweep_time"))
	_group.add_group(animate_select(_selected))
	queue.add_group(_group)


func animate_to_right_and_deselect(): # Moving to right and deselecting
	var _group = AnimGroup.new([
			Anim.new(animate_rot_pos(get_right_position())),
			Anim.new(func(time):set_flip_time(time))
		],ScreenData.get_data(screen,"animation","sweep_time"))
	
	if unique_index != selected_index: _group.add_group(animate_select(false))

	queue.add_group(_group)


func animate_to_left_and_select(): # Moving to left and selecting
	queue.add_group(AnimGroup.new([
			Anim.new(animate_rot_pos(get_left_position())),
			Anim.new(func(time):set_flip_time(1-time))
		],ScreenData.get_data(screen,"animation","sweep_time")))
	if unique_index == selected_index: queue.add_group(animate_select(true))


func set_select(_selected):
	if _selected and not selected:
		selected = true
		set_alpha(0)
		scale = scale_selected
	elif selected and not _selected:
		selected = false
		set_alpha(1)
		scale = scale_deselected


func animate_select(_selected): # Set select, expecting an animation to be added to the queue. Usage: queue.add_group(animate_select(true/false))
	var post_sweep_time = ScreenData.get_data(screen,"animation","post_sweep_time")
	if _selected and not selected:
		selected = true
		return AnimGroup.new([
			Anim.new(af.blade_alpha(self,0)),
			Anim.new(af.scale(scale_object,scale_selected))
		],post_sweep_time)
	elif selected and not _selected:
		selected = false
		return AnimGroup.new([
			Anim.new(af.blade_alpha(self,1)),
			Anim.new(af.scale(scale_object,scale_deselected))
		],post_sweep_time)
	else: # In case we did just try to select while selected (or vice versa), here's a harmless AnimGroup that does nothing
		return AnimGroup.new([
			Anim.new(func(time):print("Oops! Just tried to select while selected. Time: ",time))
		], 0)


func set_flip_time(time):
	if time<0.3:
		set_flip(false)
		set_blank(false)
	elif time<.55:
		set_flip(false)
		set_blank(true)
	elif time<.8:
		set_flip(true)
		set_blank(true)
	else:
		set_flip(true)
		set_blank(false)


func set_flip(_flip):
	if _flip and not flip: # Only flip if we're not already flipped. Save some time :D
		flip = true
		opaque_blade.flip_h = true
		transparent_blade.flip_h = true
		transparent_blade_bg.flip_h = true
		blank_blade.flip_h = true
		label.position = Vector2(text_right.x,text_right.y+position.y)
	elif flip and not _flip:
		flip = false
		opaque_blade.flip_h = false
		transparent_blade.flip_h = false
		transparent_blade_bg.flip_h = false
		blank_blade.flip_h = false
		label.position = Vector2(text_left.x,text_left.y+position.y)
	

func set_blank(_blank):
	if _blank and not blank:
		blank = true
		opaque_blade.visible = false
		transparent_blade.visible = false
		blank_blade.visible = true
		label.visible = false
	elif blank and not _blank:
		blank = false
		opaque_blade.visible = true
		transparent_blade.visible = true
		blank_blade.visible = false
		label.visible = true
