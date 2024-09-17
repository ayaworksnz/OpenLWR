extends CharacterBody3D

signal unclick_left()

@onready var Cam = $Head/Camera3d as Camera3D
var mouseSensibility = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0
const SPEED = 5.0
var right_mouse_not_pressed = 0
var zoom_toggle = false

var input_dir = Vector2(0,0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(_delta):
	var tween = get_tree().create_tween()
	if zoom_toggle:
		tween.tween_property($Head/Camera3d, "fov", 15, 0.1)
	else:
		tween.tween_property($Head/Camera3d, "fov", 75, 0.1)
	tween.play()
	
	# Get the input direction and handle the movement/deceleration.
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

var mb1 = false

func _unhandled_input(event: InputEvent):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mb1 = true #TODO: garbaj code
		
	if mb1 and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		mb1 = false
		unclick_left.emit()
	
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		rotation.y -= event.relative.x / mouseSensibility
		$Head/Camera3d.rotation.x -= event.relative.y / mouseSensibility
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
	elif event is InputEventMouseMotion:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if $Head/Camera3d/Chat/Edit.has_focus():
			input_dir = Vector2(0,0)
		if event.is_action_pressed("menu_toggle"):
			get_node("Head/Camera3d/Menu").visible = true
		if event.is_action_pressed("zoom"):
			if $"Head/Camera3d/Menu/Settings/Settings/Controls/CheckButton".button_pressed:
				zoom_toggle = not zoom_toggle
			else:
				zoom_toggle = true
		elif event.is_action_released("zoom"):
			if not $"Head/Camera3d/Menu/Settings/Settings/Controls/CheckButton".button_pressed:
				zoom_toggle = false
