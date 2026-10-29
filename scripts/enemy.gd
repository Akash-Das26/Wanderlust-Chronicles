extends CharacterBody2D

@export var move_speed: float = 40.0 # Speed at which the enemy moves toward player

var sprite: AnimatedSprite2D
var player: Node2D

func _ready() -> void:
	rotation = 0
	# Automatically find any AnimatedSprite2D child node regardless of name
	sprite = find_child("*", true, false) as AnimatedSprite2D
	# Reference the player node
	player = get_node_or_null("/root/Game/Player") as Node2D

func _physics_process(_delta: float) -> void:
	if player and sprite:
		# Calculate 2D directional vector pointing directly toward player (both X and Y)
		var direction := global_position.direction_to(player.global_position)

		# Move toward the player in top-down space
		velocity = direction * move_speed

		# Horizontal sprite flipping based on relative X position
		sprite.flip_h = player.global_position.x < global_position.x
	else:
		# Stop movement if player doesn't exist
		velocity = Vector2.ZERO

	# Handle 2D movement and obstacle/wall collisions
	move_and_slide()

# Put die() at the root level of the script (unindented)
func die() -> void:
	queue_free()
