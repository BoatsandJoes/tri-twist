extends Node2D
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
	$PanelContainer/VBoxContainer/HBoxContainer/Header.text = "Paused"
	$PanelContainer/VBoxContainer/HBoxContainer2/Buttons/Resume.visible = true
	$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Resume.visible = true
	$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = "<"
	$PanelContainer/VBoxContainer/HBoxContainer2/Buttons/Restart.text = "Restart"
	$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = ""
	$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Settings.text = ""
	$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = ""
	self.visible = true
	get_parent().set_process_input(false)
	get_tree().paused = true

func set_mode_finished():
	$PanelContainer/VBoxContainer/HBoxContainer/Header.text = "Game Finished!"
	$PanelContainer/VBoxContainer/HBoxContainer2/Buttons/Resume.visible = false
	$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Resume.visible = false
	$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = ""
	$PanelContainer/VBoxContainer/HBoxContainer2/Buttons/Restart.text = "Try Again"
	$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = "<"
	$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = ""
	self.visible = true
	get_parent().set_process_input(false)
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _input(event):
	if ((event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton) && self.visible &&
	$PanelContainer/VBoxContainer.visible):
		if !event is InputEventMouseButton:
			get_tree().set_input_as_handled()
		if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel") || event.is_action_pressed("pause"):
			if $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Resume.visible:
				_on_Resume_pressed()
			else:
				_on_BackToMain_pressed()
		elif event.is_action_pressed("ui_up"):
			if $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Resume.text == "<":
				$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = ""
				$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = "<"
			elif $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Restart.text == "<":
				$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = ""
				if $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Resume.visible:
					$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = "<"
				else:
					$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = "<"
			elif $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Settings.text == "<":
				$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Settings.text = ""
				$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = "<"
			elif $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text == "<":
				$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = ""
				$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Settings.text = "<"
		elif event.is_action_pressed("ui_down"):
			if $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Resume.text == "<":
				$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = ""
				$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = "<"
			elif $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Restart.text == "<":
				$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = ""
				$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Settings.text = "<"
			elif $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Settings.text == "<":
				$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Settings.text = ""
				$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = "<"
			elif $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text == "<":
				$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = ""
				if $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Resume.visible:
					$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = "<"
				else:
					$PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = "<"
		elif event.is_action_pressed("ui_accept"):
			if $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Resume.text == "<":
				_on_Resume_pressed()
			elif $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Restart.text == "<":
				_on_Restart_pressed()
			elif $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/Settings.text == "<":
				_on_Settings_pressed()
			elif $PanelContainer/VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text == "<":
				_on_BackToMain_pressed()

func _on_Resume_pressed():
	self.visible = false
	get_tree().paused = false
	get_parent().set_process_input(true)
	get_parent().triangleDropper.update_active_piece_position()
	get_parent().show_real_grid()

func _on_Restart_pressed():
	get_tree().paused = false
	get_parent().set_process_input(true)
	emit_signal("restart")

func _on_Settings_pressed():
	$PanelContainer/VBoxContainer.visible = false
	settings_menu = Settings.instance()
	$PanelContainer.add_child(settings_menu)
	settings_menu.set_config(get_parent().get_parent().config, get_parent().get_parent().p1Device, get_parent().get_parent().p2Device)
	settings_menu.connect("back_to_menu", self, "_on_settings_menu_back_to_menu")
	settings_menu.connect("fullscreen", get_parent().get_parent(), "set_fullscreen")
	settings_menu.connect("windowed", get_parent().get_parent(), "set_windowed")

func _on_settings_menu_back_to_menu(updateConfig: bool, config: ConfigFile):
	if updateConfig:
		get_parent().get_parent().set_config(config)
	settings_menu.queue_free()
	$PanelContainer/VBoxContainer.visible = true

func _on_BackToMain_pressed():
	get_tree().paused = false
	emit_signal("back_to_menu")
