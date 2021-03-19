extends Control
class_name Main

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var TitleScreen = load("res://scenes/ui/mainMenu/TitleScreen.tscn")
var MainMenu = load("res://scenes/ui/mainMenu/MainMenu.tscn")
var ModeSelect = load("res://scenes/ui/mainMenu/ModeSelect.tscn")
var Credits = load("res://scenes/ui/mainMenu/Credits.tscn")
var TakeYourTime = load("res://scenes/modes/TakeYourTime.tscn")
var GoGoGo = load("res://scenes/modes/GoGoGo.tscn")
var DigMode = load("res://scenes/modes/DigMode.tscn")
var menu
var game

# Called when the node enters the scene tree for the first time.
func _ready():
	go_to_title()

func exit_game():
	get_tree().quit()

func go_to_title():
	if menu != null && weakref(menu).get_ref():
		menu.queue_free()
	if game != null && weakref(game).get_ref():
		game.queue_free()
	menu = TitleScreen.instance()
	add_child(menu)
	menu.connect("start", self, "_on_TitleScreen_start")
	menu.connect("exit", self, "_on_TitleScreen_exit")

func go_to_main_menu():
	if menu != null && weakref(menu).get_ref():
		menu.queue_free()
	if game != null && weakref(game).get_ref():
		game.queue_free()
	menu = MainMenu.instance()
	add_child(menu)
	menu.connect("play", self, "_on_MainMenu_play")
	menu.connect("settings", self, "_on_MainMenu_settings")
	menu.connect("credits", self, "_on_MainMenu_credits")
	menu.connect("back_to_title", self, "_on_MainMenu_back_to_title")
	menu.connect("exit", self, "_on_MainMenu_exit")

func go_to_credits():
	if menu != null && weakref(menu).get_ref():
		menu.queue_free()
	if game != null && weakref(game).get_ref():
		game.queue_free()
	menu = Credits.instance()
	add_child(menu)
	menu.connect("back_to_menu", self, "_on_Credits_back_to_menu")

func go_to_mode_select():
	if menu != null && weakref(menu).get_ref():
		menu.queue_free()
	if game != null && weakref(game).get_ref():
		game.queue_free()
	menu = ModeSelect.instance()
	add_child(menu)
	menu.connect("take_your_time", self, "_on_ModeSelect_take_your_time")
	menu.connect("gogogo", self, "_on_ModeSelect_gogogo")
	menu.connect("dig_mode", self, "_on_ModeSelect_dig_mode")
	menu.connect("back", self, "_on_ModeSelect_back")

func go_to_take_your_time_mode():
	if menu != null && weakref(menu).get_ref():
		menu.queue_free()
	if game != null && weakref(game).get_ref():
		game.queue_free()
	game = TakeYourTime.instance()
	add_child(game)
	game.connect("back_to_menu", self, "_on_game_back_to_menu")
	game.connect("restart", self, "go_to_take_your_time_mode")

func go_to_gogogo_mode():
	if menu != null && weakref(menu).get_ref():
		menu.queue_free()
	if game != null && weakref(game).get_ref():
		game.queue_free()
	game = GoGoGo.instance()
	add_child(game)
	game.connect("back_to_menu", self, "_on_game_back_to_menu")
	game.connect("restart", self, "go_to_gogogo_mode")

func go_to_dig_mode():
	if menu != null && weakref(menu).get_ref():
		menu.queue_free()
	if game != null && weakref(game).get_ref():
		game.queue_free()
	game = DigMode.instance()
	add_child(game)
	game.connect("back_to_menu", self, "_on_game_back_to_menu")
	game.connect("restart", self, "go_to_dig_mode")

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
	pass

func _on_MainMenu_credits():
	go_to_credits()

func _on_MainMenu_back_to_title():
	go_to_title()

func _on_Credits_back_to_menu():
	go_to_main_menu()

func _on_ModeSelect_take_your_time():
	go_to_take_your_time_mode()

func _on_ModeSelect_gogogo():
	go_to_gogogo_mode()

func _on_ModeSelect_dig_mode():
	go_to_dig_mode()

func _on_ModeSelect_back():
	go_to_main_menu()

func _on_game_back_to_menu():
	go_to_mode_select()