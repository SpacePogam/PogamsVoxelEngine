extends CharacterBody3D

var move_dir
var look_dir: Vector2
var captured = false
var walk_vel: Vector3
var maxspeed = 3.5
var jump_vel: Vector3
var grav_vel: Vector3
var jumppower = 1.2
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var crouching = false
@onready var ray = $Camera3D/RayCast3D
@onready var tip = $Camera3D/RayCast3D/Tip
signal getTile
signal placeTile
signal breakTile
signal givePos

var jumping = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	captured = true

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	var _forward: Vector3 = $Camera3D.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * maxspeed * move_dir.length(), 100 * delta)
	return walk_vel

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		jumping = true
	else:
		jumping = false
	velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	move_and_slide()
	pass

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") and captured == true:
		captured = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif Input.is_action_just_pressed("ui_cancel") and captured == false:
		captured = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if captured: _rotate_camera()
	
	if Input.is_action_just_pressed("use"):
		if ray.is_colliding() and ray.get_collider() == get_node("/root/worldTest/tiles"):
			placeTile.emit(ray.get_collision_point(),ray.get_collision_normal())
	
	if Input.is_action_just_pressed("hit"):
		if ray.is_colliding() and ray.get_collider() == get_node("/root/worldTest/tiles"):
			breakTile.emit(ray.get_collision_point())
	
	if Input.is_action_just_pressed("crouch"):
		crouching = true
		$CollisionShape3D.shape.size.y = 1.2
		position.y -= 0.4
		maxspeed = 2
	if Input.is_action_just_released("crouch"):
		crouching = false
		$CollisionShape3D.shape.size.y = 2
		position.y += 0.4
		maxspeed = 3.5
	
	if Input.is_action_pressed("sprint") and not Input.is_action_pressed("crouch"):
		maxspeed = 5
	if Input.is_action_just_released("sprint") and not Input.is_action_pressed("crouch"):
		maxspeed = 3.5

func _rotate_camera():
	$Camera3D.rotation.y -= look_dir.x * 1.25 * 1
	$Camera3D.rotation.x = clamp($Camera3D.rotation.x - look_dir.y * 1.25 * 1, -1.5, 1.5)
	$CollisionShape3D.rotation.y -= look_dir.x * 1.25 * 1
	pass

func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jumppower * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func _process(_delta):
	if ray.is_colliding() and ray.get_collider() == get_node("/root/worldTest/tiles"):
		getTile.emit(ray.get_collision_point())
	else:
		getTile.emit(tip.global_position)
	givePos.emit(position)
	pass
