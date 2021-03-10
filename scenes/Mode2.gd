extends GameScene
class_name Mode2

# Called when the node enters the scene tree for the first time.
func _ready():
	triangleDropper.gameGrid.toggle_chain_mode(true)
	triangleDropper.gameGrid.set_gravity(0.05)
	hud.set_time_limit(2, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass