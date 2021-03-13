extends Node2D
class_name GameScene


export (PackedScene) var TriangleDropper
var HUD = load("res://scenes/ui/HUD.tscn")
var PausePopup = load("res://scenes/ui/PausePopup.tscn")
var triangleDropper: TriangleDropper
var hud: HUD
var pausePopup: PausePopup

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	triangleDropper = TriangleDropper.instance()
	add_child(triangleDropper)
	triangleDropper.set_previews_visible(3)
	triangleDropper.connect("piece_sequence_advanced", self, "_on_triangleDropper_piece_sequence_advanced")
	triangleDropper.gameGrid.connect("tumble", self, "_on_gameGrid_tumble")
	triangleDropper.gameGrid.connect("grid_full", self, "_on_gameGrid_grid_full")
	hud = HUD.instance()
	hud.set_position(Vector2(10, 100))
	hud.set_size(Vector2(1900, 780))
	add_child(hud)
	hud.connect("end_game", self, "_on_HUD_end_game")
	pausePopup = PausePopup.instance()
	add_child(pausePopup)

func _input(event):
	if event is InputEventKey && event.is_action_pressed("ui_escape"):
		# Set pause menu to pause mode
		pausePopup.set_mode_pause()

func get_chains():
	return hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").combos

func has_chain(chainKey):
	return hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").combos.has(chainKey)

func get_chain(chainKey) -> Dictionary:
	if hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").combos.has(chainKey):
		return hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").combos.get(chainKey)
	else:
		return {}

func upsert_chain(chainKey, chainValue):
	hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").upsert_combo(chainKey, chainValue)

func delete_chain(chainKey):
	hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").delete_combo(chainKey)

func end_combo_if_exists(comboKey):
	hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").end_combo_if_exists(comboKey)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_triangleDropper_piece_sequence_advanced():
	hud.get_node("HBoxContainer/VBoxContainer2/MoveCount").make_move()

func _on_gameGrid_tumble():
	pass
	#hud.get_node("HBoxContainer/VBoxContainer/ScoreDisplay").increment_score(1) Turned off because of hard drop

func _on_gameGrid_grid_full():
	_on_HUD_end_game()

func _on_HUD_end_game():
	# Freeze input
	triangleDropper.set_process_input(false)
	triangleDropper.leftPressed = false
	triangleDropper.rightPressed = false
	triangleDropper.get_node("DasTimer").stop()
	triangleDropper.get_node("ArrTimer").stop()
	# Clear all chains.
	triangleDropper.gameGrid.set_off_chains()
	var timer = Timer.new()
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	timer.start(3.1)

func _on_timer_timeout():
	# Set pause menu to game end mode
	pausePopup.set_mode_finished()