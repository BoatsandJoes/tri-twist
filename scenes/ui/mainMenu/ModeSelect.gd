extends Control
class_name ModeSelect

signal back
signal take_your_time
signal gogogo
signal dig_mode
signal triathalon

var SelectArrow = load("res://scenes/ui/elements/SelectArrow.tscn")
var selectArrow: SelectArrow
var ModeMenu = load("res://scenes/ui/mainMenu/ModeMenu.tscn")
var modeMenu: ModeMenu
var timer: Timer
var digArrowPosition: Vector2
var timeArrowPosition: Vector2
var goArrowPosition: Vector2
var triathalonArrowPosition: Vector2
var backArrowPosition: Vector2
var p1Device
var p2Device
var config: ConfigFile
var isConfigChanged: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/HBoxContainer/VBoxContainer2/HowToPlayBasic.set_text("Match colors to clear triangles\n\n\n\n\n\n\n\n\n\n\n\n\n",
	"Keep matching to make chains!")
	var startingDemoState: Dictionary = {}
	startingDemoState["currentPieceIndex"] = 4
	startingDemoState["activePieceColumnIndex"] = 2
	var colors: PoolIntArray = []
	for rowIndex in range(3):
		for cellIndex in range(7):
			colors.append(4)
			colors.append(4)
			colors.append(4)
	startingDemoState["boardColors"] = colors
	var pieceSequence: PoolIntArray = PoolIntArray()
	pieceSequence.append(2)
	pieceSequence.append(1)
	pieceSequence.append(1)
	pieceSequence.append(0)
	pieceSequence.append(1)
	pieceSequence.append(0)
	pieceSequence.append(1)
	pieceSequence.append(3)
	pieceSequence.append(3)
	pieceSequence.append(2)
	pieceSequence.append(3)
	pieceSequence.append(0)
	pieceSequence.append(1)
	pieceSequence.append(1)
	pieceSequence.append(1)
	$MarginContainer/HBoxContainer/VBoxContainer2/HowToPlayBasic.set_demo(startingDemoState,
	[[1, "soft_drop"],[1, "move_piece_right"],[1, "soft_drop"],[2, "soft_drop"],[2, "rotate_clockwise"],
	[1, "soft_drop"],[5,"restart"]], pieceSequence)
	selectArrow = SelectArrow.instance()
	add_child(selectArrow)
	selectArrow.visible = false
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "_on_timer_timeout")
	# Wait to make sure that buttons have resized.
	timer.start(0.01)

func init(p1Device, p2Device, config):
	self.p1Device = p1Device
	self.p2Device = p2Device
	self.config = config

func create_popup():
	$MarginContainer.visible = false
	selectArrow.visible = false
	modeMenu = ModeMenu.instance()
	add_child(modeMenu)
	modeMenu.init(p1Device, p2Device, config)
	modeMenu.connect("back_to_menu", self, "_on_modeMenu_back_to_menu")

func _on_timer_timeout():
	var digButtonPosition = $MarginContainer/HBoxContainer/VBoxContainer/DigMode.rect_global_position
	var timeButtonPosition = $MarginContainer/HBoxContainer/VBoxContainer/TakeYourTime.rect_global_position
	var goButtonPosition = $MarginContainer/HBoxContainer/VBoxContainer/GoGoGo.rect_global_position
	var triathalonButtonPosition = $MarginContainer/HBoxContainer/VBoxContainer/Triathalon.rect_global_position
	var backButtonPosition = $MarginContainer/HBoxContainer/VBoxContainer/Back.rect_global_position
	var buttonWidthHeight = $MarginContainer/HBoxContainer/VBoxContainer/DigMode.get_rect().size
	digArrowPosition = Vector2(digButtonPosition[0] + buttonWidthHeight[0], digButtonPosition[1] + buttonWidthHeight[1] / 2)
	timeArrowPosition = Vector2(timeButtonPosition[0] + buttonWidthHeight[0], timeButtonPosition[1] + buttonWidthHeight[1] / 2)
	goArrowPosition = Vector2(goButtonPosition[0] + buttonWidthHeight[0], goButtonPosition[1] + buttonWidthHeight[1] / 2)
	triathalonArrowPosition = Vector2(triathalonButtonPosition[0] + buttonWidthHeight[0],
	triathalonButtonPosition[1] + buttonWidthHeight[1] / 2)
	backArrowPosition = Vector2(backButtonPosition[0] + buttonWidthHeight[0], backButtonPosition[1] + buttonWidthHeight[1] / 2)
	select_dig_deep()
	selectArrow.visible = true
	timer.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func select_dig_deep():
	selectArrow.position = digArrowPosition

func select_take_your_time():
	selectArrow.position = timeArrowPosition

func select_gogogo():
	selectArrow.position = goArrowPosition

func select_triathalon():
	selectArrow.position = triathalonArrowPosition

func select_exit():
	selectArrow.position = backArrowPosition

func _input(event):
	if ($MarginContainer.visible && (event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton)):
		if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel"):
			_on_Back_pressed()
		elif event.is_action_pressed("ui_up"):
			if dig_selected():
				select_exit()
			elif time_selected():
				select_dig_deep()
			elif go_selected():
				select_take_your_time()
			elif triathalon_selected():
				select_gogogo()
			elif back_selected():
				select_triathalon()
		elif event.is_action_pressed("ui_down"):
			if dig_selected():
				select_take_your_time()
			elif time_selected():
				select_gogogo()
			elif go_selected():
				select_triathalon()
			elif triathalon_selected():
				select_exit()
			elif back_selected():
				select_dig_deep()
		elif event.is_action_pressed("ui_accept"):
			if time_selected():
				_on_TakeYourTime_pressed()
			elif go_selected():
				_on_GoGoGo_pressed()
			elif dig_selected():
				_on_DigMode_pressed()
			elif triathalon_selected():
				_on_Triathalon_pressed()
			elif back_selected():
				_on_Back_pressed()

func dig_selected():
	return selectArrow.position == digArrowPosition

func time_selected():
	return selectArrow.position == timeArrowPosition

func go_selected():
	return selectArrow.position == goArrowPosition

func triathalon_selected():
	return selectArrow.position == triathalonArrowPosition

func back_selected():
	return selectArrow.position == backArrowPosition

func _on_modeMenu_back_to_menu(config, isConfigChanged, p1Device, p2Device):
	if isConfigChanged:
		self.config = config
		self.isConfigChanged = true
	self.p1Device = p1Device
	self.p2Device = p2Device
	modeMenu.queue_free()
	$MarginContainer.visible = true
	selectArrow.visible = true

func _on_Back_pressed():
	emit_signal("back", config, isConfigChanged, p1Device, p2Device)

func _on_TakeYourTime_pressed():
	create_popup()
	modeMenu.set_label("Take Your Time")
	modeMenu.connect("start", self, "_on_TakeYourTime_start")

func _on_GoGoGo_pressed():
	create_popup()
	modeMenu.set_label("Go Go Go")
	modeMenu.connect("start", self, "_on_GoGoGo_start")

func _on_DigMode_pressed():
	create_popup()
	modeMenu.set_label("Dig Deep")
	modeMenu.connect("start", self, "_on_DigMode_start")

func _on_Triathalon_pressed():
	create_popup()
	modeMenu.set_label("Triathalon")
	modeMenu.connect("start", self, "_on_Triathalon_start")

func _on_TakeYourTime_start(p1Device, p2Device, config, isConfigChanged):
	self.p1Device = p1Device
	self.p2Device = p2Device
	if p1Device == "CPU":
		p1Device = p2Device
	emit_signal("take_your_time", p1Device, config, isConfigChanged)

func _on_GoGoGo_start(p1Device, p2Device, config, isConfigChanged):
	self.p1Device = p1Device
	self.p2Device = p2Device
	if p1Device == "CPU":
		p1Device = p2Device
	emit_signal("gogogo", p1Device, config, isConfigChanged)

func _on_DigMode_start(p1Device, p2Device, config, isConfigChanged):
	self.p1Device = p1Device
	self.p2Device = p2Device
	if p1Device == "CPU":
		p1Device = p2Device
	emit_signal("dig_mode", p1Device, config, isConfigChanged)

func _on_Triathalon_start(p1Device, p2Device, config, isConfigChanged):
	self.p1Device = p1Device
	self.p2Device = p2Device
	if p1Device == "CPU":
		p1Device = p2Device
	emit_signal("triathalon", p1Device, config, isConfigChanged)
