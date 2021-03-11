extends GameScene
class_name Mode1

# Called when the node enters the scene tree for the first time.
func _ready():
	triangleDropper.gameGrid.toggle_chain_mode(false)
	triangleDropper.gameGrid.set_gravity(0.2)
	hud.set_move_limit(90)

func restart():
	.parent_restart()
	_ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass