extends Node2D

@onready var intro_player = $IntroPlayer  # Reference to the AudioStreamPlayer for intro
@onready var loop_player = $LoopPlayer  # Reference to the AudioStreamPlayer for looping part

# Called when the node enters the scene tree for the first time.
func _ready():
	intro_player.play()
	intro_player.finished.connect(_on_intro_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called when the intro finishes
func _on_intro_finished():
	intro_player.stop() 
	loop_player.play() 
