extends Area2D

signal invader_missile_collision_with_area_detected


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += 1

func destruction() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	emit_signal("invader_missile_collision_with_area_detected", self, area)
