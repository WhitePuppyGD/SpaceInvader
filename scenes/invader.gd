extends Area2D

var direction = 1.0
var speed = 100

var invader_points = 0

signal invader_collision_with_wall_detected(body)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += direction * delta * speed

func destruction() -> int:
	
	var sprite = get_node("AnimatedSprite2D")

	sprite.play("destruction")

	# On check si le signal est déjà connecté (on peut revenir dans cette fonction alors que l'objet
	# n'a pas encore été détruit dans l'arbre
	if not sprite.is_connected("animation_finished", Callable(self, "_on_destruction_animation_finished")):
		sprite.connect("animation_finished", Callable(self, "_on_destruction_animation_finished"))
	
	var points = get_points()
	return points

func _on_destruction_animation_finished():
	call_deferred("queue_free")


func get_points() -> int:
	return self.invader_points

func increase_speed() -> void:
	speed += 30

func reverse_direction() -> void:
	direction = -direction
	position.y += 10

# Quand l'Area2D entre en collision avec un mur
func _on_body_entered(body: Node2D) -> void:
	emit_signal("invader_collision_with_wall_detected", body)
