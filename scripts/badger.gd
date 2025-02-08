extends CharacterBody2D


var speed = 200
var state : String = "patrol"

@export_enum("linear", "loop") var patrol_type = "linear"

@onready var pathfollow = get_parent()

func _ready() -> void:
	event_bus.badger_detected.connect(_on_object_detected_badger)


func patrol(delta):
	if patrol_type == "loop":
		pathfollow.progress += speed * delta


func _physics_process(delta: float) -> void:
	if state == "patrol":
		patrol(delta)

func _on_object_detected_badger(sound_position):
	print("signal recieved from position",sound_position)
