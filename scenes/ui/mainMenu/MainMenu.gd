extends Control
class_name MainMenu

signal play
signal credits
signal exit
signal volume

const taglines: Array = [
"It's triangle time!", #idk, it doesn't mean anything
"Let's go get ready to look so good!", #Homestar Runner Teen Girl Squad #1
"Ah, I see you are a Mac user", #Someone online's opening line of open source software evangelism (name witheld)
"Like putting too much air in a balloon!", #Futurama: Where No Fan Has Gone Before 
"Think of shipping channels in the ocean", #Numb3rs: Shadow Markets
"It's how hackers talk when they don't want to be overheard", #Numb3rs: Shadow Markets
"Okay, so imagine a bus", #Analogy often used to explain frame rules in Super Mario Bros 1 speedrunning, probably invented by Darbian
"This game isn't the only game that has a movement exploit;\nbasketball has it too", #Core A Gaming: The Korean Backdash
"It's like preordering a video game", #Paraphrased from Core A Gaming: Why Button Mashing Works (Sometimes)
"Chugga chugga chugga chugga CHOO CHOO", # Snowpiercer is a work that examines class divide, but also takes place on a train
"Might be a roguelike", # Some purist roguelike fans get upset when someone (INCORRECTLY :O ) categorizes a game in their genre
"Not a fighting game", # Some purist fighting game fans get upset when someone (INCORRECTLY :O ) categorizes a game in their genre
"Contains arbitrary execution and artificial difficulty", # Video game players often complain about these things. Some like them
"I can be your angle... or your devil", #Meme, often associated with Egoraptor/Game Grumps. Also, triangles
"I've always wanted to feel like my puzzle game\nhad the vibe of a teen romance novel", #My sister's response to I can be your angle
"Oh no! It's boiling acid!", #Security guard from near the beginning of Batman Forever
"A wagon full of pancakes? In the championship?\nI'd like to see it try", #Homestar Runner: Strong Bad Email #117 "Montage"
"I wanna take you for a ride", #Lyrics from the Marvel vs Capcom 2: New Age of Heroes character select theme
"I don't know who it is, but it probably is fhqwhgads", #Homestar Runner: Everybody to the Limit
"No copyright infringement intended,\nall rights to their original owners", #Often posted under blatantly infringing Youtube videos
"When I see a triangle I turn 300 degrees and walk away", #300 degrees is the angle outside an equilateral triangle (inside is 60)
"The juice is hypotenuse", #"The juice is loose" is something that people used to say about OJ Simpson
"No obtuse mechanics", #Obtuse is a type of angle that a triangle can have, but not in this game.
"YOU DIED", #Message that appears in several From Software games when you die
"Trongle", #Alternate title
"I couldn't tell a vertex from an edge,\nbut my wife? She's crazy about\ntriangles! Can't get enough of 'em!",
# ^ TV detective Columbo often attributes his insights to "his wife," to lull his target into thinking he's a simpleton
"To boldly Tri where no Angel has tried before" #Star Trek "To boldly go"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$MarginContainer/HBoxContainer/VBoxContainer3/Tagline.text = taglines[randi() % taglines.size()]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel"):
		emit_signal("exit")

func _on_Play_pressed():
	emit_signal("play")

func _on_Volume_pressed():
	var volume = int($MarginContainer/HBoxContainer/VBoxContainer/Volume.text.substr(8, 3))
	volume = volume - 10
	if volume < 0:
		volume = 100
	set_volume(volume)
	emit_signal("volume", volume)

func set_volume(volume):
	$MarginContainer/HBoxContainer/VBoxContainer/Volume.text = $MarginContainer/HBoxContainer/VBoxContainer/Volume.text.substr(0, 8) + String(volume)

func _on_Credits_pressed():
	emit_signal("credits")

func _on_Exit_pressed():
	emit_signal("exit")
