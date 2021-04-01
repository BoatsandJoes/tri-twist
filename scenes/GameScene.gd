extends Node2D
class_name GameScene

signal back_to_menu
signal restart

var TriangleDropper = load("res://scenes/TriangleDropper.tscn")
var HUD = load("res://scenes/ui/HUD.tscn")
var PausePopup = load("res://scenes/ui/PausePopup.tscn")
var FakeGameGrid = load("res://scenes/FakeGameGrid.tscn")
var triangleDropper: TriangleDropper
var hud: HUD
var pausePopup: PausePopup
var fakeGrid: FakeGameGrid
var player: int

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	triangleDropper = TriangleDropper.instance()
	add_child(triangleDropper)
	triangleDropper.set_previews_visible(3)
	triangleDropper.connect("piece_sequence_advanced", self, "_on_triangleDropper_piece_sequence_advanced")
	triangleDropper.gameGrid.connect("tumble", self, "_on_gameGrid_tumble")
	triangleDropper.gameGrid.connect("grid_full", self, "_on_gameGrid_grid_full")
	triangleDropper.gameGrid.connect("garbage_rows", self, "_on_gameGrid_garbage_rows")
	hud = HUD.instance()
	hud.set_position(Vector2(10, 100))
	hud.set_size(Vector2(1900, 780))
	add_child(hud)
	hud.connect("end_game", self, "_on_HUD_end_game")
	pausePopup = PausePopup.instance()
	add_child(pausePopup)
	pausePopup.connect("restart", self, "_on_PausePopup_restart")
	pausePopup.connect("back_to_menu", self, "_on_PausePopup_back_to_menu")
	fakeGrid = FakeGameGrid.instance()
	add_child(fakeGrid)
	fakeGrid.visible = false
	fakeGrid.initialize_grid()

func set_player(player: int):
	self.player = player

func set_multiplayer():
	scale = Vector2(0.8, 0.8)
	triangleDropper.set_multiplayer()
	hud.set_multiplayer()

func prep_take_your_time():
	triangleDropper.gameGrid.toggle_chain_mode(false)
	triangleDropper.gameGrid.set_gravity(0.2)
	hud.set_move_limit(60)
	hud.set_time_limit(0, 0)

func prep_gogogo():
	triangleDropper.gameGrid.toggle_chain_mode(true)
	triangleDropper.gameGrid.set_gravity(0.2)
	triangleDropper.connect("piece_sequence_advanced", self, "_on_triangleDropper_piece_sequence_advanced")
	hud.set_move_limit(0)
	hud.set_time_limit(0, 0)
	triangleDropper.enable_dropping()

func prep_dig():
	triangleDropper.gameGrid.toggle_chain_mode(true)
	triangleDropper.gameGrid.set_gravity(0.2)
	hud.set_time_limit(0, 0)
	triangleDropper.gameGrid.fill_bottom_rows(3)
	triangleDropper.gameGrid.digMode = true
	triangleDropper.gameGrid.draw_dig_line()
	triangleDropper.gameGrid.connect("garbage_rows", self, "_on_gameGrid_garbage_rows")
	triangleDropper.enable_dropping()

func set_config(config: ConfigFile):
	triangleDropper.set_das(config.get_value("tuning", "das"))
	triangleDropper.set_arr(config.get_value("tuning", "arr"))
	if player == 2:
		triangleDropper.set_device(config.get_value("controls", "p2_device"))
	else:
		triangleDropper.set_device(config.get_value("controls", "p1_device"))

func _input(event):
	if ((event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton)
	&& event.is_action_pressed("pause")):
		# Set pause menu to pause mode
		pausePopup.set_mode_pause()
		show_fake_grid()

func show_fake_grid():
	triangleDropper.visible = false
	hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer").visible = false
	fakeGrid.visible = true

func show_real_grid():
	triangleDropper.visible = true
	hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer").visible = true
	fakeGrid.visible = false

func get_chains():
	return hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").combos

func has_chain(chainKey):
	return hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").combos.has(chainKey)

func get_chain(chainKey) -> Dictionary:
	if hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").combos.has(chainKey):
		return hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").combos.get(chainKey)
	else:
		return {}

func upsert_chain(chainKey, chainValue, isLucky: bool):
	hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").upsert_combo(chainKey, chainValue, isLucky)

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
	#hud.get_node("HBoxContainer/VBoxContainer/ScoreDisplay").increment_score(1, false) Turned off because of hard drop

func _on_gameGrid_grid_full():
	_on_HUD_end_game()

func _on_gameGrid_garbage_rows():
	hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").move_combos_up()

func _on_HUD_end_game():
	#TODO sound sfx "game finished"
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

func _on_PausePopup_restart():
	emit_signal("restart")

func _on_PausePopup_back_to_menu():
	emit_signal("back_to_menu")