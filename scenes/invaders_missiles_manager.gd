class_name InvadersMissilesManager

extends Node


# Compte combien de missiles il y a dans la Scene Principale
# Le nb de missiles est limité à max_player_missiles_in_scene
func cnt_player_missiles() -> int:
	return get_tree().get_nodes_in_group("PlayerMissiles").size()

func delete_invaders_missiles() -> void:
	for invader_missile in get_tree().get_nodes_in_group("InvadersMissiles"):
		invader_missile.queue_free()
