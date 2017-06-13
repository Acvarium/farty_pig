extends AnimatedSprite
var a = 0


func set_a(anim):
	a = anim
	if a == 0:
		get_node("anim").play("water")
	elif a == 1:
		get_node("anim").play("water1")
	elif a == 2:
		get_node("anim").play("water2")

	
func _ready():
	if a == 0:
		get_node("anim").play("water")
	elif a == 1:
		get_node("anim").play("water1")
	elif a == 2:
		get_node("anim").play("water2")

	