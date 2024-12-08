extends Area2D

var missile_speed = 1000

signal missile_collision_with_invader_detected
signal missile_collision_with_area_detected


func set_starting_position(gun_position: Vector2) -> void:
	position = gun_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y -= missile_speed * delta

func destruction() -> void:
	call_deferred("queue_free")

func _on_area_entered(area: Area2D) -> void:
	emit_signal("missile_collision_with_area_detected", self, area)

# S'il rencontre un Invader, on emet le signal qui sera traité par main.gd
# On sait que c'est un Invader car Invader est le seul Node en CharaacterBody2D
func _on_body_entered(body: Node2D) -> void:
	emit_signal("missile_collision_with_invader_detected",self, body)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	destruction()
