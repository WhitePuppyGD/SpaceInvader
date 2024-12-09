extends Area2D

var speed = 500

func _process(delta: float) -> void:
	#translate(Vector2(position.x, -1 * speed))
	position.y += 1 * speed * delta

func destruction() -> void:
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	destruction()
