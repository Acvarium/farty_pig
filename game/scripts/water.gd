tool
extends ParallaxLayer
var water_obj = load("res://objects/water.tscn") 
export var a = 0


func _ready():
	for i in range(672/32):
		var w = water_obj.instance()
#		w.set_a(a)
		w.set_pos(Vector2(i * 32, 0))
		add_child(w)
		
	pass
