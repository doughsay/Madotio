extends CharacterBody2D


const TOP_SPEED = 150.0
const JUMP_VELOCITY = -375.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, 10)
	else:
		velocity.x = move_toward(velocity.x, direction * TOP_SPEED, 10)

	if is_on_floor():
		if velocity.x > 0 and direction == 1:
			$Sprite.scale.x = 1
			$Sprite.animation = "running"
			
		if velocity.x < 0 and direction == -1:
			$Sprite.scale.x = -1
			$Sprite.animation = "running"
			
		if velocity.x > 0 and direction == -1:
			$Sprite.scale.x = -1
			$Sprite.animation = "turning"
			
		if velocity.x < 0 and direction == 1:
			$Sprite.scale.x = 1
			$Sprite.animation = "turning"
			
		if velocity.x == 0:
			$Sprite.animation = "standing"
	
	else:
		$Sprite.animation = "jumping"

	move_and_slide()
