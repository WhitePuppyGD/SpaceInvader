extends Area2D

@onready var missile_scene = preload("res://scenes/player_missile.tscn")
@onready var gun_position_marker: Marker2D = $GunPositionMarker

signal player_ship_collision_with_area_detected
signal player_missile_collision_with_invader_detected
signal player_missile_collision_with_area_detected


var ship_scale = 10
var ship_width = 13 * ship_scale

var ship_speed = 400

var ship_min_position = 0
var ship_max_position = 0

func shoot_missile() -> void:
	var missile = missile_scene.instantiate()
	missile.set_starting_position(gun_position_marker.global_position)
	missile.connect("missile_collision_with_invader_detected", Callable(self, "_on_missile_collision_with_invader_detected"))
	missile.connect("missile_collision_with_area_detected", Callable(self, "_on_missile_collision_with_area_detected"))
	get_parent().add_child(missile)


func destruction() -> void:
	# On joue l'animation "destruction" du AnimatedSprite2D
	var sprite = get_node("AnimatedSprite2D")
	sprite.play("destruction")
	if not sprite.is_connected("animation_finished", Callable(self, "_on_destruction_animation_finished")):
		sprite.connect("animation_finished", Callable(self, "_on_destruction_animation_finished"))


func move_ship(direction, delta) -> void:
	position.x += direction * ship_speed	 * delta
	position.x = clamp(position.x, ship_min_position, ship_max_position)

func set_ship_boundaries(max_pos) -> void:
	ship_min_position = 0 + ship_width / 2.0
	ship_max_position = max_pos - ship_width / 2.0


func _on_destruction_animation_finished():
	call_deferred("queue_free")


func _on_missile_collision_with_invader_detected(missile: Area2D, invader :CharacterBody2D) -> void:
	emit_signal("player_missile_collision_with_invader_detected", missile, invader)
	
func _on_missile_collision_with_area_detected(missile: Area2D, area: Area2D) -> void:
	emit_signal("player_missile_collision_with_area_detected", missile, area)

func _on_area_entered(area: Area2D) -> void:
	emit_signal("player_ship_collision_with_area_detected", area)
