extends CanvasLayer
class_name PausePopup

signal back_to_menu
signal restart

var SelectArrow = load("res://scenes/ui/elements/SelectArrow.tscn")
var selectArrow: SelectArrow
var resumeArrowPosition: Vector2
var restartArrowPosition: Vector2
var backToMainArrowPosition: Vector2
var timer: Timer
var finishedTimer: Timer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$PopupPanel.visible = false
	selectArrow = SelectArrow.instance()
	add_child(selectArrow)
	selectArrow.visible = false
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "_on_timer_timeout")
	# Wait to make sure that buttons have resized.
	timer.start(0.01)

func _on_timer_timeout():
	set_arrow_positions()
	timer.queue_free()

func set_arrow_positions():
	var resumeButtonPosition = $PopupPanel/VBoxContainer/Buttons/Resume.rect_global_position
	var restartButtonPosition = $PopupPanel/VBoxContainer/Buttons/Restart.rect_global_position
	var backToMainButtonPosition = $PopupPanel/VBoxContainer/Buttons/BackToMain.rect_global_position
	var buttonWidthHeight = $PopupPanel/VBoxContainer/Buttons/BackToMain.get_rect().size
	if $PopupPanel/VBoxContainer/Buttons/Resume.visible:
		resumeArrowPosition = Vector2(resumeButtonPosition[0] + buttonWidthHeight[0], resumeButtonPosition[1] + buttonWidthHeight[1] / 2)
	else:
		resumeArrowPosition = Vector2(0,0)
	restartArrowPosition = Vector2(restartButtonPosition[0] + buttonWidthHeight[0], restartButtonPosition[1] + buttonWidthHeight[1] / 2)
	backToMainArrowPosition = Vector2(backToMainButtonPosition[0] + buttonWidthHeight[0], backToMainButtonPosition[1] + buttonWidthHeight[1] / 2)

func set_mode_pause():
	$PopupPanel/VBoxContainer/HBoxContainer/Header.text = "Paused"
	selectArrow.visible = true
	set_arrow_positions()
	select_resume()
	$PopupPanel/VBoxContainer/Buttons/Restart.text = "Restart"
	$PopupPanel.visible = true
	get_parent().set_process_input(false)
	get_tree().paused = true

func set_mode_finished():
	$PopupPanel/VBoxContainer/HBoxContainer/Header.text = "Game Finished!"
	$PopupPanel/VBoxContainer/Buttons/Resume.visible = false
	$PopupPanel.visible = true
	finishedTimer = Timer.new()
	add_child(finishedTimer)
	finishedTimer.one_shot = true
	finishedTimer.connect("timeout", self, "_on_finishedTimer_timeout")
	# Wait to make sure that buttons have resized.
	finishedTimer.start(0.01)

func _on_finishedTimer_timeout():
	selectArrow.visible = true
	$PopupPanel/VBoxContainer/Buttons/Restart.text = "Try Again"
	set_arrow_positions()
	select_restart()
	get_parent().set_process_input(false)
	get_tree().paused = true
	finishedTimer.queue_free()

func select_resume():
	selectArrow.position = resumeArrowPosition

func select_restart():
	selectArrow.position = restartArrowPosition

func select_back_to_main():
	selectArrow.position = backToMainArrowPosition

func is_resume_selected():
	return selectArrow.position == resumeArrowPosition

func is_restart_selected():
	return selectArrow.position == restartArrowPosition

func is_back_to_main_selected():
	return selectArrow.position == backToMainArrowPosition

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
		elif event.is_action_pressed("ui_up"):
			if is_resume_selected():
				select_back_to_main()
			elif is_restart_selected():
				if $PopupPanel/VBoxContainer/Buttons/Resume.visible:
					select_resume()
				else:
					select_back_to_main()
			elif is_back_to_main_selected():
				select_restart()
		elif event.is_action_pressed("ui_down"):
			if is_resume_selected():
				select_restart()
			elif is_restart_selected():
				select_back_to_main()
			elif is_back_to_main_selected():
				if $PopupPanel/VBoxContainer/Buttons/Resume.visible:
					select_resume()
				else:
					select_restart()
		elif event.is_action_pressed("ui_accept"):
			if is_resume_selected():
				_on_Resume_pressed()
			elif is_restart_selected():
				_on_Restart_pressed()
			elif is_back_to_main_selected():
				_on_BackToMain_pressed()

func _on_Resume_pressed():
	$PopupPanel.visible = false
	selectArrow.visible = false
	get_tree().paused = false
	get_parent().set_process_input(true)
	get_parent().triangleDropper.update_active_piece_position()
	get_parent().show_real_grid()

func _on_Restart_pressed():
	get_tree().paused = false
	get_parent().set_process_input(true)
	emit_signal("restart")

func _on_BackToMain_pressed():
	get_tree().paused = false
	emit_signal("back_to_menu")
