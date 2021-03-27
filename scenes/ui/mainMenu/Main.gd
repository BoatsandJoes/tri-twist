extends Control
class_name Main

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var TitleScreen = load("res://scenes/ui/mainMenu/TitleScreen.tscn")
var MainMenu = load("res://scenes/ui/mainMenu/MainMenu.tscn")
var ModeSelect = load("res://scenes/ui/mainMenu/ModeSelect.tscn")
var Settings = load("res://scenes/ui/mainMenu/Settings.tscn")
var Credits = load("res://scenes/ui/mainMenu/Credits.tscn")
var TakeYourTime = load("res://scenes/modes/TakeYourTime.tscn")
var GoGoGo = load("res://scenes/modes/GoGoGo.tscn")
var DigMode = load("res://scenes/modes/DigMode.tscn")
var Triathalon = load("res://scenes/modes/Triathalon.tscn")
var background: ColorRect
var menu
var game
var vp
var base_size = Vector2(1920, 1080)
var config: ConfigFile

# Called when the node enters the scene tree for the first time.
func _ready():
	load_config_from_filesystem()
	initialize_display()
	# TODO sound music start playing menu music
	go_to_title()

func initialize_display():
	# Set resolution
	vp = get_tree().get_root()
	if config.get_value("video", "fullscreen"):
		set_fullscreen()
	else:
		set_windowed()

func load_config_from_filesystem():
	config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if !config.has_section_key("video", "fullscreen"):
		config.set_value("video", "fullscreen", true)
	if !config.has_section_key("tuning", "das"):
		config.set_value("tuning", "das", 12)
	if !config.has_section_key("tuning", "arr"):
		config.set_value("tuning", "arr", 3)
	if err != OK: # If not, something went wrong with the file loading
		# Save to filesystem for the first time.
		config.save("user://settings.cfg")

func set_config(config: ConfigFile):
	self.config = config
	if is_instance_valid(game):
		game.set_config(config)

# Got these methods from reddit user leanderish: thanks!
func set_fullscreen():
	config.set_value("video", "fullscreen", true)
	var window_size = OS.get_screen_size()
	
	if OS.get_name() == 'Windows' && window_size == base_size:
                # Not sure if this works outside of Windows / native resolution.
                #  - Mac didn't like it, nor smaller resolutions.
		OS.set_window_fullscreen(true)
	
	else:
		var scale = min(window_size.x / base_size.x, window_size.y / base_size.y)
		var scaled_size = (base_size * scale).round()
		
		var margins = Vector2(window_size.x - scaled_size.x, window_size.y - scaled_size.y)
		var screen_rect = Rect2((margins / 2).round(), scaled_size)
		
		OS.set_borderless_window(true)
		OS.set_window_position(OS.get_screen_position())
		OS.set_window_size(Vector2(window_size.x, window_size.y + 1)) # Black magic?
		vp.set_size(scaled_size) # Not sure this is strictly necessary
		vp.set_attach_to_screen_rect(screen_rect)

func set_windowed():
	config.set_value("video", "fullscreen", false)
	var window_size = OS.get_screen_size()
        # I set the windowed version to an arbitrary 80% of screen size here
	var scale = min(window_size.x / base_size.x, window_size.y / base_size.y) * 0.8
	var scaled_size = (base_size * scale).round()
	
	var window_x = (window_size.x / 2) - (scaled_size.x / 2)
	var window_y = (window_size.y / 2) - (scaled_size.y / 2)
	OS.set_borderless_window(false)
	OS.set_window_fullscreen(false)
	OS.set_window_position(Vector2(window_x, window_y))
	OS.set_window_size(scaled_size)
	vp.set_size(scaled_size)

func exit_game():
	get_tree().quit()

func go_to_title():
	if is_instance_valid(menu):
		menu.queue_free()
	if is_instance_valid(game):
		game.queue_free()
	menu = TitleScreen.instance()
	add_child(menu)
	menu.connect("start", self, "_on_TitleScreen_start")
	menu.connect("exit", self, "_on_TitleScreen_exit")

func go_to_main_menu():
	if is_instance_valid(menu):
		menu.queue_free()
	if is_instance_valid(game):
		game.queue_free()
	menu = MainMenu.instance()
	add_child(menu)
	menu.connect("play", self, "_on_MainMenu_play")
	menu.connect("settings", self, "_on_MainMenu_settings")
	menu.connect("credits", self, "_on_MainMenu_credits")
	menu.connect("back_to_title", self, "_on_MainMenu_back_to_title")
	menu.connect("exit", self, "_on_MainMenu_exit")

func go_to_settings():
	if is_instance_valid(menu):
		menu.queue_free()
	if is_instance_valid(game):
		game.queue_free()
	menu = Settings.instance()
	add_child(menu)
	menu.set_config(config)
	menu.connect("back_to_menu", self, "_on_Settings_back_to_menu")
	menu.connect("windowed", self, "set_windowed")
	menu.connect("fullscreen", self, "set_fullscreen")

func go_to_credits():
	if is_instance_valid(menu):
		menu.queue_free()
	if is_instance_valid(game):
		game.queue_free()
	menu = Credits.instance()
	add_child(menu)
	menu.connect("back_to_menu", self, "_on_Credits_back_to_menu")

func go_to_mode_select():
	if is_instance_valid(menu):
		menu.queue_free()
	if is_instance_valid(game):
		game.queue_free()
		#TODO sound music if gogogo music is playing, stop playing it
		#TODO sound music if take your time/menu music is not already playing, start playing menu music
	menu = ModeSelect.instance()
	add_child(menu)
	menu.connect("take_your_time", self, "_on_ModeSelect_take_your_time")
	menu.connect("gogogo", self, "_on_ModeSelect_gogogo")
	menu.connect("dig_mode", self, "_on_ModeSelect_dig_mode")
	menu.connect("triathalon", self, "_on_ModeSelect_triathalon")
	menu.connect("back", self, "_on_ModeSelect_back")

func go_to_take_your_time_mode():
	if is_instance_valid(menu):
		menu.queue_free()
		# We would start playing take your time music here, but currently thinking it will be the same as the menu music
	if is_instance_valid(game):
		game.queue_free()
	game = TakeYourTime.instance()
	add_child(game)
	set_config_for_game_scene()
	game.connect("back_to_menu", self, "_on_game_back_to_menu")
	game.connect("restart", self, "go_to_take_your_time_mode")

func go_to_gogogo_mode():
	if is_instance_valid(menu):
		menu.queue_free()
		#TODO sound music stop playing menu music
		#TODO sound music start playing gogogo music
	if is_instance_valid(game):
		game.queue_free()
	game = GoGoGo.instance()
	add_child(game)
	set_config_for_game_scene()
	game.connect("back_to_menu", self, "_on_game_back_to_menu")
	game.connect("restart", self, "go_to_gogogo_mode")

func go_to_dig_mode():
	if is_instance_valid(menu):
		menu.queue_free()
		#TODO sound music stop playing menu music
		#TODO sound music start playing dig mode music
	if is_instance_valid(game):
		game.queue_free()
	game = DigMode.instance()
	add_child(game)
	set_config_for_game_scene()
	game.connect("back_to_menu", self, "_on_game_back_to_menu")
	game.connect("restart", self, "go_to_dig_mode")

func go_to_triathalon_mode():
	if is_instance_valid(menu):
		menu.queue_free()
		# We would start playing take your time music here, but currently thinking it will be the same as the menu music
	if is_instance_valid(game):
		game.queue_free()
	game = Triathalon.instance()
	add_child(game)
	set_config_for_game_scene()
	game.connect("back_to_menu", self, "_on_game_back_to_menu")
	game.connect("restart", self, "go_to_triathalon_mode")

func set_config_for_game_scene():
	game.set_config(config)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_TitleScreen_start():
	go_to_main_menu()

func _on_TitleScreen_exit():
	exit_game()

func _on_MainMenu_exit():
	exit_game()

func _on_MainMenu_play():
	go_to_mode_select()

func _on_MainMenu_settings():
	go_to_settings()

func _on_MainMenu_credits():
	go_to_credits()

func _on_MainMenu_back_to_title():
	go_to_title()

func _on_Settings_back_to_menu(updateConfig: bool, config: ConfigFile):
	if updateConfig:
		self.config = config
	go_to_main_menu()

func _on_Credits_back_to_menu():
	go_to_main_menu()

func _on_ModeSelect_take_your_time():
	go_to_take_your_time_mode()

func _on_ModeSelect_gogogo():
	go_to_gogogo_mode()

func _on_ModeSelect_dig_mode():
	go_to_dig_mode()

func _on_ModeSelect_triathalon():
	go_to_triathalon_mode()

func _on_ModeSelect_back():
	go_to_main_menu()

func _on_game_back_to_menu():
	go_to_mode_select()