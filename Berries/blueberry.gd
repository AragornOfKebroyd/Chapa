extends Area2D

# Define a custom signal
signal blueberry_collided

# Called when the node enters the area of another object
func _on_body_entered(body):
	if body.is_in_group("player"):  # Check if the body is the player
		emit_signal("blueberry_collided")  # Emit the signal when collision occurs
		print("blueberry")
		queue_free()  # Optional: remove the blueberry after collision
