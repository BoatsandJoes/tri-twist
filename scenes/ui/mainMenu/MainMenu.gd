extends Control
class_name MainMenu

signal play
signal multiplayer
signal settings
signal credits
signal back_to_title
signal exit

const taglines: Array = [
"Ah, I see you are a Windows user", #Someone online's opening line of open source software evangelism (name witheld)
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
"I can be your angle... or yuor devil", #Meme, often associated with Egoraptor/Game Grumps. Also, triangles
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
"I couldn't tell a vertex from an edge, but my wife?\nShe's crazy about triangles! Can't get enough of 'em!",
# ^TV detective Columbo often attributes his insights to "his wife," to lull his target into thinking he's a simpleton
"To boldly Tri where no Angel has tried before" #Star Trek "To boldly go"
]

var SelectArrow = load("res://scenes/ui/elements/SelectArrow.tscn")
var selectArrow: SelectArrow
var playArrowPosition: Vector2
var versusArrowPosition: Vector2
var settingsArrowPosition: Vector2
var creditsArrowPosition: Vector2
var exitArrowPosition: Vector2
var timer: Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$MarginContainer/HBoxContainer/VBoxContainer3/Tagline.text = taglines[randi() % taglines.size()]
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
	var playButtonPosition = $MarginContainer/HBoxContainer/VBoxContainer/Play.rect_global_position
	var versusButtonPosition = $MarginContainer/HBoxContainer/VBoxContainer/Multiplayer.rect_global_position
	var settingsButtonPosition = $MarginContainer/HBoxContainer/VBoxContainer/Settings.rect_global_position
	var creditsButtonPosition = $MarginContainer/HBoxContainer/VBoxContainer/Credits.rect_global_position
	var exitButtonPosition = $MarginContainer/HBoxContainer/VBoxContainer/Exit.rect_global_position
	var buttonWidthHeight = $MarginContainer/HBoxContainer/VBoxContainer/Play.get_rect().size
	playArrowPosition = Vector2(playButtonPosition[0] + buttonWidthHeight[0], playButtonPosition[1] + buttonWidthHeight[1] / 2)
	versusArrowPosition = Vector2(versusButtonPosition[0] + buttonWidthHeight[0], versusButtonPosition[1] + buttonWidthHeight[1] / 2)
	settingsArrowPosition = Vector2(settingsButtonPosition[0]+buttonWidthHeight[0],settingsButtonPosition[1]+buttonWidthHeight[1] / 2)
	creditsArrowPosition = Vector2(creditsButtonPosition[0] + buttonWidthHeight[0], creditsButtonPosition[1]+buttonWidthHeight[1] / 2)
	exitArrowPosition = Vector2(exitButtonPosition[0] + buttonWidthHeight[0], exitButtonPosition[1] + buttonWidthHeight[1] / 2)
	select_play()
	selectArrow.visible = true
	timer.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if (event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton):
		if event.is_action_pressed("ui_escape") || event.is_action_pressed("ui_cancel"):
			emit_signal("exit")
		elif event.is_action_pressed("ui_up"):
			if play_selected():
				select_exit()
			elif versus_selected():
				select_play()
			elif settings_selected():
				select_versus()
			elif credits_selected():
				select_settings()
			elif exit_selected():
				select_credits()
		elif event.is_action_pressed("ui_down"):
			if play_selected():
				select_versus()
			elif versus_selected():
				select_settings()
			elif settings_selected():
				select_credits()
			elif credits_selected():
				select_exit()
			elif exit_selected():
				select_play()
		elif event.is_action_pressed("ui_accept"):
			if play_selected():
				_on_Play_pressed()
			elif versus_selected():
				_on_Multiplayer_pressed()
			elif settings_selected():
				_on_Settings_pressed()
			elif credits_selected():
				_on_Credits_pressed()
			elif exit_selected():
				_on_Exit_pressed()

func play_selected():
	return selectArrow.position == playArrowPosition

func versus_selected():
	return selectArrow.position == versusArrowPosition

func settings_selected():
	return selectArrow.position == settingsArrowPosition

func credits_selected():
	return selectArrow.position == creditsArrowPosition

func exit_selected():
	return selectArrow.position == exitArrowPosition

func select_play():
	selectArrow.position = playArrowPosition
	
func select_versus():
	selectArrow.position = versusArrowPosition
	
func select_settings():
	selectArrow.position = settingsArrowPosition
	
func select_credits():
	selectArrow.position = creditsArrowPosition
	
func select_exit():
	selectArrow.position = exitArrowPosition

func _on_Play_pressed():
	emit_signal("play")

func _on_Multiplayer_pressed():
	emit_signal("multiplayer")

func _on_Settings_pressed():
	emit_signal("settings")

func _on_Credits_pressed():
	emit_signal("credits")

func _on_Exit_pressed():
	emit_signal("exit")