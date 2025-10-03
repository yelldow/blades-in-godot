extends Control

@onready
var LeftSidebar = $LeftSidebar
@onready
var RightSidebar = $RightSidebar

func set_left(pos):
	LeftSidebar.position = Vector2(pos.x, 0)

func set_right(pos):
	RightSidebar.position = Vector2(pos.x, 0)
