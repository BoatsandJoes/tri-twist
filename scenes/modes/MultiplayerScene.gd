extends Node2D

var GoGoGo = load("res://scenes/modes/GoGoGo.tscn")
var DigMode = load("res://scenes/modes/DigMode.tscn")
var player1Scene
var player2Scene

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	player1Scene = DigMode.instance()
	player2Scene = DigMode.instance()
	add_child(player1Scene)
	add_child(player2Scene)
	player2Scene.triangleDropper.set_piece_sequence(player1Scene.triangleDropper.pieceSequence)
	player2Scene.triangleDropper.deserialize(player1Scene.triangleDropper.serialize())
	player2Scene.connect("restart", self, "_on_scene_restart")
	player2Scene.connect("back_to_menu", self, "_on_scene_back_to_menu")
	player1Scene.set_multiplayer()
	player2Scene.set_multiplayer()
	player1Scene.position = Vector2(-200, 200)
	player2Scene.position = Vector2((get_tree().get_root().size[0] - 400) / 2, 200)
	player1Scene.hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").connect("combo_done",
	self, "player1_attack")
	player2Scene.hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").connect("combo_done",
	self, "player2_attack")
	player1Scene.triangleDropper.gameGrid.connect("garbage_rows", self, "_on_scene1_garbage_rows")
	player2Scene.triangleDropper.gameGrid.connect("garbage_rows", self, "_on_scene2_garbage_rows")

func set_config(config, p1Device, p2Device):
	player1Scene.set_player(1)
	player2Scene.set_player(2)
	player1Scene.set_config(config, p1Device, p2Device)
	player2Scene.set_config(config, p1Device, p2Device)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func player1_attack(score: int, comboKey):
	player2Scene.triangleDropper.gameGrid.queue_garbage(player1Scene.triangleDropper.gameGrid.offset_garbage(score, comboKey))

func player2_attack(score: int, comboKey):
	player1Scene.triangleDropper.gameGrid.queue_garbage(player2Scene.triangleDropper.gameGrid.offset_garbage(score, comboKey))

func _on_scene1_garbage_rows():
	player1_attack(50000, [])

func _on_scene2_garbage_rows():
	player2_attack(50000, [])

func _on_scene_restart():
	emit_signal("restart")

func _on_scene_back_to_menu():
	emit_signal("back_to_menu")