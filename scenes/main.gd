extends Node2D

@onready var player_ship_scene = preload("res://scenes/player.tscn")

@onready var invaders_group = get_tree().get_nodes_in_group("Invaders")
@onready var invaders_missiles_group = get_tree().get_nodes_in_group("InvadersMissiles")
@onready var player_missiles_group = get_tree().get_nodes_in_group("PlayerMissiles")

@onready var hud: HUD = $Score/HUD


var screen_width = null
var screen_height = null 

var player_ship = null
var player_ship_spawn_position = Vector2(960, 1018)

var max_player_missiles_in_scene = 1

var total_score : int = 0

var rng = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	screen_width = get_viewport_rect().size[0]
	screen_height = get_viewport_rect().size[1]
	
	rng = RandomNumberGenerator.new()
	
	connect_signals_to_invaders()
	
	spawn_player_ship()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Si le vaisseau est toujours en vie
	if is_instance_valid(player_ship):
		player_ship.move_ship(Input.get_axis("ui_left", "ui_right"), delta)
	
		if Input.is_action_just_pressed("ui_accept"):
			if cnt_player_missiles() <= max_player_missiles_in_scene:	
				player_ship.shoot_missile()
	
func spawn_player_ship() -> void:
	player_ship = player_ship_scene.instantiate()
	player_ship.position = player_ship_spawn_position
	player_ship.set_ship_boundaries(screen_width)
	connect_signals_to_player_ship()
	add_child(player_ship)


# Compte combien de missiles il y a dans la Scene Principale
# Le nb de missiles est limité à max_player_missiles_in_scene
func cnt_player_missiles() -> int:
	return player_missiles_group.size()


func increase_invaders_speed() -> void:
	for invader in invaders_group:
		if is_instance_valid(invader):
			invader.increase_speed()


func delete_invaders_missiles() -> void:
	for invader_missile in invaders_missiles_group:
		invader_missile.queue_free()

func invaders_authorisation_to_shoot(order: bool) -> void:
	for invader in invaders_group:
		if is_instance_valid(invader):
			invader.set_authorisation_to_shoot(order)


# Connection du signal émis par les murs lorsqu'un invader entre en collision avec
func connect_signals_to_invaders() -> void:
	for invader in invaders_group:
		invader.connect("invader_collision_with_wall_detected", Callable(self, "_on_invader_collision_with_wall_detected"))
		invader.connect("invader_missile_collision_with_area_detected", Callable(self, "_on_invader_missile_collision_with_area_detected"))


func connect_signals_to_player_ship() -> void:	
	# On connecte les signaux envoyés par player_ship et que seront traités dans Main
	player_ship.connect("player_ship_collision_with_area_detected", Callable(self, "_on_player_ship_collision_with_area_detected"))
	player_ship.connect("player_missile_collision_with_invader_detected", Callable(self, "_on_player_missile_collision_with_invader_detected"))
	player_ship.connect("player_missile_collision_with_area_detected", Callable(self, "_on_player_missile_collision_with_area_detected"))


func _on_player_ship_collision_with_area_detected(area: Area2D):
	if area.is_in_group("InvadersMissiles"):
		delete_invaders_missiles()
		player_ship.destruction()
		invaders_authorisation_to_shoot(false)

	await get_tree().create_timer(1.0).timeout
	
	spawn_player_ship()
	invaders_authorisation_to_shoot(true)



func _on_player_missile_collision_with_area_detected(missile, area):
	pass


func _on_player_missile_collision_with_invader_detected(missile, invader):
	hud.update_score(invader.destruction())
	missile.destruction()
	increase_invaders_speed()
	
	
func _on_invader_missile_collision_with_area_detected(missile: Area2D, area: Area2D) -> void:
	if area.name == "BottomWall":
		missile.destruction()
		

# Quand un invader touche un mur latéral, on change la direction de tous les invaders
func _on_invader_collision_with_wall_detected(body: Node2D):
	for invader in invaders_group:
		if is_instance_valid(invader):
			invader.reverse_direction()
