extends Area3D

var speed = 65

func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -speed) * delta
	pass


func _on_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("enemy"):
		body.queue_free()
	queue_free()
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	queue_free()
	pass
