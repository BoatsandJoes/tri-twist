extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const taglines: Array = [
"Like putting too much air in a balloon!",
"Think of shipping channels in the ocean",
"It's how hackers talk when they don't want to be overheard",
"Okay, so imagine a bus",
"This game isn't the only game that has a movement exploit; basketball has it too",
"Chugga chugga chugga chugga CHOO CHOO",
"Might be a roguelike",
"I've always wanted to feel like my puzzle game had the vibe of a teen romance novel",
"Open source https://github.com/BoatsandJoes",
"Ah, I see you are a Windows user",
"Oh no! It's boiling acid!",
"A wagon full of pancakes? In the champeenship? I'd like to see it try",
"I can be your angle... or yuor devil",
"psssh...nothin personnel...kid..."]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$MarginContainer/HBoxContainer/VBoxContainer3/Tagline.text = taglines[randi() % taglines.size()]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_escape"):
			get_tree().quit()
		elif event.is_action_pressed("ui_up"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/Mode1Arrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode1Arrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/Mode2Arrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode2Arrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode1Arrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode2Arrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text = "<"
		elif event.is_action_pressed("ui_down"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/Mode1Arrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode1Arrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode2Arrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/Mode2Arrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode2Arrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/Mode1Arrow.text = "<"
		elif event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_select"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/Mode1Arrow.text == "<":
				_on_Mode1_pressed()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/Mode2Arrow.text == "<":
				_on_Mode2_pressed()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/DigModeArrow.text == "<":
				_on_DigMode_pressed()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text == "<":
				_on_Quit_pressed()

func _on_Quit_pressed():
	get_tree().quit()


func _on_Mode1_pressed():
	get_tree().change_scene("scenes/Mode1.tscn")


func _on_Mode2_pressed():
	get_tree().change_scene("scenes/Mode2.tscn")


func _on_DigMode_pressed():
	get_tree().change_scene("scenes/DigMode.tscn")
