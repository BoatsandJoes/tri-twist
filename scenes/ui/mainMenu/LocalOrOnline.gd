extends Control
class_name LocalOrOnline

signal offline
signal online
signal back

var SelectArrow = load("res://scenes/ui/elements/SelectArrow.tscn")
var selectArrow: SelectArrow
var timer: Timer
var offlineArrowPosition: Vector2
var onlineArrowPosition: Vector2
var backArrowPosition: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
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
	var offlineButtonPosition = $MarginContainer/VBoxContainer/Offline.rect_global_position
	var onlineButtonPosition = $MarginContainer/VBoxContainer/Online.rect_global_position
	var backButtonPosition = $MarginContainer/VBoxContainer/Back.rect_global_position
	var buttonWidthHeight = $MarginContainer/VBoxContainer/Offline.get_rect().size
	offlineArrowPosition = Vector2(offlineButtonPosition[0] + buttonWidthHeight[0], offlineButtonPosition[1] + buttonWidthHeight[1] / 2)
	onlineArrowPosition = Vector2(onlineButtonPosition[0] + buttonWidthHeight[0], onlineButtonPosition[1] + buttonWidthHeight[1] / 2)
	backArrowPosition = Vector2(backButtonPosition[0] + buttonWidthHeight[0], backButtonPosition[1] + buttonWidthHeight[1] / 2)
	select_offline()
	selectArrow.visible = true
	timer.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func select_offline():
	selectArrow.position = offlineArrowPosition

func select_online():
	selectArrow.position = onlineArrowPosition

func select_exit():
	selectArrow.position = backArrowPosition

func _input(event):
	if ($MarginContainer.visible && (event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton)):
		if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel"):
			_on_Back_pressed()
		elif event.is_action_pressed("ui_up"):
			if offline_selected():
				select_exit()
			elif online_selected():
				select_offline()
			elif back_selected():
				select_online()
		elif event.is_action_pressed("ui_down"):
			if offline_selected():
				select_online()
			elif online_selected():
				select_exit()
			elif back_selected():
				select_offline()
		elif event.is_action_pressed("ui_accept"):
			if offline_selected():
				_on_Offline_pressed()
			elif online_selected():
				_on_Online_pressed()
			elif back_selected():
				_on_Back_pressed()

func offline_selected():
	return selectArrow.position == offlineArrowPosition

func online_selected():
	return selectArrow.position == onlineArrowPosition

func back_selected():
	return selectArrow.position == backArrowPosition

func _on_Back_pressed():
	emit_signal("back")

func _on_Offline_pressed():
	emit_signal("offline")
	
func _on_Online_pressed():
	emit_signal("online")