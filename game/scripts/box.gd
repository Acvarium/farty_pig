extends Sprite
var main_node

func _ready():
	main_node = get_node("/root/main/")


func _on_Area2D_body_enter( body ):
	main_node.box()
	queue_free()
