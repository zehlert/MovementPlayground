extends CharacterBody3D

@export var speed = 6
@export var sprint_speed = 10
@export var slide_speed = 20
@export var jump_velocity = 8
@export var air_speed = 0.1
@export var sensitivity = 0.005

var move_speed = speed
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var neck := $Neck
@onready var camera := $Neck/Camera3D

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed('ui_cancel'):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * sensitivity)
			camera.rotate_x(-event.relative.y * sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
			

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Handle sprint
	if Input.is_action_pressed('sprint'):
		move_speed = sprint_speed
	else:
		move_speed = speed
	
	# Handle movment while touching the ground
	if is_on_floor():
		if direction:
			velocity.x = direction.x * move_speed
			velocity.z = direction.z * move_speed
			
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

	# Handle movement while in the air
	if not is_on_floor():
		if direction:
			velocity.x += direction.x * air_speed
			velocity.z += direction.z * air_speed

	move_and_slide()
