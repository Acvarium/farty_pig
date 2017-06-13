extends StaticBody2D


func _ready():
	randomize()
	get_node("sprite").set_frame(randi()%3)
	if randf() < 0.5:
		get_node("sprite").set_flip_h(true)