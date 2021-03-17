extends Panel
class_name PausePopup

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	pause_mode = Node.PAUSE_MODE_PROCESS

func set_mode_pause():
	$VBoxContainer/HBoxContainer/Header.text = "Paused"
	$VBoxContainer/HBoxContainer2/Buttons/Resume.visible = true
	$VBoxContainer/HBoxContainer2/SelectArrow/Resume.visible = true
	$VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = "<"
	$VBoxContainer/HBoxContainer2/Buttons/Restart.text = "Restart"
	$VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = ""
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
	if event is InputEventKey && self.visible:
		if event.is_action_pressed("ui_escape"):
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
			elif $VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text == "<":
				$VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = ""
				$VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = "<"
		elif event.is_action_pressed("ui_down"):
			if $VBoxContainer/HBoxContainer2/SelectArrow/Resume.text == "<":
				$VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = ""
				$VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = "<"
			elif $VBoxContainer/HBoxContainer2/SelectArrow/Restart.text == "<":
				$VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = ""
				$VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = "<"
			elif $VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text == "<":
				$VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text = ""
				if $VBoxContainer/HBoxContainer2/SelectArrow/Resume.visible:
					$VBoxContainer/HBoxContainer2/SelectArrow/Resume.text = "<"
				else:
					$VBoxContainer/HBoxContainer2/SelectArrow/Restart.text = "<"
		elif event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_select"):
			get_tree().set_input_as_handled()
			if $VBoxContainer/HBoxContainer2/SelectArrow/Resume.text == "<":
				_on_Resume_pressed()
			elif $VBoxContainer/HBoxContainer2/SelectArrow/Restart.text == "<":
				_on_Restart_pressed()
			elif $VBoxContainer/HBoxContainer2/SelectArrow/BackToMain.text == "<":
				_on_BackToMain_pressed()

func _on_Resume_pressed():
	self.visible = false
	get_tree().paused = false
	get_parent().set_process_input(true)

func _on_Restart_pressed():
	get_tree().paused = false
	get_parent().set_process_input(true)
	get_tree().reload_current_scene()

func _on_BackToMain_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://scenes/ui/MainMenu.tscn")
