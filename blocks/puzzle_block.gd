extends Node2D

enum BlockState {ALIVE, HIT, DEAD}

const hit_animation_speed = 10
var state: BlockState = BlockState.ALIVE

func _process(delta):
	match state:
		BlockState.HIT:
			$Path2D/PathFollow2D.progress_ratio += hit_animation_speed * delta
			
			if $Path2D/PathFollow2D.progress_ratio >= 1.0:
				state = BlockState.DEAD


func _on_hit(_body):
	match state:
		BlockState.ALIVE:
			$Path2D/PathFollow2D/AnimatedSprite2D.animation = "dead"
			state = BlockState.HIT
