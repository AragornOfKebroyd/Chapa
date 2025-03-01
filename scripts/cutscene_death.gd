extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var label = $Label

var alpha = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	color_rect.color = Color(0,0,0,0)
	
	var tween = create_tween()
	label.visible_ratio = 0
	tween.tween_property(label, "visible_ratio", 1, 3)
	tween.finished.connect(death_over)

signal death_cutscene_over

func death_over():
	get_tree().create_timer(1).timeout.connect(remove_self)

func remove_self():
	death_cutscene_over.emit()
	queue_free()

func _physics_process(delta):
	if alpha < 0.7:
		alpha += 0.004
	
	color_rect.color = Color(0,0,0,alpha)
