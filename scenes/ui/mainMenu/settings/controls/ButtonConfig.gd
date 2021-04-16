extends PanelContainer
class_name ButtonConfig

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event: InputEvent):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Tuning_pressed():
	$HBoxContainer/TopMenu.visible = false
	$HBoxContainer/TuningMenu.visible = true

func _on_GameButtons_pressed():
	$HBoxContainer/TopMenu.visible = false
	$HBoxContainer/GameButtonConfig.visible = true

func _on_MenuButtons_pressed():
	$HBoxContainer/TopMenu.visible = false
	$HBoxContainer/MenuButtonConfig.visible = true
