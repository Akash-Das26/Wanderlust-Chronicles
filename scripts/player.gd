extends CharacterBody2D

const SPEED = 300.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AtttackArea
@onready var sword_swing_sound: AudioStreamPlayer = $SwordSwingSound


# Store the offset from the player to the AttackArea's collision shape
var attack_area_offset_x: float = 0.0
var is_attacking: bool = false

func _ready() -> void:
	attack_area.monitoring = false
	
	# Cache the initial relative position offset (or shape offset)
	attack_area_offset_x = attack_area.position.x
	if attack_area_offset_x == 0.0 and attack_area.has_node("CollisionShape2D"):
		# If AtttackArea is at 0, offset using its child CollisionShape2D position
		attack_area_offset_x = $AtttackArea/CollisionShape2D.position.x
	
	if not attack_area.body_entered.is_connected(_on_attack_area_body_entered):
		attack_area.body_entered.connect(_on_attack_area_body_entered)
		
	if not sprite.frame_changed.is_connected(_on_sprite_frame_changed):
		sprite.frame_changed.connect(_on_sprite_frame_changed)
		
	if not sprite.animation_finished.is_connected(_on_animation_finished):
		sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector * SPEED
		
		# Handle direction flip for both sprite and AttackArea
		if input_vector.x != 0:
			var facing_left := input_vector.x < 0
			sprite.flip_h = facing_left
			
			# Determine target direction multiplier (-1 or 1)
			var side_multiplier := -1.0 if facing_left else 1.0
			
			# 1. Flip Area2D position if it has an offset
			if attack_area_offset_x != 0.0:
				attack_area.position.x = abs(attack_area_offset_x) * side_multiplier
			
			# 2. Flip internal CollisionShape2D position as fallback
			if attack_area.has_node("CollisionShape2D"):
				var shape_node = attack_area.get_node("CollisionShape2D")
				shape_node.position.x = abs(shape_node.position.x) * side_multiplier
			
		sprite.play("walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		sprite.play("idle")

	move_and_slide()

func start_attack() -> void:
	is_attacking = true
	attack_area.monitoring = false
	sprite.frame = 0
	sprite.play("attack")
	sword_swing_sound.play()
	
	get_tree().create_timer(0.6).timeout.connect(func():
		if is_attacking:
			_end_attack()
	, CONNECT_ONE_SHOT)

func _on_sprite_frame_changed() -> void:
	if sprite.animation == "attack":
		if sprite.frame == 3:
			attack_area.monitoring = true
			call_deferred("_check_overlapping_enemies")
		else:
			attack_area.monitoring = false

func _on_animation_finished() -> void:
	if sprite.animation == "attack":
		_end_attack()

func _end_attack() -> void:
	is_attacking = false
	attack_area.monitoring = false
	sprite.play("idle")

func _on_attack_area_body_entered(body: Node2D) -> void:
	_try_kill_enemy(body)

func _check_overlapping_enemies() -> void:
	for body in attack_area.get_overlapping_bodies():
		_try_kill_enemy(body)

func _try_kill_enemy(body: Node2D) -> void:
	if body == self:
		return
		
	if body.has_method("die"):
		body.die()
	elif body.get_parent() and body.get_parent().has_method("die"):
		body.get_parent().die()
