extends Node2D

var count_invaders = 0

@onready var invaders_group:
	get:
		return get_tree().get_nodes_in_group("Invaders")

func _ready() -> void:
	count_invaders = invaders_group.size()

func _process(delta: float) -> void:
	count_invaders = invaders_group.size()

func init(signal_target: Node, speed :int = 200) -> void:
	set_speed(speed)
	connect_signals(signal_target)

func delete_invaders() -> void:
	for invader in invaders_group:
		call_deferred("invader.queue_free()")

func set_speed(speed: int) -> void:
	for invader in invaders_group:
		invader.speed = speed

func increase_speed() -> void:
	for invader in invaders_group:
		if is_instance_valid(invader):
			invader.increase_speed()

func authorisation_to_shoot(order: bool) -> void:
	for invader in invaders_group:
		if is_instance_valid(invader):
			invader.set_authorisation_to_shoot(order)

func connect_signals(signal_target: Node) -> void:
	for invader in invaders_group:
		invader.connect("invader_collision_with_wall_detected", Callable(self, "_on_invader_collision_with_wall_detected"))
		invader.connect("invader_missile_collision_with_area_detected", Callable(signal_target, "_on_invader_missile_collision_with_area_detected"))

# Quand un invader touche un mur latéral, on change la direction de tous les invaders
func _on_invader_collision_with_wall_detected(body: Node2D):
	for invader in invaders_group:
		if is_instance_valid(invader):
			invader.reverse_direction()
