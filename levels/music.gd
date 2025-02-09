extends Node2D

@onready var intro_player = $IntroPlayer  # Reference to the AudioStreamPlayer for intro
@onready var loop_player = $LoopPlayer  # Reference to the AudioStreamPlayer for looping part
@onready var badger_player = $BadgerPlayer

var badger_sounds = [
	preload("res://sfx/sfx1.mp3"),
	preload("res://sfx/sfx2.mp3"),
	preload("res://sfx/sfx3.mp3"),
	preload("res://sfx/sfx4.mp3"),
	preload("res://sfx/sfx5.mp3"),
	preload("res://sfx/sfx6.mp3")
]

# Called when the node enters the scene tree for the first time.
func _ready():
	intro_player.play()
	intro_player.finished.connect(_on_intro_finished)

func play_random_sound():
	var random_index = randi() % badger_sounds.size()  # Get a random index
	badger_player.stream = badger_sounds[random_index]  # Set the sound
	badger_player.play()  # Play the sound

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if randi_range(0, 10000) < 10:
		play_random_sound()

# Called when the intro finishes
func _on_intro_finished():
	intro_player.stop() 
	loop_player.play() 
