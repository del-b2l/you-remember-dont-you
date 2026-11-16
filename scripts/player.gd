extends CharacterBody3D

const MOVE_SPEED := 3.2
const MOUSE_SENSITIVITY := 0.0022
const INTERACTION_DISTANCE := 3.6

var camera: Camera3D
var ray: RayCast3D
var gravity := 9.8

func _ready() -> void:
    name = "Player"
    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.32
    capsule.height = 1.75
    collision.shape = capsule
    collision.position.y = 0.88
    add_child(collision)

    camera = Camera3D.new()
    camera.name = "Camera3D"
    camera.position.y = 1.55
    camera.current = true
    add_child(camera)

    ray = RayCast3D.new()
    ray.target_position = Vector3(0, 0, -INTERACTION_DISTANCE)
    ray.collide_with_areas = false
    ray.collide_with_bodies = true
    camera.add_child(ray)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
        camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
        camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-82), deg_to_rad(82))
    if event.is_action_pressed("interact"):
        _try_interact()
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        velocity.y = 0

    var input_vector := Vector2(
        Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
        Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
    )
    var direction := (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
    if direction:
        velocity.x = direction.x * MOVE_SPEED
        velocity.z = direction.z * MOVE_SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, MOVE_SPEED)
        velocity.z = move_toward(velocity.z, 0, MOVE_SPEED)
    move_and_slide()

func _try_interact() -> void:
    ray.force_raycast_update()
    if ray.is_colliding():
        var target := ray.get_collider()
        var main := get_parent()
        if main.has_method("interact"):
            main.interact(target)
