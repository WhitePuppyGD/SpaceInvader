extends Area2D

var missile_speed = 1000

signal missile_collision_with_invader_detected(missile, invader)


func init(gun_position: Vector2) -> void:
	position = gun_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y -= missile_speed * delta	

func destruction() -> void:
	call_deferred("queue_free")

# S'il rencontre le TopWall, on le détruit
func _on_area_entered(area: Area2D) -> void:
	if area.name =="TopWall":
		destruction()

# S'il rencontre un Invader, on emet le signal qui sera traité par main.gd
func _on_body_entered(body: Node2D) -> void:
	emit_signal("missile_collision_with_invader_detected",self, body)
