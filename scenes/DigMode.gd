extends GameScene
class_name DigMode

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	triangleDropper.gameGrid.toggle_chain_mode(true)
	triangleDropper.gameGrid.set_gravity(0.2)
	hud.set_time_limit(2, 0)
	triangleDropper.gameGrid.fill_bottom_rows(3)
	triangleDropper.gameGrid.digMode = true
	triangleDropper.gameGrid.connect("garbage_rows", self, "_on_gameGrid_garbage_rows")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_gameGrid_garbage_rows():
	._on_gameGrid_garbage_rows()
	hud.get_node("HBoxContainer/VBoxContainer/ScoreDisplay").increment_score(50000, false)