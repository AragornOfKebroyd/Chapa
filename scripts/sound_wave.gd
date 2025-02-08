extends Node2D
@export var wave_speed: float = 400.0  # Speed of expansion
@export var max_radius: float = 500.0  # Maximum expansion size

var radius = 5
# Called when the node enters the scene tree for the first time.

@export var start_radius: float = 50.0  # Initial radius of the circle
@export var segments: int = 64  # Number of points in the circle


func draw_wave(r):
	
	var perc_dist = radius / max_radius
	
	opacity = 1 * (1-perc_dist)**2
	
	
	modulate.a = opacity
	
	# make line2d a circle
	var line = $Line2D
	line.clear_points()
	
	for i in range(segments + 1):  # +1 to close the loop
		var angle = i * TAU / segments  # TAU = 2 * PI
		var point = Vector2(cos(angle), sin(angle)) * r
		line.add_point(point)

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var opacity = 1
func _physics_process(delta):
	radius += wave_speed * delta
	draw_wave(radius)
	$Area2D/CollisionShape2D.shape.radius = radius
	
	
	
	if radius > max_radius:
		queue_free()
	

func _on_Area2D_area_entered(area):
	if area.has_method("on_wave_hit"):
		area.on_wave_hit(global_position)

func _on_Area2D_body_entered(body):
	if body.has_method("on_wave_hit"):
		body.on_wave_hit(global_position)
