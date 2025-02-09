extends Node

@onready var intro_player = $IntroPlayer  # Reference to the AudioStreamPlayer for intro
@onready var loop_player = $LoopPlayer  # Reference to the AudioStreamPlayer for looping part

func _ready():
	# Start playing the intro music
	intro_player.play()

	# Connect the 'finished' signal properly to the _on_intro_finished method
	intro_player.finished.connect(_on_intro_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called when the intro finishes
func _on_intro_finished():
	intro_player.stop() 
	loop_player.play() 
