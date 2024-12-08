extends Area2D

@export var missile_scene : PackedScene = preload("res://scenes/player_missile.tscn")
@onready var gun_position_marker: Marker2D = $GunPositionMarker

signal player_ship_collision_with_area_detected
signal player_missile_collision_with_invader_detected
signal player_missile_collision_with_area_detected

@export var game_manager : Node

# On tente un setter/getter pour voir
var player_ship_alive : bool = true:
	get:
		return player_ship_alive
	set(value):
		player_ship_alive = value

var ship_scale = 10
var ship_width = 13 * ship_scale

var ship_speed = 400

var ship_min_position = 0
var ship_max_position = 0

var player_ship_spawn_position = Vector2(960, 1018)

func init(max_pos : int, signal_target: Node ):
	position = player_ship_spawn_position
	set_ship_boundaries(max_pos)
	connect_signals(signal_target)
	game_manager = signal_target


func connect_signals(signal_target: Node) -> void:
	connect("player_ship_collision_with_area_detected", Callable(signal_target, "_on_player_ship_collision_with_area_detected"))


func shoot_missile() -> void:
	var missile = missile_scene.instantiate()
	missile.init(gun_position_marker.global_position, game_manager)
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

func _on_missile_collision_with_area_detected(missile: Area2D, area: Area2D) -> void:
	emit_signal("player_missile_collision_with_area_detected", missile, area)

func _on_area_entered(area: Area2D) -> void:
	emit_signal("player_ship_collision_with_area_detected", area)
