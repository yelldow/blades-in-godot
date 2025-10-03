extends Control


@onready
var bg_colors = $BG_Colors

func set_bg(index):
	bg_colors.set_bg(index)

func animate_bg_right(index, leftmost, rightmost):
	bg_colors.animate_bg_right(index, leftmost, rightmost)

func animate_bg_left(index, leftmost, rightmost):
	bg_colors.animate_bg_left(index, leftmost, rightmost)
