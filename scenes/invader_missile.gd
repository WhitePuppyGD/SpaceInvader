extends Area2D

signal invader_missile_collision_detected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += 1
	pass


func _on_area_entered(area: Area2D) -> void:
	if area.name == "BottomWall":
		queue_free()
	pass # Replace with function body.
