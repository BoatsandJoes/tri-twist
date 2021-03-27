extends PanelContainer
class_name PausePopup

signal back_to_menu
signal restart

var Settings = load("res://scenes/ui/mainMenu/Settings.tscn")
var settings_menu: Settings

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false

func set_mode_pause():
	$VBoxContainer/HBoxContainer/Header.text = "Paused"
	$VBoxContainer/HBoxContainer2/Buttons/Resume.visible = true
	$VBoxContainer/HBoxContainer2/SelectArrow/Resume.visible = true
	$VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = "<"
	$VBoxContainer/HBoxContainer2/Buttons/Restart.text = "Restart"
	$VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = ""
	$VBoxContainer/HBoxContainer2/SelectArrow/Settings.text = ""
	$VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = ""
	self.visible = true
	get_parent().set_process_input(false)
	get_tree().paused = true

func set_mode_finished():
	$VBoxContainer/HBoxContainer/Header.text = "Game Finished!"
	$VBoxContainer/HBoxContainer2/Buttons/Resume.visible = false
	$VBoxContainer/HBoxContainer2/SelectArrow/Resume.visible = false
	$VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = ""
	$VBoxContainer/HBoxContainer2/Buttons/Restart.text = "Try Again"
	$VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = "<"
	$VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = ""
	self.visible = true
	get_parent().set_process_input(false)
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _input(event):
	if ((event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton) && self.visible &&
	$VBoxContainer.visible):
		get_tree().set_input_as_handled()
		if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel") || event.is_action_pressed("pause"):
			if $VBoxContainer/HBoxContainer2/SelectArrow/Resume.visible:
				_on_Resume_pressed()
			else:
				_on_BackToMain_pressed()
		elif event.is_action_pressed("ui_up"):
			if $VBoxContainer/HBoxContainer2/SelectArrow/Resume.text == "<":
				$VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = ""
				$VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = "<"
			elif $VBoxContainer/HBoxContainer2/SelectArrow/Restart.text == "<":
				$VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = ""
				if $VBoxContainer/HBoxContainer2/SelectArrow/Resume.visible:
					$VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = "<"
				else:
					$VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = "<"
			elif $VBoxContainer/HBoxContainer2/SelectArrow/Settings.text == "<":
				$VBoxContainer/HBoxContainer2/SelectArrow/Settings.text = ""
				$VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = "<"
			elif $VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text == "<":
				$VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = ""
				$VBoxContainer/HBoxContainer2/SelectArrow/Settings.text = "<"
		elif event.is_action_pressed("ui_down"):
			if $VBoxContainer/HBoxContainer2/SelectArrow/Resume.text == "<":
				$VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = ""
				$VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = "<"
			elif $VBoxContainer/HBoxContainer2/SelectArrow/Restart.text == "<":
				$VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = ""
				$VBoxContainer/HBoxContainer2/SelectArrow/Settings.text = "<"
			elif $VBoxContainer/HBoxContainer2/SelectArrow/Settings.text == "<":
				$VBoxContainer/HBoxContainer2/SelectArrow/Settings.text = ""
				$VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = "<"
			elif $VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text == "<":
				$VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = ""
				if $VBoxContainer/HBoxContainer2/SelectArrow/Resume.visible:
					$VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = "<"
				else:
					$VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = "<"
		elif event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_select"):
			if $VBoxContainer/HBoxContainer2/SelectArrow/Resume.text == "<":
				_on_Resume_pressed()
			elif $VBoxContainer/HBoxContainer2/SelectArrow/Restart.text == "<":
				_on_Restart_pressed()
			elif $VBoxContainer/HBoxContainer2/SelectArrow/Settings.text == "<":
				_on_Settings_pressed()
			elif $VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text == "<":
				_on_BackToMain_pressed()

func _on_Resume_pressed():
	self.visible = false
	get_tree().paused = false
	get_parent().set_process_input(true)

func _on_Restart_pressed():
	get_tree().paused = false
	get_parent().set_process_input(true)
	emit_signal("restart")

func _on_Settings_pressed():
	$VBoxContainer.visible = false
	settings_menu = Settings.instance()
	add_child(settings_menu)
	settings_menu.set_das(get_parent().get_parent().das)
	settings_menu.set_arr(get_parent().get_parent().arr)
	settings_menu.set_fullscreen(get_parent().get_parent().fullscreen)
	settings_menu.connect("back_to_menu", self, "_on_settings_menu_back_to_menu")
	settings_menu.connect("fullscreen", get_parent().get_parent(), "set_fullscreen")
	settings_menu.connect("windowed", get_parent().get_parent(), "set_windowed")
	settings_menu.connect("das_changed", get_parent().get_parent(), "set_das")
	settings_menu.connect("arr_changed", get_parent().get_parent(), "set_arr")

func _on_settings_menu_back_to_menu():
	settings_menu.queue_free()
	$VBoxContainer.visible = true

func _on_BackToMain_pressed():
	get_tree().paused = false
	emit_signal("back_to_menu")
