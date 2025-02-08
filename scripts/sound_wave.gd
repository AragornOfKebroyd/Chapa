extends Node2D
@export var wave_speed: float = 500.0  # Speed of expansion
@export var max_radius: float = 700.0  # Maximum expansion size

var radius = 5
# Called when the node enters the scene tree for the first time.

@export var start_radius: float = 5.0  # Initial radius of the circle
@export var segments: int = 512  # Number of points in the circle

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
	
@onready var line = $Line2D
func _draw():
	
	var c = Color.WHITE
	c.a = 0.3

	draw_polygon(line.points, [c])


func update_wave():
	line.clear_points()

	
	
	for p in points:
		line.add_point(p)
	
	queue_redraw()
signal object_detected

@onready var collision_polygon_2d = $Area2D/CollisionPolygon2D

var badger_hit = false

func process_wave(delta, rad):
	
	var perc_dist = rad / max_radius
	
	opacity = (1-perc_dist)**2
	
	modulate.a = opacity
	
	for i in range(segments+1):
		var new_pos = points[i] + velocities[i] * delta
		
		# check for collision
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(points[i] + global_position, new_pos + global_position)
		var result = space_state.intersect_ray(query)
		
		if result:
			# Bounce the point if it hits something
			#var normal = result.normal

			# Bounce
			#velocities[i] = velocities[i].bounce(normal)
			
			# Wrap around
			velocities[i] = Vector2.ZERO
			points[i] = result.position
			
			if result.collider and result.collider.has_method("_on_object_detected_badger") and not badger_hit:  # Check if the object has a certain method
				print("signal emitted")
				event_bus.emit_signal("badger_detected",global_position)
				badger_hit = true
		
		points[i] = new_pos  # Update position
		
		
		# check for badger collision
		#var params = PhysicsPointQueryParameters2D.new()
		#params.position = points[i] + global_position
		#params.collide_with_bodies = true
		#params.collide_with_areas = true
		#
		#var results = space_state.intersect_point(params)
		#for res in results:
			#var obj = res.collider
			#print(obj)
			
				#emit_signal("object_detected")  # Trigger a signal with the object
		
	update_wave()
	
	
func _ready():
	create_wave()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

var opacity = 1
func _physics_process(delta):
	radius += wave_speed * delta
	
	process_wave(delta, radius)
	
	if radius > max_radius:
		queue_free()
	
func _on_Area2D_area_entered(area):
	if area.has_method("on_wave_hit"):
		area.on_wave_hit(global_position)

func _on_Area2D_body_entered(body):
	if body.has_method("on_wave_hit"):
		body.on_wave_hit(global_position)
