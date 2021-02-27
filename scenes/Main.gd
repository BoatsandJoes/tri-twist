extends Node2D


export (PackedScene) var GameScene
var gameScene: GameScene

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	gameScene = GameScene.instance()
	add_child(gameScene)

func _input(event):
	if event is InputEventKey && event.is_action_pressed("ui_escape"):
		get_tree().quit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
