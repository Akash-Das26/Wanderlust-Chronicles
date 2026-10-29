extends CanvasLayer

@onready var survived_time_label: Label = $SurvivedTimeLabel

var survivedTime: int = 0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_survived_time_timer_timeout() -> void:
	survivedTime += 1
	survived_time_label.text = "Time Survived: " + str(survivedTime) + "s"
