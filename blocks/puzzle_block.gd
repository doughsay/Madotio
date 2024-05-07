extends Node2D

enum BlockState {ACTIVE, INACTIVE}

var state: BlockState = BlockState.ACTIVE


func _on_hit(body: Node2D):
	if body.is_in_group("can hit blocks"):
		match state:
			BlockState.ACTIVE:
				$Path2D/PathFollow2D/AnimatedSprite2D.animation = "inactive"
				state = BlockState.INACTIVE
				
				var tween = create_tween()
				var prop_tween = tween.tween_property($Path2D/PathFollow2D, "progress_ratio", 1.0, 0.15)
				prop_tween.set_trans(Tween.TRANS_SINE)
				prop_tween.set_ease(Tween.EASE_OUT_IN)
