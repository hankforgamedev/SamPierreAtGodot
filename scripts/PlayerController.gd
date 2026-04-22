extends CharacterBody2D

const SPEED        := 300.0
const GRAVITY      := 980.0
const JUMP_VELOCITY:= -520.0

var _nearby_npc: Node   = null
var _in_dialogue := false

@onready var hint_label: Label = $HintLabel

func _physics_process(delta: float) -> void:
	if _in_dialogue:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	var dir := Input.get_axis("move_left", "move_right")
	velocity.x = dir * SPEED

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _nearby_npc != null and not _in_dialogue:
		_nearby_npc.interact()
		get_viewport().set_input_as_handled()

func set_nearby_npc(npc: Node) -> void:
	_nearby_npc = npc
	if hint_label:
		hint_label.visible = npc != null

func set_in_dialogue(value: bool) -> void:
	_in_dialogue = value
