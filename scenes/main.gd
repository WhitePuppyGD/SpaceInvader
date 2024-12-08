extends Node2D

@export var player_ship_scene: PackedScene = preload("res://scenes/player.tscn")

@onready var invaders_group = get_tree().get_nodes_in_group("Invaders")
@onready var hud: HUD = $Score/HUD

@onready var screen_width = get_viewport_rect().size[0]
@onready var screen_height = get_viewport_rect().size[1]

@onready var rng = RandomNumberGenerator.new()

@onready var player_ship = null

var max_player_missiles_in_scene = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_signals_to_invaders()
	player_ship = spawn_player_ship()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Si le vaisseau est toujours en vie
	if is_instance_valid(player_ship) && player_ship.player_ship_alive:
		player_ship.move_ship(Input.get_axis("ui_left", "ui_right"), delta)
	
		if Input.is_action_just_pressed("ui_accept"):
			if cnt_player_missiles() <= max_player_missiles_in_scene:	
				player_ship.shoot_missile()
	
	
func spawn_player_ship() -> Area2D:
	var ship = player_ship_scene.instantiate()
	ship.init(screen_width, self)
	add_child(ship)
	return ship


# Compte combien de missiles il y a dans la Scene Principale
# Le nb de missiles est limité à max_player_missiles_in_scene
func cnt_player_missiles() -> int:
	return get_tree().get_nodes_in_group("PlayerMissiles").size()


func increase_invaders_speed() -> void:
	for invader in invaders_group:
		if is_instance_valid(invader):
			invader.increase_speed()


func delete_invaders_missiles() -> void:
	for invader_missile in get_tree().get_nodes_in_group("InvadersMissiles"):
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


# Mort du vaisseau
func _on_player_ship_collision_with_area_detected(area: Area2D):
	if area.is_in_group("InvadersMissiles"):
		player_ship.player_ship_alive = false
		delete_invaders_missiles()
		player_ship.destruction()
		invaders_authorisation_to_shoot(false)
		
	await get_tree().create_timer(1.0).timeout
	
	player_ship = spawn_player_ship()
	player_ship.player_ship_alive = true
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
