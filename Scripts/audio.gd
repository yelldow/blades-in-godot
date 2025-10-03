extends Control

@onready
var swoosh1 = $Swoosh1
@onready
var swoosh2 = $Swoosh2
@onready
var swoosh3 = $Swoosh3
@onready
var swoosh4 = $Swoosh4
@onready
var swoosh5 = $Swoosh5
@onready
var swoosh_click = $SwooshClick

var click_time = .35
var click_wait = 0
var playing_click = false

func play_swoosh(num):
	[swoosh1,swoosh2,swoosh3,swoosh4,swoosh5][num].play()
	playing_click = true
	click_wait = 0

func _process(delta):
	if playing_click:
		click_wait += delta
		if click_wait > click_time:
			swoosh_click.play()
			playing_click = false
			click_wait = 0
