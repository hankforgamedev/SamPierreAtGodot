class_name FPPlayer
extends CharacterBody3D

## 第一人稱控制器（Arctic Eggs 原型）
## 滑鼠視角事件由主場景（SubViewport 外）轉呼叫 rotate_look()，
## 移動用 Input 全域輪詢，不依賴 SubViewport 的輸入轉發。

const SPEED := 3.0
const ACCEL := 14.0
const LOOK_SENS := 0.0022
const INTERACT_RANGE := 2.4

var input_enabled := true
var cam: Camera3D

var _ray: RayCast3D
var _pitch_limit := deg_to_rad(85.0)
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.height = 1.7
	cap.radius = 0.3
	col.shape = cap
	col.position = Vector3(0, 0.85, 0)
	add_child(col)

	cam = Camera3D.new()
	cam.position = Vector3(0, 1.55, 0)
	cam.fov = 70.0
	add_child(cam)
	cam.current = true

	_ray = RayCast3D.new()
	_ray.target_position = Vector3(0, 0, -INTERACT_RANGE)
	cam.add_child(_ray)

	# 讓斜坡走得上去、上下坡不彈起：放寬地面角度上限 + 貼地吸附
	floor_max_angle = deg_to_rad(50.0)
	floor_snap_length = 0.5


func rotate_look(relative: Vector2) -> void:
	if not input_enabled:
		return
	rotate_y(-relative.x * LOOK_SENS)
	cam.rotation.x = clampf(cam.rotation.x - relative.y * LOOK_SENS, -_pitch_limit, _pitch_limit)


## 準星正對的可互動物件；沒有則回傳 null
func current_target() -> Node:
	if _ray.is_colliding():
		var hit := _ray.get_collider()
		if hit is Node and hit.is_in_group("interactable"):
			return hit
	return null


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta

	var move := Vector2.ZERO
	if input_enabled:
		if Input.is_physical_key_pressed(KEY_D):
			move.x += 1.0
		if Input.is_physical_key_pressed(KEY_A):
			move.x -= 1.0
		if Input.is_physical_key_pressed(KEY_S):
			move.y += 1.0
		if Input.is_physical_key_pressed(KEY_W):
			move.y -= 1.0
		move = move.limit_length(1.0)

	var dir := transform.basis * Vector3(move.x, 0.0, move.y)
	velocity.x = move_toward(velocity.x, dir.x * SPEED, ACCEL * delta)
	velocity.z = move_toward(velocity.z, dir.z * SPEED, ACCEL * delta)
	move_and_slide()
