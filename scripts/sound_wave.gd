extends Node2D
@export var wave_speed: float = 200.0  # Speed of expansion
@export var max_radius: float = 300.0  # Maximum expansion size
@export var dropoff_rate: float = 100.0 # rate at which the sound decays



var radius = 5
# Called when the node enters the scene tree for the first time.

@export var start_radius: float = 50.0  # Initial radius of the circle
@export var segments: int = 64  # Number of points in the circle
func _ready():
	# make line2d a circle
	var line = $Line2D
	line.clear_points()
	
	for i in range(segments + 1):  # +1 to close the loop
		var angle = i * TAU / segments  # TAU = 2 * PI
		var point = Vector2(cos(angle), sin(angle)) * start_radius
		line.add_point(point)
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _physics_process(delta):
	radius += wave_speed * delta
	scale = Vector2(radius / 10.0, radius / 10.0)  # Scale sprite to match
	$Area2D/CollisionShape2D.shape.radius = radius
	if radius > max_radius:
		queue_free()
	

func _on_Area2D_area_entered(area):
	if area.has_method("on_wave_hit"):
		area.on_wave_hit(global_position)

func _on_Area2D_body_entered(body):
	if body.has_method("on_wave_hit"):
		body.on_wave_hit(global_position)
