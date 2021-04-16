extends Label
class_name FadingLabel

export var animationLength: float
var animationTime: float = 0.0
var incrementing = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if incrementing:
		animationTime = animationTime + delta
		if animationTime > animationLength:
			animationTime = animationLength
			incrementing = false
	else:
		animationTime = animationTime - delta
		if animationTime < 0:
			animationTime = 0
			incrementing = true
	set_modulate(Color(1,1,1,(animationLength - animationTime)/animationLength))
