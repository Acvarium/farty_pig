tool
extends StaticBody2D
export var type = 0 setget type_changed
export var move_pos = Vector2(0,0) setget move_pos_changed
export var speed = 100
export var f_process = false 
var move_to = true
var vector
var main_node

func type_changed(new_value):
	type = new_value
	
func move_pos_changed(new_value):
	move_pos = new_value
#	if !get_tree().is_editor_hint():
	if has_node("Position2D"):
		get_node("Position2D").set_pos(move_pos)

func _ready():
	main_node = get_node("/root/main")
	if !get_tree().is_editor_hint():
		get_node("anim").play("f_ball")
		set_fixed_process(f_process)
		var pos = get_node("f_ball").get_pos()
		vector = (move_pos - pos).normalized() * speed

func set_f_process(f):
	f_process = f
	set_fixed_process(f_process)

func _fixed_process(delta):
	if type == 1:
		if move_to:
			if get_node("f_ball").get_pos().distance_to(move_pos) > 5:
				var pos = get_node("f_ball").get_pos()
				var dir = move_pos - pos
				var move = dir.normalized() * speed
				get_node("f_ball").set_pos(pos + (move * delta))
			else:
				move_to = false
		else:
			if get_node("f_ball").get_pos().length() > 5:
				var pos = get_node("f_ball").get_pos()
				var dir = Vector2(0,0) - pos
				var move = dir.normalized() * speed
				get_node("f_ball").set_pos(pos + (move * delta))
			else:
				move_to = true
	elif type == 2:
		var pos = get_node("f_ball").get_pos()
		get_node("f_ball").set_pos(pos + (vector * delta))
		
func _on_Area2D_body_enter( body ):
	if body.is_in_group("player"):
		body.shock()
		main_node.jump_fish_trap()
		main_node.get_node("over_water").set_wait_time(0.001)
		main_node.get_node("ui/fish/anim").set_speed(2)
		queue_free()
	else:
		vector.y = -vector.y

func _on_Area2D_area_enter( area ):
	if area.is_in_group("in_wall"):
		set_f_process(true)
