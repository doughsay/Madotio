extends CharacterBody2D

# accurate NES numbers?
const MIN_WALKING_SPEED = 4.453125
const MAX_WALKING_SPEED = 93.75
const MAX_WALKING_SPEED_UNDERWATER = 63.75
const MAX_WALKING_SPEED_LEVEL_ENTRY = 48.75
const MAX_RUNNING_SPEED = 153.75
const WALKING_ACCELERATION = 133.59375
const RUNNING_ACCELERATION = 200.390625
const RELEASE_DECELERATION = 182.8125
const SKIDDING_DECELERATION = 365.625

# if walking slower than 138.75
const REGULAR_JUMP_VELOCITY_LESS_THAN = 138.75
const REGULAR_JUMP_VELOCITY = 240.0

# if running at or faster than above
const RUNNING_JUMP_VELOCITY = 300.0

# if standing still or walking slower than 60.0
const REGULAR_GRAVITY_LESS_THAN = 60.0
const REGULAR_FALLING_GRAVITY = 1575.0
const REGULAR_JUMPING_GRAVITY = 450.0

# if walking slower than 138.75
const WALKING_GRAVITY_LESS_THAN =  138.75
const WALKING_FALLING_GRAVITY = 1350.0
const WALKING_JUMPING_GRAVITY = 421.875

# if running at or faster than above
const RUNNING_FALLING_GRAVITY = 2025.0
const RUNNING_JUMPING_GRAVITY = 562.5

# entering level from the air
const LEVEL_ENTRY_GRAVITY = 562.5

# Marios does not come to a complete stop before turning around if you're
# skidding/holding the opposite direction. He immediately turns around if he's
# at or below this speed:
const SKID_TURNAROUND_SPEED = 33.75

# old guesses, clean up/remove
const AIR_ACCELERATION = 126.5 # guess
const AIR_DECELERATION = 0.0 # guess
#const TOP_SPEED_JUMP_ADJUST = 25 # guess

var gravity = 1350.0 # guess
var jump_gravity = 500.0 # guess

# state
var state = "small"
var paused = false
var normalized_input_direction
var normalized_velocity_direction
var jumped = false
var hit_block = false

func _physics_process(delta):
	# handle gravity
	if !is_on_floor():
		velocity.y += REGULAR_FALLING_GRAVITY * delta
		if velocity.y > 270.0:
			velocity.y = 240.0

	var input_direction = Input.get_axis("left", "right")

	if input_direction > 0.0:
		normalized_input_direction = 1
	elif input_direction < 0.0:
		normalized_input_direction = -1
	else:
		normalized_input_direction = 0

	# handle input
	if normalized_input_direction != 0:
		if velocity.x == 0:
			velocity.x = normalized_input_direction * MIN_WALKING_SPEED
		elif (velocity.x > 0 and normalized_input_direction > 0) or (velocity.x < 0 and normalized_input_direction < 0):
			# walking in the direction of input
			print("walking")
			velocity.x = move_toward(velocity.x, input_direction * MAX_WALKING_SPEED, WALKING_ACCELERATION * delta)
		elif (velocity.x > 0 and normalized_input_direction < 0) or (velocity.x < 0 and normalized_input_direction > 0):
			# skidding
			print("skidding")
			if abs(velocity.x) <= SKID_TURNAROUND_SPEED:
				velocity.x = normalized_input_direction * MIN_WALKING_SPEED
			else:
				velocity.x = move_toward(velocity.x, input_direction * MAX_WALKING_SPEED, SKIDDING_DECELERATION * delta)
	else:
		if velocity.x != 0:
			velocity.x = move_toward(velocity.x, 0, RELEASE_DECELERATION * delta)

	if velocity.x > 0:
		normalized_velocity_direction = 1
	elif velocity.x < 0:
		normalized_velocity_direction = -1
	else:
		normalized_velocity_direction = 0

	print(input_direction, ", ", normalized_input_direction, ", ", velocity)
	move_and_slide()



func get_mushroom():
	paused = true
	$GrowTimer.start()
	$AnimatedSprite2D.speed_scale = 1
	$AnimatedSprite2D.animation = "growing"


func _process(_delta):
	if paused:
		return

	if is_on_floor():
		if normalized_velocity_direction > 0 and normalized_input_direction > 0:
			$AnimatedSprite2D.scale.x = 1
			$AnimatedSprite2D.animation = "%s_running" % state
		elif normalized_velocity_direction < 0 and normalized_input_direction < 0:
			$AnimatedSprite2D.scale.x = -1
			$AnimatedSprite2D.animation = "%s_running" % state
		elif normalized_velocity_direction > 0 and normalized_input_direction < 0:
			$AnimatedSprite2D.scale.x = -1
			$AnimatedSprite2D.animation = "%s_turning" % state
		elif normalized_velocity_direction < 0 and normalized_input_direction > 0:
			$AnimatedSprite2D.scale.x = 1
			$AnimatedSprite2D.animation = "%s_turning" % state
		elif normalized_velocity_direction != 0:
			$AnimatedSprite2D.scale.x = normalized_velocity_direction
			$AnimatedSprite2D.animation = "%s_running" % state
		else:
			# normalized_velocity_direction and normalized_input_direction are both 0
			$AnimatedSprite2D.animation = "%s_standing" % state
			
		$AnimatedSprite2D.speed_scale = 1 + abs(velocity.x / 50)
	
	elif jumped:
		$AnimatedSprite2D.animation = "%s_jumping" % state
		
	else:
		$AnimatedSprite2D.speed_scale = 0


#func _physics_process(delta):
	#if paused:
		#return
	#
	## Add the gravity.
	#if is_on_floor():
		#jumped = false
	#else:
		#var g = jump_gravity if jumped and Input.is_action_pressed("jump") else gravity
		##var g = gravity
		#velocity.y += g * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("jump") and (is_on_floor() || !$CayoteTimer.is_stopped()):
		#hit_block = false
		#jumped = true
		#var jump_adjust = (abs(velocity.x) / MAX_RUNNING_SPEED) * TOP_SPEED_JUMP_ADJUST
		#velocity.y = -(JUMP_VELOCITY + jump_adjust)
#
	## Get the input direction and handle the movement/deceleration.
	#direction = Input.get_axis("left", "right")
	#
	#if direction == 0:
		#var deceleration = GROUND_DECELERATION if is_on_floor() else AIR_DECELERATION
		#velocity.x = move_toward(velocity.x, 0, deceleration * delta)
	#else:
		##var acceleration = WALKING_ACCELERATION if is_on_floor() else AIR_ACCELERATION
		#var acceleration
		#if is_on_floor():
			#acceleration = RUNNING_ACCELERATION if Input.is_action_pressed("run") else WALKING_ACCELERATION
		#else:
			#acceleration = AIR_ACCELERATION
			#
		#var top_speed = MAX_RUNNING_SPEED if Input.is_action_pressed("run") else MAX_WALKING_SPEED
		#if velocity.x == 0:
			#velocity.x = direction * MIN_WALKING_SPEED
		#else:
			#velocity.x = move_toward(velocity.x, direction * top_speed, acceleration * delta)
#
	#var was_on_floor = is_on_floor()
	#
	#move_and_slide()
	#
	#if was_on_floor and !is_on_floor():
		#$CayoteTimer.start()


func _on_grow_timer_timeout():
	state = "big"
	paused = false
	
	$SmallCollisionRectangle.set_deferred("disabled", true)
	$BigCollisionRectangle.set_deferred("disabled", false)
	
	if is_on_floor():
		$AnimatedSprite2D.animation = "after_grow_in_air"
	else:
		$AnimatedSprite2D.animation = "big_standing"
