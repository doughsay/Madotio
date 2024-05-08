extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	var acceleration = 6
	var stopping_acceleration = 6
	var top_speed = 100.0
	var jump_velocity = -375.0
	
	if Input.is_action_pressed("run"):
		top_speed = 150.0
	
	# Add the gravity.
	if not is_on_floor():
		acceleration = 2
		stopping_acceleration = 0
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() || !$CayoteTimer.is_stopped()):
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")

	if is_on_floor():
		if velocity.x > 0 and direction > 0:
			$Sprite.scale.x = 1
			$Sprite.animation = "running"
		elif velocity.x < 0 and direction < 0:
			$Sprite.scale.x = -1
			$Sprite.animation = "running"
		elif velocity.x > 0 and direction < 0:
			$Sprite.scale.x = -1
			$Sprite.animation = "turning"
		elif velocity.x < 0 and direction > 0:
			$Sprite.scale.x = 1
			$Sprite.animation = "turning"
		elif velocity.x == 0:
			$Sprite.animation = "standing"
		else:
			$Sprite.animation = "running"
	
	else:
		$Sprite.animation = "jumping"
		
	#print(velocity.x)
	$Sprite.speed_scale = velocity.x / 50
	
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, stopping_acceleration)
	else:
		velocity.x = move_toward(velocity.x, direction * top_speed, acceleration)

	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	if was_on_floor and !is_on_floor():
		$CayoteTimer.start()
