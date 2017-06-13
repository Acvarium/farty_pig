extends Sprite
var parent_name = "../player"
var parent

func _ready():
	parent = get_node(parent_name)
	set_process(true)
	
func _process(delta):
	var pos = parent.get_pos()
	set_pos(Vector2(int(pos.x), int(pos.y/5) * 5))
