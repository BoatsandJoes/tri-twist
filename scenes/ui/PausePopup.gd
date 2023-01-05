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

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST && $PopupPanel.visible && $PopupPanel/VBoxContainer.visible:
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
