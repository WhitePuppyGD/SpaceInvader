extends Node2D

@export var player_ship_scene: PackedScene = preload("res://scenes/player.tscn")
@export var invaders_scene: PackedScene = preload("res://scenes/invaders.tscn")


@onready var hud_ui: HUD = $UI/HUD
@onready var game_over_ui: Control = $UI/GameOver

@onready var invaders_missiles_manager: Node = $InvadersMissilesManager

@onready var screen_width = get_viewport_rect().size[0]
@onready var screen_height = get_viewport_rect().size[1]

@onready var rng = RandomNumberGenerator.new()

@onready var player_ship = null
@onready var invaders = null

@export var invaders_speed = 100


# C'est MOCHE ! Je gère les scores ici et aussi dans le HUD
@export var count_max_player_life :int = 3
@export var count_player_life :int = count_max_player_life

var max_player_missiles_in_scene = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_ship = spawn_player_ship()
	invaders = spawn_invaders()
	game_over_ui.connect("restart_button_pressed", Callable(self, "_on_restart_button_pressed"))

func restart() -> void:
	invaders_speed = 100
	player_ship = spawn_player_ship()
	invaders = spawn_invaders()
	count_player_life = count_max_player_life
	hud_ui.init()
	
	
func _process(delta: float) -> void:
	
	# Si le vaisseau est toujours en vie
	if is_instance_valid(player_ship) && player_ship.player_ship_alive:
		player_ship.move_ship(Input.get_axis("ui_left", "ui_right"), delta)
	
		if Input.is_action_just_pressed("ui_accept"):
			if invaders_missiles_manager.cnt_player_missiles() <= max_player_missiles_in_scene:	
				player_ship.shoot_missile()
		
		if is_instance_valid(invaders) && invaders.count_invaders == 0:
			invaders = spawn_invaders()
		

func spawn_player_ship() -> Area2D:
	var obj = player_ship_scene.instantiate()
	obj.player_ship_alive = true
	add_child(obj)
	obj.init(screen_width, self)
	return obj

func spawn_invaders() -> Node2D:
	var obj = invaders_scene.instantiate()
	add_child(obj)

	invaders_speed += 100
	
	if is_instance_valid(invaders):
		invaders.queue_free()
	
	obj.init(self, invaders_speed)
	
	invaders_missiles_manager.delete_invaders_missiles()

	return obj


# Mort du vaisseau
func _on_player_ship_collision_with_something_detected(area: Node2D):
	
	if area.is_in_group("InvadersMissiles") && player_ship.player_ship_alive:

		destroy_player_ship()
	
		count_player_life -= 1

		hud_ui.update_life(count_player_life)
				
		await get_tree().create_timer(1.0).timeout
	
		player_ship = spawn_player_ship()
		
		if is_instance_valid(invaders):
			invaders.authorisation_to_shoot(true)
	else:
		game_over()
	
	if count_player_life == 0:
		game_over()

func game_over() -> void:
	destroy_player_ship()
	invaders.queue_free()
	
	# On flush tout ce que se passe
	await get_tree().process_frame 
	game_over_ui.visible = true


func destroy_player_ship() -> void:

	player_ship.player_ship_alive = false
	invaders_missiles_manager.delete_invaders_missiles()
	player_ship.destruction()
	invaders.authorisation_to_shoot(false)

func _on_player_missile_collision_with_invader_detected(missile, invader):
	
	hud_ui.update_score(invader.destruction())
	missile.destruction()
	invaders.increase_speed()

func _on_restart_button_pressed() -> void:
	restart()
	game_over_ui.visible = false
