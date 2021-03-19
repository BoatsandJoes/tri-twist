extends Control
class_name MainMenu

signal play
signal settings
signal credits
signal back_to_title
signal exit

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const taglines: Array = [
"Ah, I see you are a Windows user", #Someone online's opening line of evangelism about how great open source software is (name witheld)
"Open source https://github.com/BoatsandJoes", #This game is open source! You're reading it right now!
"Like putting too much air in a balloon!", #Futurama: Where No Fan Has Gone Before 
"Think of shipping channels in the ocean", #Numb3rs: Shadow Markets
"It's how hackers talk when they don't want to be overheard", #Numb3rs: Shadow Markets
"Okay, so imagine a bus", #Analogy often used to explain frame rules in Super Mario Bros 1 speedrunning, probably invented by Darbian
"This game isn't the only game that has a movement exploit; basketball has it too", #Core A Gaming: The Korean Backdash
"It's like preordering a video game", #Paraphrased from Core A Gaming: Why Button Mashing Works (Sometimes)
"Chugga chugga chugga chugga CHOO CHOO", # Snowpiercer is a work that examines class divide, but also takes place on a train
"Might be a roguelike", # Some purist roguelike fans get upset when someone (INCORRECTLY :O ) categorizes a game in their genre
"Not a fighting game", # Some purist fighting game fans get upset when someone (INCORRECTLY :O ) categorizes a game in their genre
"Contains arbitrary execution and artificial difficulty", # Video game players often complain about these things. Some people like them
"I can be your angle... or yuor devil", #Meme, often associated with Egoraptor/Game Grumps. Also, triangles
"I've always wanted to feel like my puzzle game had the vibe of a teen romance novel", #My sister's response to I can be your angle...
"Oh no! It's boiling acid!", #Security guard from near the beginning of Batman Forever
"A wagon full of pancakes? In the championship? I'd like to see it try", #Homestar Runner: Strong Bad Email #117 "Montage"
"I wanna take you for a ride", #Lyrics from the Marvel vs Capcom 2: New Age of Heroes character select theme
"I don't know who it is, but it probably is fhqwhgads", #Homestar Runner: Everybody to the Limit
"No copyright infringement intended, all rights to their original owners" #Often posted under blatantly infringing Youtube videos
]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$MarginContainer/HBoxContainer/VBoxContainer3/Tagline.text = taglines[randi() % taglines.size()]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if (event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton):
		if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel"):
			emit_signal("back_to_title")
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
	emit_signal("exit")


func _on_Play_pressed():
	emit_signal("play")


func _on_Settings_pressed():
	emit_signal("settings")


func _on_Credits_pressed():
	emit_signal("credits")
