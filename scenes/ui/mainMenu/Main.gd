extends Control
class_name Main

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var TitleScreen = load("res://scenes/ui/mainMenu/TitleScreen.tscn")
var MainMenu = load("res://scenes/ui/mainMenu/MainMenu.tscn")
var Credits = load("res://scenes/ui/mainMenu/Credits.tscn")
var DigMode = load("res://scenes/modes/DigMode.tscn")
var background: ColorRect
var menu
var game
var vp
var base_size = Vector2(1920, 1080)
var config: ConfigFile
var restartTimer: Timer
var isConfigChanged = false

# Called when the node enters the scene tree for the first time.
func _ready():
	load_config_from_filesystem()
	# TODO sound music start playing menu music
	go_to_main_menu()

func load_config_from_filesystem():
	config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if !config.has_section_key("audio", "volume"):
		config.set_value("audio", "volume", 50)
	if err != OK: # If not, something went wrong with the file loading
		# Save to filesystem for the first time.
		config.save("user://settings.cfg")

func set_config(config: ConfigFile):
	self.config = config
	if is_instance_valid(game):
		game.set_config(config)

func exit_game():
	get_tree().quit()

func go_to_main_menu():
	if is_instance_valid(menu):
		menu.queue_free()
	if is_instance_valid(game):
		game.queue_free()
	menu = MainMenu.instance()
	menu.set_volume(config.get_value("audio", "volume"))
	add_child(menu)
	menu.connect("play", self, "_on_MainMenu_play")
	menu.connect("credits", self, "_on_MainMenu_credits")
	menu.connect("exit", self, "_on_MainMenu_exit")
	menu.connect("volume", self, "_on_MainMenu_volume")

func go_to_credits():
	if is_instance_valid(menu):
		menu.queue_free()
	if is_instance_valid(game):
		game.queue_free()
	menu = Credits.instance()
	add_child(menu)
	menu.connect("back_to_menu", self, "_on_Credits_back_to_menu")

func go_to_dig_mode():
	if is_instance_valid(menu):
		menu.queue_free()
		#TODO sound music stop playing menu music
		#TODO sound music start playing dig mode music
	if is_instance_valid(game):
		game.queue_free()
		restartTimer = Timer.new()
		add_child(restartTimer)
		restartTimer.wait_time = 0.01
		restartTimer.one_shot = true
		restartTimer.connect("timeout", self, "actually_go_to_dig")
		restartTimer.start()
	else:
		actually_go_to_dig()

func actually_go_to_dig():
	if is_instance_valid(restartTimer):
		restartTimer.queue_free()
	game = DigMode.instance()
	add_child(game)
	set_config_for_game_scene()
	game.connect("back_to_menu", self, "_on_game_back_to_menu")
	game.connect("restart", self, "go_to_dig_mode")

func set_config_for_game_scene():
	game.set_config(config)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_MainMenu_exit():
	exit_game()

func _on_MainMenu_play():
	if isConfigChanged:
		self.config = config
		config.save("user://settings.cfg")
		isConfigChanged = false
	go_to_dig_mode()

func _on_MainMenu_volume(volume: int):
	self.config.set_value("audio", "volume", volume)
	isConfigChanged = true

func _on_MainMenu_credits():
	go_to_credits()

func _on_Credits_back_to_menu():
	go_to_main_menu()

func _on_game_back_to_menu():
	go_to_main_menu()
