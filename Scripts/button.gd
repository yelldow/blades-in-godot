extends Control



var button_text: 	String = "Undefined"
var function: 		Callable = func():print("Tried to press button ",button_text," with an invalid or undefined function attached!")
var unselected_height = 32
var selected_height = 32
var shift_distance: int = -2 # When selected, shift the icon and text by this amount
var icon_offset_x: 	int = 37 # If an icon is present, shift text by this amount
var base_x: 		int = 7 # Base horizontal position. Used by text if there's no icon
var use_icon: 		bool = false
var selected: 		bool = false
var shimmer_time = 0
var shimmer_delay = 0
var shimmer_length = .75
var shimmer_strength = 0.4
var queue = AnimQueue.new()
@onready var shimmer: TextureRect = $shimmer
@onready var select: Control = $SelectContainer
@onready var icon_container: MarginContainer = $IconContainer
@onready var icon: TextureRect = get_node_or_null("IconContainer/TextureRect")
@onready var text_container: Control = $TextContainer
@onready var text: RichTextLabel = $TextContainer/Clip/Text
@onready var text_clip: ColorRect = $TextContainer/Clip
var screen = ScreenData.nil

func _ready() -> void: 
	self.connect("resized", _resize)
	shimmer.texture.gradient.colors[1].a = shimmer_strength

func _resize():
	if size.y < 16:
		text_clip.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
		text_clip.self_modulate.a = 1
	else:
		text_clip.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED
		text_clip.self_modulate.a = 0

func set_icon(texture: Texture = null):
	if texture != null:
		use_icon = true
		icon.visible = true
		icon.texture = texture
		text_container.position.x = base_x + (shift_distance * (1 if selected else 0)) + (icon_offset_x if use_icon else 0)
	else:
		use_icon = false
		icon.visible = false

func set_text(_text):
	text.text = _text

func set_function(_function: Callable):
	function = _function

func set_select_time(time):
	time = clamp(time,0,1)
	icon_container.position.x = base_x + (shift_distance * time)
	text_container.position.x = base_x + (shift_distance * time) + (icon_offset_x if use_icon else 0)
	select.set_time(time)

func set_height(_selected_height, _unselected_height):
	selected_height = _selected_height
	unselected_height = _unselected_height
	if selected:
		size.y = selected_height
	else:
		size.y = unselected_height

func set_selected(_select: bool = false):
	if _select!=selected:
		if _select:
			size.y = selected_height
			selected = true
			queue.skip()
			queue.add_anim(Anim.new(func(time):
				set_select_time(time)
				),ScreenData.get_data(screen,"animation","select_time"))
		else:
			size.y = unselected_height
			selected = false
			queue.skip()
			queue.add_anim(Anim.new(func(time):
				set_select_time(1-time)
				),ScreenData.get_data(screen,"animation","select_time"))

func execute():
	function.call()

func set_shimmer(time):
	shimmer.size.y = select.size.y
	shimmer.size.x = 83 * (select.size.x / 256)
	shimmer.position.x = (select.size.x-shimmer.size.x) * time
	shimmer.self_modulate.a = sin(time * PI) * $SelectContainer/shine.self_modulate.a

#var elapsed = 0
func _process(delta: float) -> void:
	#elapsed+=delta
	#var _delta = ( sin(elapsed) + 1 ) * 0.5
	#set_select(_delta)
	queue.update(delta)
	shimmer_delay += delta
	if shimmer_delay > 3.5:# and selected: TODO: AFTER TESTING IS DONE, REMOVE THIS COMMENT
		shimmer_time += delta / shimmer_length
		set_shimmer(shimmer_time)
		shimmer_delay = 0
	elif shimmer_time > 0:
		shimmer_time += delta / shimmer_length
		if shimmer_time > 1:
			shimmer_time = 0
		set_shimmer(shimmer_time)
