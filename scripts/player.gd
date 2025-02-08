extends CharacterBody2D

signal collision
signal hit

@export var SPEED = 240.0
const JUMP_VELOCITY = -400.0
var screen_size

func _ready():
	screen_size = get_viewport_rect().size




func _process(delta: float):
	# set animation
	if velocity.length() > 0:
		pass
	else:
		pass

const mu = 0.2
const THRESHHOLD = 7
const ONE_OVER_ROOT_TWO = 0.70710678118
var fMult = SPEED * SPEED * mu

func _physics_process(delta: float) -> void:
	#velocity = Vector2.ZERO
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
	print("force: ", force, "\nresistance", resistance, "\nacceleration: ", acceleration,"\nvelocity: ",velocity)
	
	#if sign(velocity + acceleration * delta) == sign(velocity) or velocity == Vector2.ZERO:
	velocity += acceleration * delta
	#else:
		#velocity = Vector2.ZERO
	
	if abs(velocity.x) < THRESHHOLD and sign(velocity) != sign(acceleration):
		velocity.x = 0
	if abs(velocity.y) < THRESHHOLD and sign(velocity) != sign(acceleration):
		velocity.y = 0
	
	position += velocity * delta
