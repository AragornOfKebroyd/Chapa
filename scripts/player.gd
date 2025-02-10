extends CharacterBody2D

signal collision
signal hit

@export var SPEED = 240.0
var screen_size

# blackout screen
@onready var blackout_rect = $Blackout

func _ready():
	screen_size = get_viewport_rect().size

@onready var anim_sprite = $AnimatedSprite2D  # Reference to the AnimatedSprite2D node
@onready var squeak_player = $SqueakPlayer

var view_radius = 80.0

func _process(_delta: float):
	# set animation
	if velocity.length() > 0:
		anim_sprite.play("run")
	else:
		anim_sprite.play("idle")

	if velocity.length() > 0:
		anim_sprite.play("run")
	else:
		anim_sprite.play("idle")
		
	if velocity.x > 0:  # Moving right
		anim_sprite.flip_h = false
	elif velocity.x < 0:  # Moving left
		anim_sprite.flip_h = true
	
	
	if blackout_rect:
		var mat = blackout_rect.material
		if mat is ShaderMaterial:
			var centre_pos = get_viewport().get_camera_2d().get_screen_center_position() - (screen_size / 2)
			mat.set_shader_parameter("player_pos", global_position - centre_pos)

			mat.set_shader_parameter("light_radius", view_radius) # Adjust radius

			mat.set_shader_parameter("screen_size", get_viewport_rect().size) # Pass screen size
		
const mu = 0.2
const THRESHHOLD = 7
const ONE_OVER_ROOT_TWO = 0.70710678118
var fMult = SPEED * SPEED * mu


var expand_view = false

func _physics_process(delta: float) -> void:
	process_movement(delta)
	
	process_squeak()
	
	if expand_view:
		view_radius += 5


@export var wave_scene: PackedScene  # Drag the Wave scene into the inspector
@export var sqeak_cooldown = 0.5

var can_sqeak = true
func process_squeak():
	if Input.is_action_just_pressed("squeak") and can_sqeak and !dead:
		print("squeak")
		var min_pitch = 0.8
		var max_pitch = 1.2
		
		# Generate a random pitch between min_pitch and max_pitch
		var random_pitch = randf_range(min_pitch, max_pitch)
		squeak_player.pitch_scale = random_pitch
		squeak_player.play()
		
		var wave = wave_scene.instantiate()
		wave.global_position = global_position
		get_parent().add_child(wave)
		
		can_sqeak = false
		get_tree().create_timer(sqeak_cooldown).timeout.connect(func(): can_sqeak = true)
		

func process_movement(delta):
	#velocity = Vector2.ZERO
	if dead: return
	var force = Vector2.ZERO
	
	var up_down = 0
	var left_right = 0
	if Input.is_action_pressed("move_right"):
		left_right += 1
	if Input.is_action_pressed("move_left"):
		left_right -= 1
	if Input.is_action_pressed("move_down"):
		up_down += 1
	if Input.is_action_pressed("move_up"):
		up_down -= 1

	
	if up_down == 0:
		force.x = left_right * fMult
	elif left_right == 0:
		force.y = up_down * fMult
	else:
		force.x = left_right * fMult * 0.5
		force.y = up_down * fMult * 0.5
	
	
	# ma = Fres
	var resistance = -sign(velocity) * mu * velocity * velocity
	var acceleration = force + resistance
	
	#if sign(velocity + acceleration * delta) == sign(velocity) or velocity == Vector2.ZERO:
	velocity += acceleration * delta
	#else:
		#velocity = Vector2.ZERO
	
	if abs(velocity.x) < THRESHHOLD and sign(velocity) != sign(acceleration):
		velocity.x = 0
	if abs(velocity.y) < THRESHHOLD and sign(velocity) != sign(acceleration):
		velocity.y = 0
	
	# update position with collision
	move_and_slide()

var dead = false

func show_level():
	anim_sprite.visible = false
	expand_view = true
	dead = true

func finish_level():
	expand_view = true
	dead = true # not really, just stops movement

func hide_level():
	anim_sprite.visible = true
	view_radius = 80.0
	expand_view = false
	dead = false
