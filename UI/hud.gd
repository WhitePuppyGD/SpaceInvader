class_name HUD
extends Control

@export var game_score : int = 0
@export var nb_player_life : int = 3
# Classe qui va contrôler le score et les vies restantes

@onready var score_label: Label = $ScoreLabel



func update_score(points : int) -> void:
	game_score += points
	score_label.text = str("%05d" % game_score)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
