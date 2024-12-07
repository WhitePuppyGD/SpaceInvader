extends Node2D


@onready var invaders_group = get_tree().get_nodes_in_group("Invaders")
@onready var player_ship = get_node("PlayerShip")
@onready var player_missile_scene = preload("res://scenes/player_missile.tscn")

var max_player_missiles_in_scene = 1


var rng = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var screen_width = get_viewport_rect().size[0]
	var screen_height = get_viewport_rect().size[1]
	
	rng = RandomNumberGenerator.new()
	
	connect_walls_signal_to_invaders()
	
	player_ship.connect("invader_missile_collision_with_player_ship_detected", Callable(self, "_on_invader_missile_collision_with_player_ship_detected"))
	
	player_ship.set_ship_boundaries(screen_width)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	player_ship.move_ship(Input.get_axis("ui_left", "ui_right"), delta)
	
	if Input.is_action_just_pressed("ui_accept"):
		shoot_player_missile()
	

func shoot_player_missile() -> void:

	if cnt_player_missiles() <= max_player_missiles_in_scene:
		var player_missile = player_missile_scene.instantiate()
		player_missile.init(player_ship.get_ship_gun_position())
		player_missile.connect("missile_collision_with_invader_detected", Callable(self, "_on_missile_collision_with_invader_detected"))
		add_child(player_missile)
	

func cnt_player_missiles() -> int:
	return get_tree().get_nodes_in_group("PlayerMissiles").size()

func increase_invaders_speed() -> void:
	for invader in invaders_group:
		if is_instance_valid(invader):
			invader.increase_speed()


# Connection du signal émis par les murs lorsqu'un invader entre en collision avec
func connect_walls_signal_to_invaders() -> void:
	for invader in invaders_group:
		invader.connect("invader_collision_with_wall_detected", Callable(self, "_on_invader_collision_with_wall_detected"))


func _on_invader_missile_collision_with_player_ship_detected(missile):
	print("Game Over !")

func _on_missile_collision_with_invader_detected(missile, invader):
	var points = invader.destruction()
	missile.destruction()
	increase_invaders_speed()

# Quand un invader touche un mur latéral, on change la direction de tous les invaders
func _on_invader_collision_with_wall_detected(body: Node2D):
	for invader in invaders_group:
		if is_instance_valid(invader):
			invader.reverse_direction()
