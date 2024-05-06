extends CharacterBody3D

const base_speed = 5.0
var current_stamina
const maxStamina = 200
var speed
const JUMP_VELOCITY = 4.5

const sensivity = 0.003

const bob_freq = 2.0
const bom_amp = 0.08
var t_bob = 0.0

var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	speed = base_speed
	current_stamina = maxStamina
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensivity)
		camera.rotate_x(-event.relative.y * sensivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_pressed("run") and is_on_floor() and current_stamina > 0:
		speed = base_speed * 2
		current_stamina -= 40 * delta
		current_stamina = clamp(current_stamina, 0, maxStamina)
	if not Input.is_action_pressed("run"):
		current_stamina += 10 * delta
		speed = base_speed
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bom_amp
	pos.x = cos(time * bob_freq / 2) * bom_amp
	return pos
