extends Area2D

signal invader_missile_collision_with_player_ship_detected(missile)

var ship_scale = 10
var ship_width = 13 * ship_scale
var ship_height = 8 * ship_scale

var ship_speed = 400

var ship_min_position = 0
var ship_max_position = 0
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func move_ship(direction, delta) -> void:
	position.x += direction * ship_speed	 * delta
	position.x = clamp(position.x, ship_min_position, ship_max_position)


func get_ship_gun_position() -> Vector2:
	return Vector2(position.x, position.y - ship_height)

func set_ship_boundaries(max_pos) -> void:
	ship_min_position = 0 + ship_width / 2.0
	ship_max_position = max_pos - ship_width / 2.0

func _on_area_entered(area: Area2D) -> void:
	emit_signal("invader_missile_collision_with_player_ship_detected", area)
	pass # Replace with function body.
