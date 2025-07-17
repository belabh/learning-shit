extends CharacterBody3D


const SPEED = 6.8
const JUMP_VELOCITY = 4.5
@export var gravity = 9.8
@onready var head: Node3D = $head
@onready var camera: Camera3D = $head/Camera3D
@export var sensitivity = 0.004
@onready var gun_raycast: RayCast3D = $head/Camera3D/gun/RayCast3D
@onready var gun_animation: AnimationPlayer = $head/Camera3D/gun/AnimationPlayer
var bullets_left = 40
var bullet = preload("res://scenes/bullet.tscn")
var health = 5


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	$head/Camera3D/Label.text = str(bullets_left) + " / 40"
	$head/Camera3D/Label2.text = "Health : " + str(health)

	# Handle jump.
	if Input.is_action_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("reload") and bullets_left != 40:
		gun_animation.play("reload")
		bullets_left = 40
	
	if Input.is_action_pressed("shoot") and bullets_left >0:
		if !gun_animation.is_playing():
			gun_animation.play("shoot")
			shoot()
		
	if health == 0:
		get_tree().reload_current_scene()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func damage():
	health -= 1

func shoot():
	bullets_left -= 1
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = gun_raycast.global_position
	bullet_instance.transform.basis = gun_raycast.global_transform.basis
	get_parent().add_child(bullet_instance)
	pass
