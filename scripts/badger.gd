extends CharacterBody2D


var speed = 100
var follow_speed_increase = 1.4
var state : String = "patrol"
var target_position : Vector2
var start_position : Vector2
var targeting = false
var random_numbers = range(1, 500) # Generates [1, 2, ..., n]


@export_enum("linear", "loop") var patrol_type = "linear"
@export var player : CharacterBody2D 

@onready var pathfollow = get_parent()
@onready var nav_agent = $NavigationAgent2D
#@onready var player = get_parent().get_parent().get_parent().get_node("player")

@onready var anim_sprite = $AnimatedSprite2D  # Reference to the AnimatedSprite2D node

func _ready() -> void:
	nav_agent.target_desired_distance = 4.0
	nav_agent.path_desired_distance = 4.0
	event_bus.badger_detected.connect(_on_object_detected_badger)

func random_pause():
	return (random_numbers[randi() % random_numbers.size()] == 1)

func wait(seconds: float) -> void:
	set_physics_process(false)
	get_tree().create_timer(seconds).timeout.connect(func(): set_physics_process(true))

var paused = false
var patrol_direction = 1

func badger_sprite_flip():
	if velocity.length() > 0:
		anim_sprite.play("run")
	else:
		anim_sprite.play("idle")
		
	if velocity.x > 0:  # Moving right
		anim_sprite.flip_h = false
	elif velocity.x < 0:  # Moving left
		anim_sprite.flip_h = true
		
# badger follows predefined path
func patrol(delta):
	if paused:
		anim_sprite.play("idle")
		return
	
	anim_sprite.play("run")
	if patrol_type == "loop":		
		# calculate velocity from pathfollow
		var prev_position = pathfollow.global_position  # Store previous position
		pathfollow.progress += speed * delta * patrol_direction  # Move along path
		var new_position = pathfollow.global_position  # Get new position

		velocity = (new_position - prev_position) / delta  # Calculate velocity

		# Flip animation based on velocity
		if velocity.x > 0:
			anim_sprite.flip_h = false
		elif velocity.x < 0:
			anim_sprite.flip_h = true
			
		# random pause
		if randi_range(0, 1000) < 3:
			pause_movement()

func pause_movement():
	paused = true
	
	# random pause time
	var pause_time = randf_range(2.0, 4.0)
	get_tree().create_timer(pause_time).timeout.connect(func(): 
		paused = false
		if randi_range(0, 2) <= 1: # after pause ended, have 50% chance to reverse direction
			patrol_direction *= -1)
	
# Badger goes to squeak origin
func target(delta):
	# Moves back to loop when finished
	if nav_agent.is_navigation_finished():
		nav_agent.target_position = start_position
		state = "return"
		wait(2.0) # "Investigates" sound
	
	var next_point = nav_agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()
	
	velocity = direction * speed
	move_and_slide()
	badger_sprite_flip()

# Badger follows player
func follow(delta):
	var next_point = nav_agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()
	
	velocity = direction * speed * follow_speed_increase # badger moves slightly quicker when following
	
	move_and_slide()
	badger_sprite_flip()
	
	


func return_to_path(delta):
	if nav_agent.is_navigation_finished():
		state = "patrol"

	var next_point = nav_agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()
	
	velocity = direction * speed
	move_and_slide()
	badger_sprite_flip()
	


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
	wait(1.0)

# Badger starts following player
func _on_view_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		state = "follow"

# Badger returns to loop
func _on_view_body_exited(body: Node2D) -> void:
	print(start_position)
	if body.is_in_group("Player"):
		nav_agent.target_position = start_position
		state = "return"
		wait(1.0)
