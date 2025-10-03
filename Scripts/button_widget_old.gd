extends Control

var buttons = []
var selected_button_size = 32
var button_size = 16
var selected_index = -1
var separators = []
var button_texts = []
var expand_top_offset = 12
var expand_bottom_offset = 16
@onready
var select = $Select
@onready
var expand = $Expand
var use_expand = false
var expand_scale = 1.0
var curve_radius = 6 # NEVER changes - used for calculating position

var animation_duration = .5

var queue = AnimQueue.new(false)

var animation_time = 0

func settings(_expand_bottom_offset,expand_top_offset):
	print("haha")

func set_separators():
	var num_separators = buttons.size()+1
	var separators_length = separators.size()
	var uninitialized = true
	if separators_length<num_separators:
		for i in range(num_separators - separators_length):
			var new_rect = ColorRect.new()
			separators.append(new_rect)
			add_child(new_rect)
			
		for i in separators:
			i.visible = true
	elif separators_length>num_separators:
		for i in separators:
			i.visible = false
	else:
		uninitialized = false
	
	if uninitialized:
		for i in separators:
			i.set_size(Vector2(256,1))
			i.color = Color(.11,.11,.11,.482)
	for i in separators.size():
		var diff = selected_button_size - button_size
		if selected_index>=0 and selected_index < separators.size(): # Within our range 
			if i<=selected_index:
				separators[i].position = Vector2(0,i*button_size)
			if i>selected_index:
				separators[i].position = Vector2(0,(i*button_size) + diff)
		else:
			separators[i].position = Vector2(0,i*button_size)
	
	for i in button_texts.size():
		var diff = selected_button_size - button_size
		if selected_index >= 0 and selected_index < button_texts.size():
			if i<=selected_index:
				button_texts[i].position = Vector2(0,i*button_size + (button_size / 2))
			if i>selected_index:
				button_texts[i].position = Vector2(0,i*button_size + (button_size / 2) + diff)
		else:
			button_texts[i].position = Vector2(0,i*button_size + (button_size / 2))

func set_expand():
	$Expand/horiz_high.set_y_pos(selected_index * button_size)
	$Expand/curve_high.set_y_pos(selected_index * button_size)
	if selected_index == 0 and expand_top_offset < 12:
		$Expand/curve_high.visible = false
	else:
		$Expand/curve_high.visible = true
	$Expand/vertical_high.set_y_pos(selected_index * button_size,expand_top_offset)
	$Expand/horiz_low.set_y_pos((selected_index * button_size) + selected_button_size)
	$Expand/curve_low.set_y_pos((selected_index * button_size) + selected_button_size)
	$Expand/vertical_low.set_y_pos(expand_bottom_offset + (buttons.size() * button_size) + (selected_button_size - button_size),selected_index * button_size + selected_button_size)

func set_element_time(time):
	$Expand/horiz_high.set_time(time)
	$Expand/curve_high.set_time(time)
	$Expand/vertical_high.set_time(time)
	$Expand/horiz_low.set_time(time)
	$Expand/curve_low.set_time(time)
	$Expand/vertical_low.set_time(time)
	$Select.set_time(time)

func animate():
	var _function = func(time):
			set_element_time(time)
	
	queue.add_anim(Anim.new(_function),animation_duration)
	

func render(selection_change: bool = false):
	select.set_y_size(selected_button_size)
	if selected_index>=0 and selected_index < buttons.size():
		select.visible = true
		expand.visible = true
		select.position = Vector2(0,( button_size * selected_index ) + 1)
		if selection_change: animate()
	else:
		select.visible = false
		expand.visible = false
	set_separators()
	set_expand()
	set_element_time(animation_time)



func set_selection(selection_index):
	selected_index = selection_index
	render(true)

func add_button(name: String, function = null, icon = null) -> void:
	if function == null or not (function is Callable):
		function = func():print("Tried to press button ",name," with an invalid or undefined function attached!")
	buttons.append({
		"name": name,
		"function": function,
		"icon": icon
		})
	var new_button_text = Label.new()
	new_button_text.text = name
	add_child(new_button_text)
	button_texts.append(Label.new())

func _ready() -> void:
	add_button("Live Arcade")
	add_button("Games")
	add_button("one")
	add_button("two")
	add_button("three")
	#expand_top = 0
	#expand_bottom = (button_size * buttons.size()) + 16 + (selected_button_size - button_size)
	render()

func _process(delta: float) -> void:
	inputs(delta)
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
