extends Control
var cam_speed = 50
var cam_acc = 0.1
const MAX_CAM_SPEED = 60
var i = 0
var player
var over_water = false
var island_obj = load("res://objects/island.tscn") 
export var create_islands = false

func _ready():
	randomize()
	player = get_node("player")
	set_fixed_process(true)
	set_process_input(true)


func _input(event):
	if event.is_action_pressed("F5"):
		get_tree().reload_current_scene()

func _fixed_process(delta):
#	cam_speed += cam_acc
	i += 1
	var cam_pos = get_node("camera").get_pos()
	
	cam_pos.x += cam_speed * delta
	get_node("camera").set_pos(cam_pos)
	


func add_island():
	var island = island_obj.instance()
	var cam_pos = get_node("camera").get_pos()
	var pos = Vector2(cam_pos.x + 640, randf() * 208 + 128)
	island.set_pos(pos)
	get_node("islands").add_child(island)

func _on_TextureButton_button_down():
	player.jump(true)

func _on_TextureButton_button_up():
	player.jump(false)

func _on_TextureButton1_button_down():
	player.go_left(true)

func _on_TextureButton2_button_down():
	player.go_right(true)

func _on_TextureButton1_button_up():
	player.go_left(false)

func _on_TextureButton2_button_up():
	player.go_right(false)



func _on_side_killer_body_enter( body ):
	if !body.is_in_group("player"):
		if body.is_in_group("island") and create_islands:
			add_island()
		body.queue_free()


func _on_fish_trap_body_enter( body ):
	if body.is_in_group("player") and !player.eaten:
		over_water = true
		get_node("over_water").start()
		

func _on_fish_trap_body_exit( body ):
	if body.is_in_group("player") and !player.eaten:
		over_water = false
		get_node("over_water").stop()
		print("out")

func _on_over_water_timeout():
	var r = randf()
	print(r)
	if over_water:
		var player_pos = player.get_pos()
		var cam_pos = get_node("camera").get_pos()
		var fish_pos = get_node("ui/fish").get_pos()
		get_node("ui/fish").set_pos(Vector2(player_pos.x - (cam_pos.x - (get_tree().get_root().get_rect().size.x / 2)), fish_pos.y))
		get_node("ui/fish/anim").play("fish")
		get_node("camera/fish_trap/fish_trap_timer").start()
	else:
		get_node("over_water").start()
	
			
func jump_fish_trap():
	get_node("ui/fish/anim").set_speed(3)
	get_node("camera/fish_trap").set_pos(Vector2(0,126))

func _on_Area2D_body_enter( body ):
	print("kill")
	if body.is_in_group("player"):
		print("kill")

func _on_fish_trap_timer_timeout():
	player.hide()
	player.eaten = true

