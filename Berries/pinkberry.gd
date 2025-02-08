extends Area2D

@export var hover_speed = 2.0  # Speed of hover movement
@export var hover_height = 5.0  # Max height for up/down movement
@export var fade_time = 1.0  # Time to fade in/out
@export var fade_delay = 3.0  # Delay between each fade cycle

var base_position = Vector2.ZERO
var time = 0.0

# Renamed variable to avoid conflict with built-in 'material'
var berry_material: ShaderMaterial

func _ready():
	base_position = position  # Store starting position
	

func _process(delta):
	# Hover effect (up and down movement)
	time += delta
	position.y = base_position.y + sin(time * hover_speed) * hover_height

# Function to start the fade-in and fade-out cycle
func _start_fade_cycle():
	while true:  # Infinite loop to keep the fade cycle running
		await get_tree().create_timer(fade_delay).timeout  # Wait for the delay before fading out
		_fade_out()  # Fade out
		
		await get_tree().create_timer(fade_time).timeout  # Wait for the fade time before fading in
		_fade_in()  # Fade in

# Function to fade out the berry (make it invisible)
func _fade_out():
	berry_material.set_shader_parameter("alpha", 0)  # Set alpha to 0 (invisible)

# Function to fade in the berry (make it visible)
func _fade_in():
	berry_material.set_shader_parameter("alpha", 1)  # Set alpha to 1 (visible)
