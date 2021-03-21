extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal out_of_time

var currentTime: float = 0.0
var incrementing: bool = true
var warningsLeft = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(minutes: int, seconds: int):
	incrementing = minutes == 0 && seconds == 0
	if !incrementing:
		currentTime = minutes * 60.0 + seconds
	update_time_string()

func update_time_string():
	var currentTimeInt: int = int(currentTime)
	var minutes: int = currentTimeInt / 60
	if minutes > 99:
		return "99:59.99"
	var seconds: int = currentTimeInt % 60
	var centisecondsString: String = ("%.2f" % currentTime)
	$VBoxContainer/TimeValue.text = (String(minutes).pad_zeros(2) + ":" + String(seconds).pad_zeros(2) +
	"." + centisecondsString.substr(centisecondsString.length() - 2, 2))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if incrementing:
		currentTime = currentTime + delta
		update_time_string()
	else:
		currentTime = currentTime - delta
		if currentTime <= 0.0:
			currentTime = 0.0
			update_time_string()
			emit_signal("out_of_time")
		else:
			update_time_string()
			if currentTime <= 10.0:
				if warningsLeft == 6:
					warningsLeft = 5
					#TODO sound sfx "10 seconds left"
				elif currentTime <= warningsLeft:
					warningsLeft = warningsLeft - 1
					#TODO sound sfx "5 4 3 2 1 seconds left"