extends CharacterBody2D

# Ground Physics

const MIN_WALKING_SPEED = 4.453125
const MAX_WALKING_SPEED = 93.75
const MAX_WALKING_SPEED_UNDERWATER = 63.75
const MAX_WALKING_SPEED_LEVEL_ENTRY = 48.75
const MAX_RUNNING_SPEED = 153.75
const WALKING_ACCELERATION = 133.59375
const RUNNING_ACCELERATION = 200.390625
const RELEASE_DECELERATION = 182.8125
const SKIDDING_DECELERATION = 365.625

# Mario does not come to a complete stop before turning around if you're
# skidding/holding the opposite direction. He immediately turns around if he's
# at or below this speed:
const SKID_TURNAROUND_SPEED = 33.75

# Jumping / Gravity Physics

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

# Air Physics

const SLOW_AIR_ACCELERATION = 133.59375
const FAST_AIR_ACCELERATION = 200.390625

const SLOW_AIR_DECELERATION = 133.59375
const MEDIUM_AIR_DECELERATION = 182.8125
const FAST_AIR_DECELERATION = 200.390625

const AIR_BREAK_CUTOFF = 108.75

# state
var state = "small"
var paused = false
var normalized_input_direction
var normalized_velocity_direction
var facing_direction = 1
var running = false
var jumped = false
var gravity = REGULAR_FALLING_GRAVITY
var hit_block = false
var skidding = false
var velocity_at_time_of_jump = 0.0
var use_jump_gravity = false

#func _ready():
	#Engine.time_scale = 0.25

func _physics_process(delta):
	if paused:
		return

	var input_direction = Input.get_axis("left", "right")

	if input_direction > 0.0:
		normalized_input_direction = 1
	elif input_direction < 0.0:
		normalized_input_direction = -1
	else:
		normalized_input_direction = 0
		
	if velocity.y >= 0:
		$SmallCollisionRectangle.disabled = false
	elif velocity.y < 0:
		$SmallCollisionRectangle.disabled = true

	_handle_run_input()
	_handle_jump_input(delta)
	
	if is_on_floor():
		_handle_ground_physics(delta, input_direction)
	else:
		_handle_gravity(delta)
		_handle_air_physics(delta, input_direction)

	if velocity.x > 0:
		normalized_velocity_direction = 1
	elif velocity.x < 0:
		normalized_velocity_direction = -1
	else:
		normalized_velocity_direction = 0

	var was_on_floor = is_on_floor()

	move_and_slide()

	if was_on_floor and !is_on_floor():
		$CayoteTimer.start()
		
	if !was_on_floor and is_on_floor():
		# just landed
		if (velocity.x > 0.0 and facing_direction == -1) or (velocity.x < 0.0 and facing_direction == 1):
			skidding = true


func _handle_run_input():
	if Input.is_action_just_pressed("run"):
		if !$RunTimer.is_stopped():
			$RunTimer.stop()
		running = true

	if Input.is_action_just_released("run") and $RunTimer.is_stopped():
		$RunTimer.start()


func _handle_jump_input(delta):
	if Input.is_action_just_pressed("jump") and (is_on_floor() || !$CayoteTimer.is_stopped()):
		hit_block = false
		jumped = true
		use_jump_gravity = true
		velocity_at_time_of_jump = abs(velocity.x)
		if velocity_at_time_of_jump < REGULAR_JUMP_VELOCITY_LESS_THAN:
			velocity.y = -REGULAR_JUMP_VELOCITY
		else:
			velocity.y = -RUNNING_JUMP_VELOCITY
	elif is_on_floor():
		jumped = false
		if normalized_input_direction > 0:
			facing_direction = 1
		elif normalized_input_direction < 0:
			facing_direction = -1


func _handle_ground_physics(delta, input_direction):
	if normalized_input_direction != 0:
		if velocity.x == 0:
			skidding = false
			velocity.x = normalized_input_direction * MIN_WALKING_SPEED
		elif (velocity.x > 0 and facing_direction == 1) or (velocity.x < 0 and facing_direction == -1):
			# walking/running in the direction of input
			skidding = false
			if running:
				#print("running")
				velocity.x = move_toward(velocity.x, input_direction * MAX_RUNNING_SPEED, RUNNING_ACCELERATION * delta)
			else:
				#print("walking")
				velocity.x = move_toward(velocity.x, input_direction * MAX_WALKING_SPEED, WALKING_ACCELERATION * delta)
		elif skidding or (velocity.x > 0 and facing_direction == -1) or (velocity.x < 0 and facing_direction == 1):
			# skidding
			#print("skidding")
			skidding = true
			if abs(velocity.x) <= SKID_TURNAROUND_SPEED:
				velocity.x = normalized_input_direction * MIN_WALKING_SPEED
				skidding = false
			else:
				velocity.x = move_toward(velocity.x, 0, SKIDDING_DECELERATION * delta)
	else:
		if velocity.x != 0:
			if skidding:
				#print("coming to a halt after skidding")
				velocity.x = move_toward(velocity.x, 0, SKIDDING_DECELERATION * delta)
			else:
				#print("coming to a halt")
				velocity.x = move_toward(velocity.x, 0, RELEASE_DECELERATION * delta)
		else:
			skidding = false


func _handle_gravity(delta):
	if !Input.is_action_pressed("jump") or velocity.y > 0:
		use_jump_gravity = false
	
	if use_jump_gravity:
		if velocity_at_time_of_jump < REGULAR_GRAVITY_LESS_THAN:
			velocity.y += REGULAR_JUMPING_GRAVITY * delta
		elif velocity_at_time_of_jump < WALKING_GRAVITY_LESS_THAN:
			velocity.y += WALKING_JUMPING_GRAVITY * delta
		else:
			velocity.y += RUNNING_JUMPING_GRAVITY * delta
	else:
		if velocity_at_time_of_jump < REGULAR_GRAVITY_LESS_THAN:
			velocity.y += REGULAR_FALLING_GRAVITY * delta
		elif velocity_at_time_of_jump < WALKING_GRAVITY_LESS_THAN:
			velocity.y += WALKING_FALLING_GRAVITY * delta
		else:
			velocity.y += RUNNING_FALLING_GRAVITY * delta

	if velocity.y > 270.0:
		velocity.y = 240.0


# FIXME: use new named constants instead of re-using existing ones, even though
# it's the same numbers
func _handle_air_physics(delta, input_direction):
	if normalized_input_direction == 0:
		return

	var max_air_velocity
	if velocity_at_time_of_jump > MAX_WALKING_SPEED:
		max_air_velocity = MAX_RUNNING_SPEED
	else:
		max_air_velocity = MAX_WALKING_SPEED

	#max_air_velocity = MAX_RUNNING_SPEED
	
	if (velocity.x > 0 and facing_direction == -1) or (velocity.x < 0 and facing_direction == 1):
		# accelerating backwards
		if abs(velocity.x) >= MAX_WALKING_SPEED:
			#print("fast backwards")
			velocity.x = move_toward(velocity.x, input_direction * max_air_velocity, FAST_AIR_DECELERATION * delta)
		elif velocity_at_time_of_jump >= AIR_BREAK_CUTOFF:
			#print("medium backwards")
			velocity.x = move_toward(velocity.x, input_direction * max_air_velocity, MEDIUM_AIR_DECELERATION * delta)
		else:
			#print("slow backwards")
			velocity.x = move_toward(velocity.x, input_direction * max_air_velocity, SLOW_AIR_DECELERATION * delta)
	else:
		# accelerating forwards
		if abs(velocity.x) < MAX_WALKING_SPEED:
			#print("slow forwards")
			velocity.x = move_toward(velocity.x, input_direction * max_air_velocity, SLOW_AIR_ACCELERATION * delta)
		else:
			#print("fast forwards")
			velocity.x = move_toward(velocity.x, input_direction * max_air_velocity, FAST_AIR_ACCELERATION * delta)


func get_mushroom():
	paused = true
	$GrowTimer.start()
	$AnimatedSprite2D.speed_scale = 1
	$AnimatedSprite2D.animation = "growing"


func _process(_delta):
	if paused:
		return
		
	$AnimatedSprite2D.scale.x = facing_direction

	if is_on_floor():
		if skidding:
			$AnimatedSprite2D.animation = "%s_turning" % state
		elif normalized_velocity_direction != 0:
			$AnimatedSprite2D.animation = "%s_running" % state
		else:
			$AnimatedSprite2D.animation = "%s_standing" % state
			
		#if normalized_velocity_direction > 0 and normalized_input_direction > 0:
			#$AnimatedSprite2D.animation = "%s_running" % state
		#elif normalized_velocity_direction < 0 and normalized_input_direction < 0:
			#$AnimatedSprite2D.animation = "%s_running" % state
		#elif normalized_velocity_direction > 0 and normalized_input_direction < 0:
			#$AnimatedSprite2D.animation = "%s_turning" % state
		#elif normalized_velocity_direction < 0 and normalized_input_direction > 0:
			#$AnimatedSprite2D.animation = "%s_turning" % state
		#elif normalized_velocity_direction != 0:
			#$AnimatedSprite2D.animation = "%s_running" % state
		#else:
			## normalized_velocity_direction and normalized_input_direction are both 0
			#$AnimatedSprite2D.animation = "%s_standing" % state
			
		$AnimatedSprite2D.speed_scale = 1 + abs(velocity.x / 50)
	
	elif jumped:
		$AnimatedSprite2D.animation = "%s_jumping" % state
		
	else:
		$AnimatedSprite2D.speed_scale = 0


func _on_run_timer_timeout():
	running = false


func _on_grow_timer_timeout():
	state = "big"
	paused = false
	
	$SmallCollisionRectangle.set_deferred("disabled", true)
	$BigCollisionRectangle.set_deferred("disabled", false)
	
	if is_on_floor():
		$AnimatedSprite2D.animation = "after_grow_in_air"
	else:
		$AnimatedSprite2D.animation = "big_standing"
