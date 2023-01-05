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
var pieceSequence: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pausePopup = PausePopup.instance()
	add_child(pausePopup)
	pausePopup.connect("restart", self, "_on_PausePopup_restart")
	pausePopup.connect("back_to_menu", self, "_on_PausePopup_back_to_menu")
	fakeGrid = FakeGameGrid.instance()
	add_child(fakeGrid)
	fakeGrid.visible = false
	fakeGrid.initialize_grid(1920, 1080)
	randomize()
	triangleDropper = TriangleDropper.instance()
	add_child(triangleDropper)
	var pieceSequence: PoolIntArray = []
	for i in range(1000):
		pieceSequence.append(randi() % 4)
		pieceSequence.append(randi() % 4)
		pieceSequence.append(randi() % 4)
	triangleDropper.init()
	triangleDropper.set_piece_sequence(pieceSequence)
	triangleDropper.set_previews_visible(3)
	triangleDropper.connect("piece_sequence_advanced", self, "_on_triangleDropper_piece_sequence_advanced")
	triangleDropper.gameGrid.connect("grid_full", self, "_on_gameGrid_grid_full")
	triangleDropper.gameGrid.connect("garbage_rows", self, "_on_gameGrid_garbage_rows")
	triangleDropper.gameGrid.connect("erase_chain", self, "delete_chain")
	triangleDropper.gameGrid.connect("end_combo_if_exists", self, "end_combo_if_exists")
	hud = HUD.instance()
	hud.set_position(Vector2(10, 100))
	hud.set_size(Vector2(1900, 830))
	add_child(hud)
	hud.connect("end_game", self, "_on_HUD_end_game")

func prep_dig():
	triangleDropper.gameGrid.set_gravity(0.2)
	hud.set_time_limit(2, 0)
	triangleDropper.gameGrid.fill_bottom_rows(3)
	triangleDropper.gameGrid.set_dig_mode()
	triangleDropper.gameGrid.draw_dig_line()
	triangleDropper.gameGrid.connect("garbage_rows", self, "_on_gameGrid_garbage_rows")
	triangleDropper.enable_dropping()

func set_config(config: ConfigFile):
	triangleDropper.gameGrid.set_volume(config.get_value("audio", "volume"))

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
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

func _on_gameGrid_grid_full():
	_on_HUD_end_game()

func _on_gameGrid_garbage_rows():
	hud.get_node("HBoxContainer/VBoxContainer/HBoxContainer/ComboDisplay").move_combos_up()

func _on_HUD_end_game():
	#TODO sound sfx "game finished"
	# Freeze input
	triangleDropper.set_process_input(false)
	# Clear all chains.
	triangleDropper.gameGrid.set_off_chains()
	var timer = Timer.new()
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	timer.start(0.5)

func _on_timer_timeout():
	# Set pause menu to game end mode
	pausePopup.set_mode_finished()

func _on_PausePopup_restart():
	emit_signal("restart")

func _on_PausePopup_back_to_menu():
	emit_signal("back_to_menu")
