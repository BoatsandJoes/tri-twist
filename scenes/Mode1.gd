extends GameScene
class_name Mode1

# Called when the node enters the scene tree for the first time.
func _ready():
	triangleDropper.gameGrid.toggle_chain_mode(false)
	triangleDropper.gameGrid.set_gravity(0.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass