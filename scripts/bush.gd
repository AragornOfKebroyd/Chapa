extends StaticBody2D


func _ready() -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("collided")
		event_bus.emit_signal("player_hidden", true)
		modulate.a8 = 150


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		event_bus.emit_signal("player_hidden", false)
		modulate.a8 = 255
