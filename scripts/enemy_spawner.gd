extends Node2D

# Assign in Inspector or fallback to preloaded enemy.tscn
@export var enemy_scene: PackedScene = preload("res://scenes/enemy.tscn")

# Reference to the SpawnTimer child node
@onready var spawn_timer: Timer = $SpawnTimer

# Reference to player in the Game scene
@onready var player: Node2D = get_node_or_null("/root/Game/Player") as Node2D

@export var spawn_radius: float = 400.0 # Distance away from player to spawn

func _ready() -> void:
	# Connect the timer's timeout signal if not already connected
	if spawn_timer and not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout() -> void:
	if not enemy_scene:
		print("Warning: Enemy Scene is not assigned!")
		return

	# Instantiate a new enemy
	var enemy = enemy_scene.instantiate()

	# Determine spawn position
	if player:
		# Spawn randomly in a ring around the player
		var random_direction := Vector2.RIGHT.rotated(randf_range(0, TAU))
		enemy.global_position = player.global_position + (random_direction * spawn_radius)
	else:
		# Fallback to spawner node position
		enemy.global_position = global_position

	# Add enemy as a child of the main Game scene
	get_parent().add_child(enemy)
