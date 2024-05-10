extends Node2D


func _ready():
	var tween = create_tween()
	var prop_tween = tween.tween_property($Path2D/PathFollow2D, "progress_ratio", 1.0, 0.5)
	prop_tween.set_trans(Tween.TRANS_CUBIC)
	prop_tween.set_ease(Tween.EASE_OUT_IN)
	tween.tween_callback(queue_free)
