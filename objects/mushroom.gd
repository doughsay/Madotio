extends CharacterBody2D


const SPEED = 50.0
const JUMP_VELOCITY = -200.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var direction = 1


func _ready():
	velocity.x = direction * SPEED


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	#if Input.is_action_just_pressed("jump"):
		#velocity.y = JUMP_VELOCITY

	if is_on_wall():
		direction *= -1
		velocity.x = direction * SPEED
#
	move_and_slide()


func _on_body_entered(body):
	if body.is_in_group("gets powerups"):
		body.get_mushroom()
		queue_free()
