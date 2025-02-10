extends CharacterBody2D


var speed = 100
var investigate_speed_increase = 1.6
var follow_speed_increase = 2
var state : String = "patrol"
var target_position : Vector2
var start_position : Vector2
var targeting = false
var random_numbers = range(1, 500) # Generates [1, 2, ..., n]
var player_hiding = false


@export_enum("linear", "loop") var patrol_type = "loop"
var player

@onready var pathfollow = get_parent()
@onready var nav_agent = $NavigationAgent2D
@onready var anim_sprite = $AnimatedSprite2D  # Reference to the AnimatedSprite2D node

func _ready() -> void:
	nav_agent.target_desired_distance = 4.0
	nav_agent.path_desired_distance = 4.0
	event_bus.badger_detected.connect(_on_object_detected_badger)#
	event_bus.freeze_badger.connect(freeze_badger)
	event_bus.player_hidden.connect(_on_player_hidden)

var badger_frozen = false
func freeze_badger(bool_val):
	badger_frozen = bool_val

func random_pause():
	return (random_numbers[randi() % random_numbers.size()] == 1)

func wait(seconds: float) -> void:
	set_physics_process(false)
	get_tree().create_timer(seconds).timeout.connect(func(): set_physics_process(true))

var paused = false
var patrol_direction = 1

# sprite and particles
@onready var particles = $CPUParticles2D

func badger_sprite_flip():
	if velocity.length() > 0:
		anim_sprite.play("run")
		particles.emitting = true

	else:
		anim_sprite.play("idle")
		particles.emitting = false
		
	if velocity.x > 0:  # Moving right
		anim_sprite.flip_h = false
	elif velocity.x < 0:  # Moving left
		anim_sprite.flip_h = true
		
		
func pause_movement():
	paused = true
	
	# random pause time
	var pause_time = randf_range(2.0, 4.0)
	get_tree().create_timer(pause_time).timeout.connect(func(): 
		paused = false
		if randi_range(0, 2) <= 1: # after pause ended, have 50% chance to reverse direction
			patrol_direction *= -1)


# badger follows predefined path
func patrol(delta):
	if paused:
		velocity = Vector2(0, 0)
		return
	
	if patrol_type == "loop":		
		# calculate velocity from pathfollow
		var prev_position = pathfollow.global_position  # Store previous position
		pathfollow.progress += speed * delta * patrol_direction  # Move along path
		var new_position = pathfollow.global_position  # Get new position

		velocity = (new_position - prev_position) / delta  # Calculate velocity
		
			
		# random pause
		if randi_range(0, 1000) < 3:
			pause_movement()


# Badger goes to squeak origin
func target(delta):
	# Moves back to loop when finished
	if nav_agent.is_navigation_finished():
		nav_agent.target_position = start_position
		state = "return"
		wait(2.0) # "Investigates" sound
	
	var next_point = nav_agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()
	
	velocity = direction * speed * investigate_speed_increase
	move_and_slide()

# Badger follows player
func follow(delta):
	
	# check it can see the player
	#var space_state = get_world_2d().direct_space_state
	#var query = PhysicsRayQueryParameters2D.create(global_position, player.global_position)
	#var result = space_state.intersect_ray(query)
	#if result:
		#nav_agent.target_position = start_position
		#state = "return"
		#wait(1.0)
	
	if player_hiding:
		nav_agent.target_position = start_position
		state = "return"
		wait(1.0)
	
	var next_point = nav_agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()
	
	velocity = direction * speed * follow_speed_increase # badger moves slightly quicker when following
	
	move_and_slide()
	


func return_to_path(delta):
	if nav_agent.is_navigation_finished():
		state = "patrol"

	var next_point = nav_agent.get_next_path_position()
	var direction = (next_point - global_position).normalized()
	
	velocity = direction * speed
	move_and_slide()
	


func _physics_process(delta: float) -> void:
	if badger_frozen: return
	if state == "patrol": # loop path
		start_position = global_position
		patrol(delta)
	if state == "target": # squeak origin
		target(delta)
	if state == "return": # go back to loop path
		return_to_path(delta)
	if state == "follow": # hunt down player
		nav_agent.target_position = player.global_position
		follow(delta)
	
	badger_sprite_flip()

func _on_object_detected_badger(sound_position, collider_id):
	print(get_instance_id(), collider_id)
	if get_instance_id() != collider_id: return
	#start_position = global_position
	target_position = sound_position
	nav_agent.target_position = target_position
	
	print(state)
	
	if state != "follow" and state != "target":
		wait(1.0)
	
	if state != "follow":
		state = "target"
	

func _on_player_hidden(player_hidden_status):
	player_hiding = player_hidden_status
	print(player_hiding)


# Badger starts following player
func _on_view_body_entered(body: Node2D) -> void:
	print(body)
	player = body
	if body.is_in_group("Player"):
		state = "follow"

# Badger returns to loop
func _on_view_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		nav_agent.target_position = start_position
		state = "return"
		wait(1.0)


func _on_area_2d_body_entered(body):
	# check it is the player
	if body.has_method("process_squeak"):
		event_bus.restart_level.emit()
