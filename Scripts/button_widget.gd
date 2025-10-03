extends Control

var buttons = []
var selected_height = 32
var unselected_height = 32
var selected_index = -1
var separators = []
var button_texts = []
var expand_top_offset = 12
var expand_bottom_offset = 16
var button_instance: PackedScene = preload("res://Scenes/button.tscn")
@onready
var select = $Select
@onready
var expand = $Expand
@onready
var top_tail = $Expand/top_tail
var use_expand = false
var expand_scale = 1.0
var curve_radius = 6 # NEVER changes - used for calculating position
var screen = ScreenData.nil

var queue = AnimQueue.new()

var animation_time = 0


func position_buttons():
	var cur_height = 0

	for i in buttons:
		i.position.y = cur_height
		cur_height+= i.size.y

func set_expand():
	$Expand/horiz_high.set_y_pos(selected_index * unselected_height + 1)
	$Expand/curve_high.set_y_pos(selected_index * unselected_height)
	if selected_index == 0 and expand_top_offset < 12:
		$Expand/curve_high.visible = false
	else:
		$Expand/curve_high.visible = true
	$Expand/vertical_high.set_y_pos(selected_index * unselected_height,expand_top_offset)
	$Expand/horiz_low.set_y_pos((selected_index * unselected_height) + selected_height - 1)
	$Expand/curve_low.set_y_pos((selected_index * unselected_height) + selected_height - 1)
	$Expand/vertical_low.set_y_pos(expand_bottom_offset + (buttons.size() * unselected_height) + (selected_height - unselected_height),selected_index * unselected_height + selected_height - 1)

func set_expand_time(time):
	$Expand/horiz_high.set_time(time)
	$Expand/curve_high.set_time(time)
	$Expand/vertical_high.set_time(time)
	$Expand/horiz_low.set_time(time)
	$Expand/curve_low.set_time(time)
	$Expand/vertical_low.set_time(time)
	$Expand/top_tail/shine.modulate.a = time
	$Expand/top_tail/shadow.modulate.a = time

func animate():
	var _function = func(time):
			set_expand_time(time)
	
	queue.add_anim(Anim.new(_function),ScreenData.get_data(screen,"animation","button_expand_time"))
	

func render():
	if selected_index == 0 and expand_top_offset == 0:
		top_tail.visible = true
	else:
		top_tail.visible = false
	if selected_index>=0 and selected_index < buttons.size():
		expand.visible = true
	else:
		expand.visible = false
	position_buttons()
	set_expand()
	set_expand_time(animation_time)

func set_selection(index):
	if index>=0 and index<buttons.size() and selected_index!=index:
		if selected_index>=0 and selected_index<buttons.size(): buttons[selected_index].set_selected(false)
		buttons[index].set_selected(true)
		selected_index = index
	else: # Since we're outside of our range, we'll still set the selected index, but nothing will show as selected
		if selected_index>=0 and selected_index<buttons.size(): buttons[selected_index].set_selected(false)
		selected_index = index
	render()
	queue.skip()
	animate()

func add_button(text: String, function: Callable = func():print("Tried to press button with an invalid or undefined function attached!"), icon = null) -> Object:
	print("Add Button Called")
	var new_button = button_instance.instantiate()
	add_child(new_button)
	new_button.set_text(text)
	new_button.set_function(function)
	new_button.set_icon(icon)
	new_button.set_height(selected_height,unselected_height)
	new_button.size.x = size.x
	buttons.append(new_button)
	return buttons[-1] # Enables external sources to access the button we just created. Probably rare, but just in case

func remove_button(index):
	if index>=0 and index<buttons.size():
		var to_delete = buttons[index]
		if to_delete:
			to_delete.queue_free()
		buttons.remove_at(index)

func _ready() -> void:
	#add_button("Achievements")
	#add_button("Played Games")
	#add_button("Xbox Live Arcade")
	#add_button("Demos")
	#add_button("Trailers")
	#expand_top = 0
	#expand_bottom = (unselected_height * buttons.size()) + 16 + (selected_height - unselected_height)
	render()

func _process(delta: float) -> void:
	#inputs(delta)
	queue.update(delta)

# TEMPORARY - USED FOR DEBUGGING
var time_since_input = 0
var up_hold_time = 0
var down_hold_time = 0



func inputs(delta: float) -> void:
	if Input.is_action_pressed("Up") and up_hold_time <= 0:
		set_selection(selected_index-1)
		time_since_input = 0
		up_hold_time = 0
		render()
	if Input.is_action_pressed("Up"):
		up_hold_time += delta
	else:
		up_hold_time = 0
		
	if Input.is_action_pressed("Down") and down_hold_time <= 0:
		set_selection(selected_index+1)
		time_since_input = 0
		render()
	if Input.is_action_pressed("Down"):
		down_hold_time += delta
	else:
		down_hold_time = 0
	
	time_since_input += delta
