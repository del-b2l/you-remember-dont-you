extends Node3D

const PLAYER_SCENE_SCRIPT = preload("res://scripts/player.gd")

var discovered_clues: Array[String] = []
var recent_events: Array[String] = []
var suspicion_level := 0
var attachment_level := 0
var medication_taken := false

var dialogue_label: Label
var status_label: Label
var crosshair: Label
var prompt_label: Label
var api_status_label: Label
var dialogue_panel: PanelContainer

func _ready() -> void:
    _build_environment()
    _build_player()
    _build_ui()
    _show_dialogue("Mother", "There you are. I was beginning to worry.")
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _build_environment() -> void:
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color(0.012, 0.009, 0.018)
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.28, 0.25, 0.34)
    env.ambient_light_energy = 0.35
    world_env.environment = env
    add_child(world_env)

    _add_box("Floor", Vector3(0, -0.15, 0), Vector3(10, 0.3, 9), Color(0.16, 0.13, 0.15), true)
    _add_box("Ceiling", Vector3(0, 3.2, 0), Vector3(10, 0.2, 9), Color(0.09, 0.08, 0.11), true)
    _add_box("BackWall", Vector3(0, 1.5, -4.5), Vector3(10, 3, 0.2), Color(0.20, 0.16, 0.19), true)
    _add_box("FrontWall", Vector3(0, 1.5, 4.5), Vector3(10, 3, 0.2), Color(0.16, 0.13, 0.17), true)
    _add_box("LeftWall", Vector3(-5, 1.5, 0), Vector3(0.2, 3, 9), Color(0.18, 0.14, 0.18), true)
    _add_box("RightWall", Vector3(5, 1.5, 0), Vector3(0.2, 3, 9), Color(0.18, 0.14, 0.18), true)

    # Door frame and dark doorway on the back wall.
    _add_box("DoorFrameLeft", Vector3(3.25, 1.15, -4.36), Vector3(0.15, 2.3, 0.16), Color(0.09, 0.07, 0.08), false)
    _add_box("DoorFrameRight", Vector3(4.55, 1.15, -4.36), Vector3(0.15, 2.3, 0.16), Color(0.09, 0.07, 0.08), false)
    _add_box("DoorFrameTop", Vector3(3.9, 2.3, -4.36), Vector3(1.45, 0.15, 0.16), Color(0.09, 0.07, 0.08), false)
    _add_box("DarkDoorway", Vector3(3.9, 1.1, -4.42), Vector3(1.25, 2.1, 0.05), Color(0.015, 0.01, 0.02), false)

    # Furniture.
    _add_box("BedBase", Vector3(-2.3, 0.35, -1.2), Vector3(2.5, 0.45, 3.1), Color(0.12, 0.10, 0.13), true)
    _add_box("Mattress", Vector3(-2.3, 0.64, -1.2), Vector3(2.45, 0.18, 3.0), Color(0.37, 0.32, 0.35), false)
    _add_box("Pillow", Vector3(-2.3, 0.78, -2.25), Vector3(1.0, 0.12, 0.55), Color(0.56, 0.50, 0.52), false)
    _add_box("BedsideTable", Vector3(-0.35, 0.55, -2.1), Vector3(0.85, 1.1, 0.75), Color(0.20, 0.12, 0.10), true)
    _add_box("Wardrobe", Vector3(-4.15, 1.25, -2.3), Vector3(1.1, 2.5, 1.2), Color(0.13, 0.09, 0.09), true)
    _add_box("Rug", Vector3(-1.7, 0.015, 1.0), Vector3(3.6, 0.03, 2.0), Color(0.20, 0.13, 0.17), false)

    # Interactable clues. Their positions are deliberately easy to reach.
    _add_interactable("Family Photograph", "A family photograph. The woman's face is clear, but the child's face has been scratched away.", Vector3(-0.35, 1.22, -2.1), Color(0.48, 0.39, 0.30), "photo")
    _add_interactable("Handwritten Letter", "A folded letter. The handwriting looks hurried. It says: 'You promised you would tell them the truth.'", Vector3(1.0, 0.9, 0.8), Color(0.63, 0.55, 0.40), "letter")
    _add_interactable("Medication Schedule", "A medication schedule with today's dose circled twice. The name at the top has been torn off.", Vector3(-1.9, 0.95, -1.0), Color(0.58, 0.55, 0.46), "medication")

    _build_mother()

    var key_light := OmniLight3D.new()
    key_light.position = Vector3(0, 2.65, 0.2)
    key_light.light_color = Color(0.68, 0.55, 0.48)
    key_light.light_energy = 1.15
    key_light.omni_range = 8.0
    key_light.shadow_enabled = true
    add_child(key_light)

    var doorway_light := SpotLight3D.new()
    doorway_light.position = Vector3(3.9, 2.5, -3.7)
    doorway_light.rotation_degrees = Vector3(-12, 180, 0)
    doorway_light.light_color = Color(0.35, 0.40, 0.58)
    doorway_light.light_energy = 0.7
    doorway_light.spot_range = 5.0
    doorway_light.spot_angle = 55.0
    add_child(doorway_light)

func _build_mother() -> void:
    var mother := Node3D.new()
    mother.name = "Mother"
    mother.position = Vector3(3.9, 0, -3.35)
    mother.add_to_group("mother")
    add_child(mother)

    _make_capsule(mother, "Body", Vector3(0, 1.0, 0), 0.34, 1.25, Color(0.22, 0.19, 0.25))
    _make_sphere(mother, "Head", Vector3(0, 1.92, 0), 0.25, Color(0.64, 0.48, 0.40))
    _make_capsule(mother, "LeftArm", Vector3(-0.39, 1.02, 0), 0.10, 0.85, Color(0.22, 0.19, 0.25))
    _make_capsule(mother, "RightArm", Vector3(0.39, 1.02, 0), 0.10, 0.85, Color(0.22, 0.19, 0.25))
    _make_capsule(mother, "LeftLeg", Vector3(-0.15, 0.34, 0), 0.12, 0.65, Color(0.12, 0.11, 0.14))
    _make_capsule(mother, "RightLeg", Vector3(0.15, 0.34, 0), 0.12, 0.65, Color(0.12, 0.11, 0.14))
    var face_label := Label3D.new()
    face_label.text = "MOTHER"
    face_label.position = Vector3(0, 2.35, 0)
    face_label.font_size = 24
    face_label.modulate = Color(0.85, 0.78, 0.72)
    mother.add_child(face_label)

    var collider := StaticBody3D.new()
    collider.name = "MotherInteractable"
    collider.position = Vector3(0, 1.1, 0)
    collider.add_to_group("mother_interactable")
    var shape := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.48
    capsule.height = 2.4
    shape.shape = capsule
    collider.add_child(shape)
    mother.add_child(collider)

func _make_capsule(parent: Node3D, node_name: String, pos: Vector3, radius: float, height: float, color: Color) -> void:
    var mesh_node := MeshInstance3D.new()
    mesh_node.name = node_name
    var mesh := CapsuleMesh.new()
    mesh.radius = radius
    mesh.height = height
    mesh_node.mesh = mesh
    mesh_node.position = pos
    mesh_node.material_override = _material(color)
    parent.add_child(mesh_node)

func _make_sphere(parent: Node3D, node_name: String, pos: Vector3, radius: float, color: Color) -> void:
    var mesh_node := MeshInstance3D.new()
    mesh_node.name = node_name
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    mesh_node.mesh = mesh
    mesh_node.position = pos
    mesh_node.material_override = _material(color)
    parent.add_child(mesh_node)

func _add_box(node_name: String, pos: Vector3, size: Vector3, color: Color, collision: bool) -> Node3D:
    var body: Node3D
    if collision:
        var static_body := StaticBody3D.new()
        body = static_body
        var collision_shape := CollisionShape3D.new()
        var box_shape := BoxShape3D.new()
        box_shape.size = size
        collision_shape.shape = box_shape
        static_body.add_child(collision_shape)
    else:
        body = Node3D.new()
    body.name = node_name
    body.position = pos
    var mesh_instance := MeshInstance3D.new()
    var box_mesh := BoxMesh.new()
    box_mesh.size = size
    mesh_instance.mesh = box_mesh
    mesh_instance.material_override = _material(color)
    body.add_child(mesh_instance)
    add_child(body)
    return body

func _add_interactable(title: String, description: String, pos: Vector3, color: Color, clue_id: String) -> void:
    var body := StaticBody3D.new()
    body.name = clue_id
    body.position = pos
    body.add_to_group("interactable")
    body.set_meta("title", title)
    body.set_meta("description", description)
    body.set_meta("clue_id", clue_id)
    var shape := CollisionShape3D.new()
    var box_shape := BoxShape3D.new()
    box_shape.size = Vector3(0.75, 0.22, 0.55)
    shape.shape = box_shape
    body.add_child(shape)
    var mesh_node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = box_shape.size
    mesh_node.mesh = mesh
    mesh_node.material_override = _material(color)
    body.add_child(mesh_node)
    var label := Label3D.new()
    label.text = title
    label.position = Vector3(0, 0.22, 0)
    label.font_size = 28
    label.modulate = Color(0.95, 0.87, 0.72)
    body.add_child(label)
    add_child(body)

func _material(color: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 1.0
    return mat

func _build_player() -> void:
    var player := CharacterBody3D.new()
    player.name = "Player"
    player.set_script(PLAYER_SCENE_SCRIPT)
    player.position = Vector3(0, 0.1, 3.3)
    add_child(player)

func _build_ui() -> void:
    var layer := CanvasLayer.new()
    layer.name = "UI"
    add_child(layer)

    crosshair = Label.new()
    crosshair.text = "+"
    crosshair.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    crosshair.position = Vector2(-8, -15)
    crosshair.add_theme_font_size_override("font_size", 24)
    crosshair.add_theme_color_override("font_color", Color(0.92, 0.88, 0.82))
    layer.add_child(crosshair)

    prompt_label = Label.new()
    prompt_label.text = "E  INTERACT"
    prompt_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    prompt_label.position = Vector2(-55, -112)
    prompt_label.add_theme_font_size_override("font_size", 16)
    prompt_label.add_theme_color_override("font_color", Color(0.85, 0.79, 0.72))
    prompt_label.visible = false
    layer.add_child(prompt_label)

    dialogue_panel = PanelContainer.new()
    dialogue_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
    dialogue_panel.offset_left = 100
    dialogue_panel.offset_right = -100
    dialogue_panel.offset_top = -150
    dialogue_panel.offset_bottom = -28
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.025, 0.02, 0.03, 0.94)
    style.border_color = Color(0.35, 0.28, 0.30, 1)
    style.set_border_width_all(1)
    style.set_corner_radius_all(4)
    dialogue_panel.add_theme_stylebox_override("panel", style)
    layer.add_child(dialogue_panel)

    var dialogue_box := VBoxContainer.new()
    dialogue_box.add_theme_constant_override("separation", 8)
    dialogue_panel.add_child(dialogue_box)

    var speaker := Label.new()
    speaker.name = "Speaker"
    speaker.text = "MOTHER"
    speaker.add_theme_font_size_override("font_size", 14)
    speaker.add_theme_color_override("font_color", Color(0.72, 0.57, 0.53))
    dialogue_box.add_child(speaker)

    dialogue_label = Label.new()
    dialogue_label.name = "Dialogue"
    dialogue_label.text = "There you are."
    dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    dialogue_label.add_theme_font_size_override("font_size", 18)
    dialogue_label.add_theme_color_override("font_color", Color(0.91, 0.88, 0.84))
    dialogue_box.add_child(dialogue_label)

    status_label = Label.new()
    status_label.position = Vector2(18, 16)
    status_label.text = "CLUES: 0/3"
    status_label.add_theme_font_size_override("font_size", 14)
    status_label.add_theme_color_override("font_color", Color(0.70, 0.66, 0.65))
    layer.add_child(status_label)

    api_status_label = Label.new()
    api_status_label.text = "DIALOGUE: LOCAL PLACEHOLDERS"
    api_status_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    api_status_label.position = Vector2(-260, 16)
    api_status_label.add_theme_font_size_override("font_size", 12)
    api_status_label.add_theme_color_override("font_color", Color(0.55, 0.58, 0.62))
    layer.add_child(api_status_label)

func interact(target: Object) -> void:
    if target is Node and target.is_in_group("interactable"):
        var clue_id: String = str(target.get_meta("clue_id"))
        var title: String = str(target.get_meta("title"))
        var description: String = str(target.get_meta("description"))
        if not discovered_clues.has(clue_id):
            discovered_clues.append(clue_id)
            _record_event("Inspected " + clue_id)
        _show_dialogue(title.to_upper(), description)
        status_label.text = "CLUES: %d/3" % discovered_clues.size()
        return

    if target is Node and target.is_in_group("mother_interactable"):
        _record_event("Spoke to the woman")
        _show_dialogue("MOTHER", _mother_response())
        return

func _mother_response() -> String:
    if discovered_clues.has("letter"):
        suspicion_level += 1
        return "You shouldn't go through other people's things. That letter is old. It doesn't mean what you think."
    if discovered_clues.has("photo"):
        return "That's a lovely picture, isn't it? You were so small. You remember, don't you?"
    if discovered_clues.has("medication"):
        return "It's just your schedule. You know how difficult things get when you miss a dose."
    return "Come away from the door, sweetheart. You're making yourself anxious."

func _record_event(event_text: String) -> void:
    recent_events.append(event_text)
    while recent_events.size() > 5:
        recent_events.pop_front()

func _show_dialogue(speaker: String, line: String) -> void:
    var speaker_node := dialogue_panel.find_child("Speaker", true, false) as Label
    if speaker_node:
        speaker_node.text = speaker.to_upper()
    dialogue_label.text = line

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
