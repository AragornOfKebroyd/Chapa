extends CharacterBody2D

var speed : float = 2.0
var is_straying : bool = false
var offset = 0;

@onready var navigation_agent = $NavigationAgent2D


# on collision: stops process, is_straying = true, follow_sound
# once reached sound coordinate: wait 1 sec, is_straying = false, resume path

func _on_object_detected_badger(sound_position):
	print("signal recieved from position",sound_position)

# Collides with sound wave
#func _on_Area2D_body_entered(area):
	#print("collide")
	#if body.has_method("on_wave_hit"):
		#is_straying = true
		#navigation_agent.target_position = Vector2(100, 100)
		#set_process(true)


func _ready() -> void:
	event_bus.badger_detected.connect(_on_object_detected_badger)


# Called every frame
func _process(delta):
	# Move back onto path2d
	if not is_straying:
		offset += speed * delta
		if offset > 1.0:
			offset = 0.0  # Loop back to start when reaching the end
	# Move to where sound came from
	else:
		if navigation_agent.is_navigation_finished():
			is_straying = false
			get_tree().create_timer(1).timeout.connect(func(): set_process(true))
		else:
			var next_position = navigation_agent.get_next_path_position()
			velocity = (next_position - global_position).normalized() * speed
			move_and_slide()
		
