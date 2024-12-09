class_name HUD
extends Control

@export var game_score : int = 0
@export var nb_player_life : int = 3
# Classe qui va contrôler le score et les vies restantes

@onready var score_label: Label = $ScoreLabel


func init() -> void:
	for i in range(3):  # Parcours les indices 0, 1, 2
		var node_path = "Life{n} Texture".format({"n": i + 1})
		var life_node = get_node(node_path)
		life_node.visible = true
	game_score = 0
	update_score(0)

func update_life(life: int) -> void:
	for i in range(3):  # Parcours les indices 0, 1, 2
		#var node_path = "$Life{} Texture".format(i + 1)
		var node_path = "Life{n} Texture".format({"n": i + 1})
		var life_node = get_node(node_path)
		life_node.visible = (i < life)

func update_score(points : int) -> void:
	game_score += points
	score_label.text = str("%05d" % game_score)
