extends Control

@onready
var BG = $Background
@onready
var Audio = $Audio
@onready
var Sidebars = $Sidebars

var screen_size = Vector2(1152,648)
var base_size = Vector2(1152,648)
var blades = []
var blade_instance: PackedScene = preload("res://Scenes/Blade.tscn")
var menu_instance: PackedScene = preload("res://Scenes/Menus/blades_menu.tscn")
var horizontal_offset = Vector2(50,0)
var vertical_offset = Vector2(0,10)
# var offset_right = offset * Vector2 (-1,1)
# Blades position is calculated based on the position of the menu.
# The menu position is calculated, then the data is passed to the blades, then they're prompted to animate to their new positions.
# The menu position is calculated by adding offsets to the topleftmost position
# The topleftmost menu position is gathered from ScreenData.json
var menu_position = Vector2(0,0)
var menu_size = Vector2(0,0)
var inner_topleft = Vector2(0,0)
var inner_bottomright = Vector2(0,0)
var inner_margin_vertical = 90
var inner_margin_left = 58
var inner_margin_right = -64
var selected_page = 2
var pages = 5
var page_text = [
	"marketplace",
	"xbox live",
	"games",
	"media",
	"system"
]
var menus = []
var menu_info = [
	{
		"name":"marketplace",
		"type":"marketplace"
	},
	{
		"name":"xbox live",
		"type":"live"
	},
	{
		"name":"games",
		"type":"generic",
		"buttons":[
			{
				"name":"Achievements",
				"description":"Unlock achievements by\nplaying games!",
			},
			{
				"name":"Played Games",
				"description":"View the games you've played\nso far."
			},
			{
				"name":"Xbox Live Arcade",
				"description":"Explore and enjoy a collection\nofsimple, fun games. New\ntitles are always being added\nso checck back often.",
			},
			{
				"name":"Demos and More",
				"description":"Try game demos! You can\ndownload demos from Xbox\nLive Marketplace."
			}
		]
	}
]
var menu_handlers = {
	"nil":func(menu,info):pass,
	"marketplace":func(menu,info):
		menu.add_button("marketplace","this isn't implemented yet :("),
	"live":func(menu,info):
		menu.add_button("live","this isn't implemented yet :("),
	"generic":func(menu,info):
		for i in info["buttons"]:
			menu.add_button(i["name"],i["description"])
			print("haha")
}

var screen = ScreenData.blades
var elapsed_time = 0

var menu_queue = AnimQueue.new()

@onready
var sidebars = $Sidebars
@onready
var menu_container = $Menu_Container
@onready
var menu_margin = $Menu_Container/Menu_Margin
@onready
var bg_shine = $"Menu_Container/BG Shine"

var playing_animations = [] # A list of animation queues; A queue is a list of animations played in series

var tasks = []

#TODO: Refactor menu_topleftmost and menu_size into menu_topleft and menu_bottomright


func process_tasks():
	tasks = tasks.filter(
	func(task): return not task.call(elapsed_time))

func animate_menu():
	menu_queue.skip()
	menu_margin.modulate.a = 0
	menu_queue.add_anim(Anim.new(func(_time):pass),ScreenData.get_data(screen,"animation","sweep_time")+ScreenData.get_data(screen,"animation","shine_expand_time"))
	menu_queue.add_anim(Anim.new(func(_time):menu_margin.modulate.a = _time),ScreenData.get_data(screen,"animation","shine_shrink_time"))

func animate_blades(): # Prompt all blades to animate to their new positions
	bg_shine.animate()
	animate_menu()
	for i in range(len(blades)):
		blades[i].set_menu_position(menu_position,menu_size)
		blades[i].set_unique_index(i)
		blades[i].set_selected_index(selected_page)
		blades[i].set_screen(screen)
		blades[i].set_text(page_text[i])
		blades[i].animate()

func initialize_blades(): # Set positions of all blades without animation
	for i in range(len(blades)):
		blades[i].set_menu_position(menu_position,menu_size)
		blades[i].set_unique_index(i)
		blades[i].set_selected_index(selected_page)
		blades[i].set_screen(screen)
		blades[i].set_text(page_text[i])
		blades[i].set_bg(i)
		blades[i].initialize()


func position_menu():
	menu_position = ScreenData.get_data(screen,"menu","position") + Vector2(ScreenData.get_data(screen,"general","spacing").x * selected_page,0)
	menu_size = ScreenData.get_data(screen,"menu","size")
	menu_container.position = menu_position + ScreenData.get_data(screen,"menu","margin_topleft")
	menu_container.size = menu_size - (ScreenData.get_data(screen,"menu","margin_topleft") + ScreenData.get_data(screen,"menu","margin_bottomright"))
	sidebars.set_left(Vector2(ScreenData.get_data(screen,"general","sidebars")[0],0))
	sidebars.set_right(Vector2(screen_size.x - ScreenData.get_data(screen,"general","sidebars")[1],0))

func _ready():
	BG.set_bg(selected_page)
	position_menu()
	for i in range(pages):
		var new_blade = blade_instance.instantiate()
		blades.append(new_blade)
		add_child(new_blade)
	initialize_blades()
	for menu in menu_info:
		print("menu ",menu["name"])
		var new_menu = menu_instance.instantiate()
		menus.append(new_menu)
		menu_handlers.get(menu.get("name"),menu_handlers["nil"]).call(new_menu,menu)
		$Menu_Container/Menu_Margin/Menu.add_child(new_menu)
		new_menu.anchor_left = 0.0
		new_menu.anchor_top = 0.0
		new_menu.anchor_right = 1.0
		new_menu.anchor_bottom = 1.0
		new_menu.offset_left =  0
		new_menu.offset_top = 0
		new_menu.offset_right = 0
		new_menu.offset_bottom = 0
		new_menu.grow_horizontal = 2
		new_menu.grow_vertical = 2
	
	print("finished adding menus!")
	
	# Connect the size_changed signal
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_size_changed"))
	
	

func page_left():
	if selected_page>0:
		selected_page-=1
		for blade in blades:
			blade.skip()
		position_menu()
		animate_blades()
		#initialize_blades()
		
		#BG.set_bg(selected_page)

		BG.animate_bg_right(selected_page,blades[selected_page+1].position.x + 50,menu_position.x + menu_size.x + 50)
		Audio.play_swoosh(selected_page)
	

func page_right():
	if selected_page<pages-1:
		selected_page+=1
		for blade in blades:
			blade.skip()
		position_menu()
		animate_blades()
		#initialize_blades()

		#BG.set_bg(selected_page)
		
		BG.animate_bg_left(selected_page,blades[selected_page-1].position.x + ScreenData.get_data(screen,"general","spacing").x + 50,blades[selected_page].position.x + 50)
		Audio.play_swoosh(selected_page)


var cur_input = "none"
var prev_input = "none"
var repeat_delay = .35
var repeat_rate = .15
var input_rate = .1
var repeat_wait_time = 0
var input_wait_time = 0
var input_hold_time = 0
var input_held = false

func call_input():
	if cur_input != "none":
		{
			"left": page_left,
			"right": page_right,
		}[cur_input].call()

func process_input_direction(): # Decides between left and right
	prev_input = cur_input
	var left = Input.is_action_pressed("Left")
	var right = Input.is_action_pressed("Right")
	var action = "none"
	if left and not right:
		action = "left"
	if right and not left:
		action = "right"
	cur_input = action

func process_inputs(delta):
	if cur_input == prev_input and cur_input != "none":
		input_hold_time += delta
		input_held = true
	else:
		input_hold_time = 0
		input_held = false
	# Two systems:
	# One registers inputs *once* - if they've been held, it does nothing
	# The other registers inputs only if they've been held for x ms
	
	# Repeated single inputs. These do not repeat
	if cur_input != "none":
		if input_held == false:
			call_input()
	
	# A single held input that repeats
	if input_held == true:
		if input_hold_time > repeat_delay:
			if repeat_wait_time <= 0:
				call_input()
				repeat_wait_time = repeat_rate
			else:
				repeat_wait_time -= delta
		else:
			repeat_wait_time = 0
	else:
		repeat_wait_time = 0



func _process(delta: float) -> void:
	process_input_direction()
	process_inputs(delta)
	elapsed_time += delta
	process_tasks()
	menu_queue.update(delta)
	

func _on_viewport_size_changed():
	var new_size = get_viewport().size
	scale = Vector2(float(new_size.x) / 1152.0, float(new_size.y) / 648.0)
