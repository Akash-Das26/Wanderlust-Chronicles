extends Area2D

func _ready() -> void:
	# Connect the body_entered signal automatically
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the colliding node is the Player
	if body.is_in_group("player") or body.name == "Player":
		if body.has_method("die"):
			get_tree().paused = true
			GameOver.show()
