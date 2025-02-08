extends Node2D
@export var wave_speed: float = 400.0  # Speed of expansion
@export var max_radius: float = 500.0  # Maximum expansion size

var radius = 5
# Called when the node enters the scene tree for the first time.

@export var start_radius: float = 50.0  # Initial radius of the circle
@export var segments: int = 256  # Number of points in the circle


var points: Array
var velocities: Array

func create_wave():
	points.clear()
	velocities.clear()
	
	for i in range(segments + 1):
		var angle = i * TAU / segments
		var direction =  Vector2(cos(angle), sin(angle))
		var start_position = direction * start_radius
		
		points.append(start_position)
		velocities.append(direction * wave_speed)
	
	update_wave()

func update_wave():
	var line = $Line2D
	line.clear_points()
	
	for p in points:
		line.add_point(p)

func process_wave(delta):
	for i in range(segments+1):
		var new_pos = points[i] + velocities[i] * delta
		
		# check for collision
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(points[i] + global_position, new_pos + global_position)
		var result = space_state.intersect_ray(query)
		
		if result:
			# Bounce the point if it hits something
			var normal = result.normal
			velocities[i] = velocities[i].bounce(normal)
		
		points[i] = new_pos  # Update position
	update_wave()
	
	

func draw_wave(r):
	
	var perc_dist = radius / max_radius
	
	opacity = 1 * (1-perc_dist)**2
	
	
	modulate.a = opacity
	
	# make line2d a circle
	var line = $Line2D
	line.clear_points()
	
	for i in range(segments + 1):  # +1 to close the loop
		var angle = i * TAU / segments  # TAU = 2 * PI
		var direction =  Vector2(cos(angle), sin(angle))
		var point = direction * r
		line.add_point(point)

func _ready():
	#create_wave()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var opacity = 1
func _physics_process(delta):
	radius += wave_speed * delta
	draw_wave(radius)
	$Area2D/CollisionShape2D.shape.radius = radius
	
	#process_wave(delta)
	
	if radius > max_radius:
		queue_free()
	

func _on_Area2D_area_entered(area):
	if area.has_method("on_wave_hit"):
		area.on_wave_hit(global_position)

func _on_Area2D_body_entered(body):
	if body.has_method("on_wave_hit"):
		body.on_wave_hit(global_position)
