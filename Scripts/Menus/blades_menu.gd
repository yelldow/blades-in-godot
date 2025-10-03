extends Control

@onready
var button_widget = $Button_Widget
@onready
var user_select = $User_Widget/Selection_Box
@onready
var text = $Text
@onready
var cursor = $Cursor
var select = 0
var queued_buttons = []
func _ready():
	user_select.set_select(true)
	button_widget.expand_top_offset = 0
	#button_widget.add_button("Achievements")
	#button_widget.add_button("Played Games")
	#button_widget.add_button("Xbox Live Arcade")
	#button_widget.add_button("Demos and More")
	button_widget.render()

var time_since_input = 0
var up_hold_time = 0
var down_hold_time = 0

func add_button(_name: String, description: String):
	queued_buttons.append([_name,description])

var descriptions=[
	"",
	#"Unlock achievements by\nplaying games!",
	#"View the games you've played\nso far.",
	#"Explore and enjoy a collection\nofsimple, fun games. New\ntitles are always being added\nso checck back often.",
	#"Try game demos! You can\ndownload demos from Xbox\nLive Marketplace.",
	#"Watch game trailers. You can\ndownload trailers from Xbox\nLive Marketplace."
]

func set_select(_select):
	_select=clamp(_select,0,5)
	if _select!=select:
		button_widget.set_selection(_select-1)
		if _select==0:
			user_select.animate_select(true)
		elif select==0:
			user_select.animate_select(false)
		select=_select
		text.text = descriptions[select]

func _process(delta: float) -> void:
	if queued_buttons.size()>0:
		for button in queued_buttons:
			button_widget.add_button(button[0])
			descriptions.append(button[1])
			button.append("DONE")
		queued_buttons = queued_buttons.filter(func(button):return button.size()<3)

	inputs(delta)

func inputs(delta: float) -> void:
	if Input.is_action_pressed("Up") and select>0:
		if up_hold_time <= 0:
			cursor.play()
			set_select(select-1)
			time_since_input = 0
			up_hold_time+=delta
			#up_hold_time = 0
		else:
			up_hold_time+=delta
	else:
		up_hold_time=0
	
	if Input.is_action_pressed("Down") and select<4:
		if down_hold_time <= 0:
			cursor.play()
			set_select(select+1)
			time_since_input = 0
			down_hold_time += delta
			#down_hold_time = 0
		else:
			down_hold_time += delta
	else:
		down_hold_time = 0
	
	time_since_input += delta
