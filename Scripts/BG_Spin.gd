extends TextureRect

@onready
var speed = get_meta("spin_degrees_per_second")

func _process(delta: float) -> void:
	rotation += speed * delta
