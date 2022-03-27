extends KinematicBody


export(float) var MASS : float = 5
var GRAVITY : float = -9.8 * MASS
var vel = Vector3()
export(float) var MAX_SPEED : float = 20
export(float) var JUMP_SPEED : float = 18
export(float) var ACCEL : float = 4.5

var dir = Vector3()

export(float) var DEACCEL : float = 16
export(float) var MAX_SLOPE_ANGLE : float = 40

onready var camera = $Rotation_Helper/Camera
onready var rotation_helper = $Rotation_Helper
onready var weapons = $Rotation_Helper/weapons
onready var shotgun = $Rotation_Helper/weapons/shotgun
onready var shotgun_shot_point = $Rotation_Helper/weapons/shotgun/shot_point
onready var decal = preload("res://scenes//Decal.tscn")

export(float) var bullet_max_dist : float = -1000
export(float) var spread : float = 100

var health : int = 100
export(int) var shotgun_damage : int  = 10

var selected_weapon = 0

var MOUSE_SENSITIVITY = 0.05
var rng = RandomNumberGenerator.new()


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	for _i in range(10):
		rng.randomize()
		var raycast = RayCast.new()
		raycast.enabled = true
		raycast.cast_to = Vector3(rng.randf_range(-spread, spread), rng.randf_range(-spread, spread), bullet_max_dist)
		print(raycast.cast_to)
		shotgun_shot_point.add_child(raycast)


func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	
	if Input.is_action_just_pressed("primary_fire"):
		if selected_weapon == 0:
			fire_shotgun()


func process_input(_delta):
	
	# ----------------------------------
	# Walking
	dir = Vector3()
	var cam_xform = camera.get_global_transform()
	
	var input_movement_vector = Vector2()
	
	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
	
	input_movement_vector = input_movement_vector.normalized()
	
	# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
	# ----------------------------------
	
	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	# ----------------------------------
	
	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------


func process_movement(delta):
	dir.y = 0
	dir = dir.normalized()
	
	vel.y += delta * GRAVITY
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir
	target *= MAX_SPEED
	
	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL
	
	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
		
		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot


func damage(damage : int):
	health -= damage


func death():
	var _reload = get_tree().reload_current_scene()


func fire_shotgun():
	var decal_instance
		
	for i in shotgun_shot_point.get_children():
		rng.randomize()
		i.cast_to.x = rng.randf_range(-spread, spread)
		i.cast_to.y = rng.randf_range(-spread, spread)
		
		print("i raycast cast_to: " + str(i.cast_to))
		
		decal_instance = decal.instance()
		
		if i.is_colliding():
			get_parent().get_child(0).add_child(decal_instance)
			decal_instance.global_transform.origin = i.get_collision_point()
