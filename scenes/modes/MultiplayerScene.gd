extends Node2D

var GoGoGo = load("res://scenes/modes/GoGoGo.tscn")
var DigMode = load("res://scenes/modes/DigMode.tscn")
var player1Scene
var player2Scene

# Called when the node enters the scene tree for the first time.
func _ready():
	player1Scene = DigMode.instance()
	player2Scene = DigMode.instance()
	add_child(player1Scene)
	add_child(player2Scene)
	player2Scene.connect("restart", self, "_on_scene_restart")
	player2Scene.connect("back_to_menu", self, "_on_scene_back_to_menu")
	player1Scene.set_multiplayer()
	player2Scene.set_multiplayer()
	player1Scene.position = Vector2(-200, 200)
	player2Scene.position = Vector2((get_tree().get_root().size[0] - 400) / 2, 200)
	player1Scene.hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").connect("combo_done",
	player2Scene.triangleDropper.gameGrid, "spawn_garbage")
	player2Scene.hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").connect("combo_done",
	player1Scene.triangleDropper.gameGrid, "spawn_garbage")
	player1Scene.triangleDropper.gameGrid.connect("garbage_rows", self, "_on_scene1_garbage_rows")
	player2Scene.triangleDropper.gameGrid.connect("garbage_rows", self, "_on_scene2_garbage_rows")

func set_config(config):
	player1Scene.set_player(1)
	player2Scene.set_player(2)
	player1Scene.set_config(config)
	player2Scene.set_config(config)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_scene1_garbage_rows():
	player2Scene.triangleDropper.gameGrid.spawn_garbage(50000)

func _on_scene2_garbage_rows():
	player1Scene.triangleDropper.gameGrid.spawn_garbage(50000)

func _on_scene_restart():
	emit_signal("restart")

func _on_scene_back_to_menu():
	emit_signal("back_to_menu")