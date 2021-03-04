extends Node2D


export (PackedScene) var GameScene
var gameScene: GameScene

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	gameScene = GameScene.instance()
	add_child(gameScene)

func _input(event):
	if event is InputEventKey && event.is_action_pressed("ui_escape"):
		get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_HSlider_value_changed(value):
	gameScene.triangleDropper.gameGrid.set_gravity(value)
	$MarginContainer/HBoxContainer/Labels/FallDelayValue.text = String(value)


func _on_ActiveChain_value_changed(value):
	gameScene.triangleDropper.gameGrid.set_clear_delay(value)
	$MarginContainer/HBoxContainer/Labels/ClearDelayValue.text = String(value)


func _on_NumColors_value_changed(value):
	gameScene.free()
	gameScene = GameScene.instance()
	add_child(gameScene)
	gameScene.triangleDropper.set_color_count(value)
	$MarginContainer/HBoxContainer/Labels/NumColorsValue.text = String(value)


func _on_ForceDrop_value_changed(value):
	gameScene.triangleDropper.set_drop_timer(value)
	$MarginContainer/HBoxContainer/Labels/ForceDropValue.text = String(value)


func _on_ClearScaling_value_changed(value):
	gameScene.triangleDropper.gameGrid.set_clear_scaling(value)
	$MarginContainer/HBoxContainer/Labels/ClearScalingValue.text = String(value)


func _on_Das_value_changed(value):
	$MarginContainer/HBoxContainer/Labels/DasValue.text = String(value)
	gameScene.triangleDropper.get_node("DasTimer").set_wait_time(value)


func _on_Arr_value_changed(value):
	$MarginContainer/HBoxContainer/Labels/ArrValue.text = String(value)
	gameScene.triangleDropper.get_node("ArrTimer").set_wait_time(value)


func _on_Previews_value_changed(value):
	$MarginContainer/HBoxContainer/Labels/PreviewsValue.text = String(value)
	gameScene.triangleDropper.set_previews_visible(value)
