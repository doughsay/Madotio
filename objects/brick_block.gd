extends Node2D

var coin_scene = preload("res://objects/block_coin.tscn")

func _on_hit(body: Node2D):
	if body.is_in_group("can hit blocks") and !body.hit_block:
		body.hit_block = true
		var tween = create_tween()
		var prop_tween = tween.tween_property($Path2D/PathFollow2D, "progress_ratio", 1.0, 0.15)
		prop_tween.set_trans(Tween.TRANS_SINE)
		prop_tween.set_ease(Tween.EASE_OUT_IN)
		tween.tween_callback(reset)

func reset():
	$Path2D/PathFollow2D.progress_ratio = 0
