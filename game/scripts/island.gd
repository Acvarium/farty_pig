extends StaticBody2D
var main_node
export var obj = true
var balloon_enter = false
var food_obj = load("res://objects/food.tscn") 
var snail_obj = load("res://objects/snail.tscn") 
var plant_obj = load("res://objects/plant.tscn") 
var balloon_obj = load("res://objects/balloon.tscn") 


func _ready():
	randomize()
	main_node = get_node("/root/main")
	if obj:
		add_food()

func add_food():
	var a = randf()
	if  a < 0.8:
		var set = randi()%(get_node("sets").get_child_count())
		for s in get_node("sets/set" + str(set + 1)).get_children():
			var food = food_obj.instance()
			var pos = s.get_pos()
			food.set_pos(pos)
			get_node("food").add_child(food)
	elif a > 0.8:
		var b = balloon_obj.instance()

		b.set_pos(Vector2(14, -32))
		get_node("creatures").add_child(b)
	
	if randf() < 0.5:
		if randf() < 0.8:
			add_creature(1)
		else:
			add_creature(0)
		
		
func add_creature(c_num):
	var creature = snail_obj.instance()
	creature.set_pos(Vector2(0,-22))
	if c_num == 1:
		creature = plant_obj.instance()
		creature.set_pos(Vector2(int(randf() * 50 - 25),-30))
	get_node("creatures").add_child(creature)

func _on_Area2D_body_enter( body ):
	if body.is_in_group("player"):
		if !balloon_enter:
			var balloons = body.get_balloons()
			if balloons > 0:
				body.set_balloons(balloons - 1)
			balloon_enter = true
		


func _on_Area2D_body_exit( body ):
	get_node("Timer").start()

func _on_Timer_timeout():
	balloon_enter = false
