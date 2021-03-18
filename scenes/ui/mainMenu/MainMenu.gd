extends Control
class_name MainMenu

signal play
signal settings
signal credits

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
"Not a fighting game",
"Contains arbitrary execution and artificial difficulty",
"I've always wanted to feel like my puzzle game had the vibe of a teen romance novel",
"Open source https://github.com/BoatsandJoes",
"Ah, I see you are a Windows user",
"Oh no! It's boiling acid!",
"A wagon full of pancakes? In the championship? I'd like to see it try",
"I can be your angle... or yuor devil",
"psssh...nothin personnel...kid...",
"I wanna take you for a ride"]

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
			_on_Exit_pressed()
		elif event.is_action_pressed("ui_up"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/PlayArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/PlayArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/SettingsArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/SettingsArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/PlayArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/CreditsArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/CreditsArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/SettingsArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/CreditsArrow.text = "<"
		elif event.is_action_pressed("ui_down"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/PlayArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/PlayArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/SettingsArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/SettingsArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/SettingsArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/CreditsArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/CreditsArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/CreditsArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text = "<"
			elif $MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text == "<":
				$MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text = ""
				$MarginContainer/HBoxContainer/VBoxContainer2/PlayArrow.text = "<"
		elif event.is_action_pressed("ui_accept") || event.is_action_pressed("ui_select"):
			if $MarginContainer/HBoxContainer/VBoxContainer2/PlayArrow.text == "<":
				_on_Play_pressed()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/SettingsArrow.text == "<":
				_on_Settings_pressed()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/CreditsArrow.text == "<":
				_on_Credits_pressed()
			elif $MarginContainer/HBoxContainer/VBoxContainer2/ExitArrow.text == "<":
				_on_Exit_pressed()

func _on_Exit_pressed():
	get_tree().quit()


func _on_Play_pressed():
	emit_signal("play")


func _on_Settings_pressed():
	emit_signal("settings")


func _on_Credits_pressed():
	emit_signal("credits")
