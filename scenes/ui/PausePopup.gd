extends CanvasLayer
class_name PausePopup

signal back_to_menu
signal restart

var finishedTimer: Timer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$PopupPanel.visible = false

func set_mode_pause():
	$PopupPanel/VBoxContainer/HBoxContainer/Header.text = "Paused"
	$PopupPanel/VBoxContainer/Buttons/Restart.text = "Restart"
	$PopupPanel.visible = true
	get_parent().set_process_input(false)
	get_tree().paused = true

func set_mode_finished():
	$PopupPanel/VBoxContainer/HBoxContainer/Header.text = "Game Finished!"
	$PopupPanel/VBoxContainer/Buttons/Resume.visible = false
	$PopupPanel.visible = true
	$PopupPanel/VBoxContainer/Buttons/Restart.text = "Try Again"
	get_parent().set_process_input(false)
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _input(event):
	if ((event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton) && $PopupPanel.visible &&
	$PopupPanel/VBoxContainer.visible):
		if !event is InputEventMouseButton:
			get_tree().set_input_as_handled()
		if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel") || event.is_action_pressed("pause"):
			if $PopupPanel/VBoxContainer/Buttons/Resume.visible:
				_on_Resume_pressed()
			else:
				_on_BackToMain_pressed()

func _on_Resume_pressed():
	$PopupPanel.visible = false
	get_tree().paused = false
	get_parent().set_process_input(true)
	get_parent().show_real_grid()

func _on_Restart_pressed():
	get_tree().paused = false
	get_parent().set_process_input(true)
	emit_signal("restart")

func _on_BackToMain_pressed():
	get_tree().paused = false
	emit_signal("back_to_menu")
