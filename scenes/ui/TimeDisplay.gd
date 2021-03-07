extends MarginContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal out_of_time

var currentTime: float = 0.0
var incrementing: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(minutes: float, seconds: float):
	incrementing = minutes == 0 && seconds == 0
	if !incrementing:
		currentTime = minutes * 6000.0 + seconds * 100.0
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
