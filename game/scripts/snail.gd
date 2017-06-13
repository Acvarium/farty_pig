extends StaticBody2D
var flip = false
var move = false

func _ready():
	move = true
	get_node("sprite").set_flip_h(flip)
	if flip:
		get_node("floor/col").set_pos(Vector2(8,11))
	else:
		get_node("floor/col").set_pos(Vector2(-8,11))
	get_node("anim").play("snail")



func _on_anim_finished():
	var dir = -1
	if flip:
		dir = 1
	if move:
		get_node("anim").play("snail")
		var pos = get_pos()
		pos.x += dir
		set_pos(pos)


func _on_Area2D_body_enter( body ):
	print("________",body.get_name())
	if body.is_in_group("player"):
		print("+++++++++++",body.get_name())

		move = false
		get_node("anim").play("hide")


func _on_Area2D_body_exit( body ):
	if body.is_in_group("player"):
		move = true
		get_node("anim").play("show")

func _on_floor_body_exit( body ):
	if !body.is_in_group("player"):
		flip = !flip
		get_node("sprite").set_flip_h(flip)
		if flip:
			get_node("floor/col").set_pos(Vector2(8,11))
		else:
			get_node("floor/col").set_pos(Vector2(-8,11))
		
