extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var state = "small"
var paused = false
var direction
var jumped = false


func get_mushroom():
	paused = true
	$GrowTimer.start()
	$AnimatedSprite2D.speed_scale = 1
	$AnimatedSprite2D.animation = "growing"
	print("MUSHROOM MUSHROOM!")


func _process(_delta):
	if paused:
		return

	if is_on_floor():
		if velocity.x > 0 and direction > 0:
			$AnimatedSprite2D.scale.x = 1
			$AnimatedSprite2D.animation = "%s_running" % state
		elif velocity.x < 0 and direction < 0:
			$AnimatedSprite2D.scale.x = -1
			$AnimatedSprite2D.animation = "%s_running" % state
		elif velocity.x > 0 and direction < 0:
			$AnimatedSprite2D.scale.x = -1
			$AnimatedSprite2D.animation = "%s_turning" % state
		elif velocity.x < 0 and direction > 0:
			$AnimatedSprite2D.scale.x = 1
			$AnimatedSprite2D.animation = "%s_turning" % state
		elif velocity.x == 0:
			$AnimatedSprite2D.animation = "%s_standing" % state
		else:
			$AnimatedSprite2D.animation = "%s_running" % state
			
		$AnimatedSprite2D.speed_scale = abs(velocity.x / 50)
	
	elif jumped:
		$AnimatedSprite2D.animation = "%s_jumping" % state
		
	else:
		$AnimatedSprite2D.speed_scale = 0
		
	


func _physics_process(delta):
	if paused:
		return
		
	var acceleration = 8
	var stopping_acceleration = 8
	var top_speed = 100.0
	var jump_velocity = -375.0
	
	if Input.is_action_pressed("run"):
		top_speed = 150.0
	
	# Add the gravity.
	if is_on_floor():
		jumped = false
	else:
		acceleration = 3
		stopping_acceleration = 0
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() || !$CayoteTimer.is_stopped()):
		jumped = true
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("left", "right")
	
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, stopping_acceleration)
	else:
		velocity.x = move_toward(velocity.x, direction * top_speed, acceleration)

	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	if was_on_floor and !is_on_floor():
		$CayoteTimer.start()


func _on_grow_timer_timeout():
	state = "big"
	paused = false
	
	$SmallCollisionRectangle.set_deferred("disabled", true)
	$BigCollisionRectangle.set_deferred("disabled", false)
	
	if is_on_floor():
		$AnimatedSprite2D.animation = "after_grow_in_air"
	else:
		$AnimatedSprite2D.animation = "big_standing"
