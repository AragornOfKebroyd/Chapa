extends CharacterBody2D


var speed = 100
var state : String = "patrol"
var target_position : Vector2
var start_position : Vector2
var targeting = false

@export_enum("linear", "loop") var patrol_type = "linear"
@export var player : CharacterBody2D 

@onready var pathfollow = get_parent()
@onready var nav_agent = $NavigationAgent2D
#@onready var player = get_parent().get_parent().get_parent().get_node("player")

func _ready() -> void:
	nav_agent.target_desired_distance = 4.0
	nav_agent.path_desired_distance = 4.0
	event_bus.badger_detected.connect(_on_object_detected_badger)

# badger follows predefined path
func patrol(delta):
	if patrol_type == "loop":
		pathfollow.progress += speed * delta

# badger investigates sound
# then moves back to loop start
func target(delta):
	if nav_agent.is_navigation_finished():
		nav_agent.target_position = start_position
		state = "return"
		get_tree().create_timer(1.0).timeout.connect(func(): true)

	var next_point = nav_agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()
	
	velocity = direction * speed
	move_and_slide()

# badger follows player
# then moves back to loop start
func follow(delta):
	var next_point = nav_agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()
	
	velocity = direction * speed
	
	move_and_slide()


func return_to_path(delta):
	if nav_agent.is_navigation_finished():
		state = "patrol"

	var next_point = nav_agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()
	
	velocity = direction * speed
	move_and_slide()


func _physics_process(delta: float) -> void:
	if state == "patrol":
		start_position = global_position
		patrol(delta)
	if state == "target":
		target(delta)
	if state == "return":
		return_to_path(delta)
	if state == "follow":
		nav_agent.target_position = player.global_position
		follow(delta)

func _on_object_detected_badger(sound_position):
	#start_position = global_position
	target_position = sound_position
	nav_agent.target_position = target_position
	state = "target"

func _on_view_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		state = "follow"


func _on_view_body_exited(body: Node2D) -> void:
	print(start_position)
	if body.is_in_group("Player"):
		nav_agent.target_position = start_position
		state = "return"
