extends CharacterBody3D
@onready var head = $Head


var current_speed = 5.0
const walkSpeed = 5.0
const sprintSpeed = 8.0
const crouchSpeed = 3.0
const jump_velocity = 4.5

const head_position = 1.8
const lerp_speed = 10.0
const crouching_depth = 0.9

var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO
var slide_speed = 10.0


var crouching = false
var sprinting = false
var walking = false
var sliding = false

var direction = Vector3.ZERO
const  mouse_sens = 0.06

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	
	var input_dir = Input.get_vector("gauche", "droite", "avant", "arriere")
	
	
	if Input.is_action_pressed("crouch"):
		current_speed = crouchSpeed
		head.position.y = lerp(head.position.y, crouching_depth, delta*lerp_speed)
		$HitBoxStand.disabled = true
		$HitBoxCrouch.disabled = false
		if sprinting && input_dir != Vector2.ZERO:
			sliding = true
			slide_vector = input_dir
			slide_timer = slide_timer_max
			
		
		crouching = true
		sprinting = false
		walking = false

	elif !$RayCast3D.is_colliding():
		$HitBoxStand.disabled = false
		$HitBoxCrouch.disabled = true
		head.position.y = lerp(head.position.y, head_position, delta*lerp_speed)


		if Input.is_action_pressed("sprint"):
			current_speed = sprintSpeed
			crouching = false
			sprinting = true
			walking = false
			sliding = false
		else:
			current_speed = walkSpeed
			crouching = false
			sprinting = false
			walking = true
			sliding = false


	if sliding:
		slide_timer-= delta
		if slide_timer <=0:
			sliding = false



	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta


	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		sliding = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

		if sliding:
				velocity.x = direction.x * (slide_timer+0.1) *slide_speed
				velocity.z = direction.z * (slide_timer+0.1) * slide_speed

	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
