extends CanvasLayer
#
@onready var textBoxContainer = $TextBox/MarginContainer
@onready var label = $TextBox/MarginContainer/Panel/MarginContainer/HBoxContainer/Text
@onready var start_symbol = $TextBox/MarginContainer/Panel/MarginContainer/HBoxContainer/StartSymbol
@onready var end_symbol = $TextBox/MarginContainer/Panel/MarginContainer/HBoxContainer/EndSymbol
@onready var bg_texture = $TextureRect

const CHARACTER_READ_RATE = 0.05

@export var text_array: Array[String]
@export var background_image: Texture2D


enum State {
	READY,
	READING,
	FINISHED
}

var text_queue = []

var current_state = State.READY
var debug = false

func change_state(next_state):
	current_state = next_state
	if !debug: return
	match current_state:
		State.READY:
			print("Changing state to State.READY")
		State.READING:
			print("Changing state to State.READING")
		State.FINISHED:
			print("Changing state to State.FINISHED")
		

var start = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if debug: print("Starting State is State.READY")
	hide_textbox()

func set_image():
	bg_texture.texture = background_image

func instantiate():
	set_image()
	show_all_text()
	start = true
	
func show_all_text():
	for item in text_array:
		queue_text(item)

func show_text(text):
	hide_textbox()
	display_text()

func queue_text(text):
	text_queue.push_back(text)

signal stop_tween
signal slide_finished

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !start: return
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				display_text()
			else:
				hide_textbox()
				emit_signal("slide_finished")
				queue_free()
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				label.visible_ratio = 1
				stop_tween.emit()
				finished_reading()
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				change_state(State.READY)
				label.text = ""
				start_symbol.text = ""
				end_symbol.text = ""
#
func hide_textbox():
	label.text = ""
	start_symbol.text = ""
	end_symbol.text = ""
	textBoxContainer.hide()

func show_textbox():
	start_symbol.text = "*"
	textBoxContainer.show()

func display_text():
	var next_text = text_queue.pop_front()
	label.text = next_text
	change_state(State.READING)
	show_textbox()
	var tween = create_tween()
	label.visible_ratio = 0
	tween.tween_property(label, "visible_ratio", 1, len(next_text) * CHARACTER_READ_RATE)
	tween.finished.connect(finished_reading)
	connect("stop_tween",tween.stop)

func finished_reading():
	end_symbol.text = "*"
	change_state(State.FINISHED)
