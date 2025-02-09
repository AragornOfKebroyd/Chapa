extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	event_bus.next_level.connect(next_level)
	event_bus.restart_level.connect(death)
	do_next_cutscene()
	
@onready var cutscene_one_two = $Cutscene_one_two/Node2D/TextureRect

@export var cutscenes: Array[PackedScene]  # Array of slide scenes
@export var player: CharacterBody2D  # Reference to the player
@export var levels: Array[PackedScene]  # Array of levels to load after cutscene
@export var death_cutscene: PackedScene

var current_cutscene_index = 0
var current_cutscene
var current_slides

var current_level_index = 0
var current_level

var death_cutscene_instance

func do_next_cutscene():
	if is_instance_valid(current_level): 
		print("level deleted", current_level)
		
		current_level.queue_free()
	remove_child(player)
	start_cutscene()

func start_cutscene():
	print(cutscenes.size())
	if current_cutscene_index < cutscenes.size():
		current_cutscene = cutscenes[current_cutscene_index].instantiate()
		add_child(current_cutscene)
		current_slides = current_cutscene.get_children()
		current_slides[0].instantiate()
		var i = 0
		for slide in current_slides:
			if i < current_slides.size() - 1:
				#print("connected slide ",slide, " to slide ",current_slides[i+1])
				slide.connect("slide_finished",current_slides[i+1].instantiate)
			else:
				print("connected slide ",slide, " to slide end")
				slide.connect("slide_finished",end_cutscene)
			i += 1
	else:
		get_tree().quit()


func end_cutscene():
	current_cutscene_index += 1
	if current_level_index < levels.size():
		var next_level = levels[current_level_index].instantiate()
		print("NEXT LEVEL", next_level)
		print("CURRENT LEVEL", current_level)
		
		# move player first
		var start_pos = next_level.find_child("PlayerStartPos")
		player.position = start_pos.global_position
		
		get_tree().get_root().add_child(next_level)  # Load new level
		
		current_level = next_level
		
		# add player back and teleport player to start
		add_child(player)

# called when berry is collected
func next_level():
	current_level_index += 1
	event_bus.freeze_badger.emit(true)
	player.finish_level()
	get_tree().create_timer(3).timeout.connect(actual_next_level)

func actual_next_level():
	player.hide_level()
	event_bus.freeze_badger.emit(false)
	do_next_cutscene()

# called when hit by badger
func death():
	death_cutscene_instance = death_cutscene.instantiate()
	add_child(death_cutscene_instance)
	player.show_level()
	death_cutscene_instance.connect("death_cutscene_over", get_rid_of_death_cutscene)

func get_rid_of_death_cutscene():
	death_cutscene_instance.queue_free()
	player.hide_level()
	set_process_input(true)
	restart_level()

func restart_level():
	# get start_pos
	var start_pos = current_level.find_child("PlayerStartPos")
	
	# move player
	player.position = start_pos.global_position
