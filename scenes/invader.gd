extends CharacterBody2D

@onready var invader_missile_scene = preload("res://scenes/invader_missile.tscn")

var direction = Vector2(1, 0)
var speed = 100
var acceleration = 1.08

var invader_points = 0

var rng := RandomNumberGenerator.new()

signal invader_collision_with_wall_detected
signal invader_missile_collision_with_area_detected


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	velocity = direction * speed
	move_and_slide()

	# Voici comment on gère les collisions après un déplacement
	# d'un CharacterBody2D
	for i in range(get_slide_collision_count()):
		var collider = get_slide_collision(i).get_collider()
		if collider.is_in_group("LateralWalls"):
			emit_signal("invader_collision_with_wall_detected", collider)


func _process(delta: float) -> void:
	if rng.randi_range(0, 1000) > 999:
		shoot()


func shoot() -> void:
	var invader_missile = invader_missile_scene.instantiate()
	invader_missile.position = position
	invader_missile.connect("invader_missile_collision_with_area_detected", Callable(self, "_on_invader_missile_collision_with_area_detected"))
	get_parent().add_child(invader_missile)

func destruction() -> int:
	
	# On joue l'animation "destruction" du AnimatedSprite2D
	var sprite = get_node("AnimatedSprite2D")
	sprite.play("destruction")

	# On check si le signal est déjà connecté (on peut revenir dans cette fonction alors que l'objet
	# n'a pas encore été détruit dans l'arbre
	if not sprite.is_connected("animation_finished", Callable(self, "_on_destruction_animation_finished")):
		sprite.connect("animation_finished", Callable(self, "_on_destruction_animation_finished"))
	
	var points = get_points()
	return points


func get_points() -> int:
	return self.invader_points

func increase_speed() -> void:
	speed *= acceleration

func reverse_direction() -> void:
	direction = -direction
	position.y += 10

func _on_destruction_animation_finished():
	call_deferred("queue_free")
	
func _on_invader_missile_collision_with_area_detected(missile: Area2D, area: Area2D) -> void:
	emit_signal("invader_missile_collision_with_area_detected", missile, area)
