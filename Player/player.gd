extends CharacterBody3D

@export var Health : int = 10

const SPEED = 5.0
const RUN_MULTIPLIER = 1.6
const JUMP_VELOCITY = 4.5
const SENSETIVITY = 0.03
const STEP_AUDIO_LENGTH = 150.0
const STEP_PITCH_DIFF = 0.05
const BOB_FREQ = 2.5
const BOB_AMP = 0.015
var t_bob : float = 0

@onready var head : Node3D = $Head
@onready var camera : Camera3D = $Head/Camera3D
@onready var FPS_rig : Node3D = $Head/Camera3D/WeaponSystem/FPS_rig
@onready var FloorMaterialRay : RayCast3D = $FloorMaterialRay
@onready var StepAudioPlayer : AudioStreamPlayer3D = $MovementStepAudio

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

var current_movement_sfx_resource : MovementSFX_Resource

enum state {NORMAL, DEAD}
var current_state : int = state.NORMAL
var current_moved : float = 0
var current_step : int = 0
var rng = RandomNumberGenerator.new()
var in_air : bool = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	current_movement_sfx_resource = FloorMaterialRay.change_sfx()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSETIVITY)
		camera.rotate_x(-event.relative.y * SENSETIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(90))
		
func _physics_process(delta):
	orthonormalize()
	head.orthonormalize()
	camera.orthonormalize()
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	match current_state:
		state.NORMAL:
			var rng = RandomNumberGenerator.new()
			# Handle jump.
			if Input.is_action_just_pressed("Jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				jump_sfx()
			
			if !is_on_floor() and in_air == false:
				in_air = true
			elif is_on_floor() and in_air == true:
				in_air = false
				land_sfx()

			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack")
			var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if is_on_floor():
				if direction and Input.is_action_pressed("MoveRun"):
					velocity.x = direction.x * SPEED * RUN_MULTIPLIER
					velocity.z = direction.z * SPEED * RUN_MULTIPLIER
					if is_on_floor():
						step_sfx_checker(current_movement_sfx_resource.Running_Sound)
				elif direction:
					velocity.x = direction.x * SPEED
					velocity.z = direction.z * SPEED
					if is_on_floor():
						step_sfx_checker(current_movement_sfx_resource.Walking_Sound)
				else:
					velocity.x = move_toward(velocity.x, 0, SPEED)
					velocity.z = move_toward(velocity.z, 0, SPEED)
			else:
				velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 4.0)
				velocity.y = lerp(velocity.y, direction.y * SPEED, delta * 4.0)
	bob(delta)
	move_and_slide()

func step_sfx_checker(Sound_Array : Array) -> void:
	if current_step > len(Sound_Array)-1:
		current_step = 0
	current_moved += velocity.length()
	if current_moved > STEP_AUDIO_LENGTH:
		StepAudioPlayer.stream = Sound_Array[current_step] #rng.randf_range(0, len(Sound_Array)-1)
		current_step += 1
		StepAudioPlayer.pitch_scale = rng.randf_range(1.0 - STEP_PITCH_DIFF,1.0 + STEP_PITCH_DIFF)
		StepAudioPlayer.play()
		current_moved = 0

func bob(delta):
	t_bob += delta * velocity.length() * float(is_on_floor())
	var pos = Vector3.ZERO
	pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP
	pos.x = cos(t_bob * BOB_FREQ/2) * BOB_AMP
	FPS_rig.transform.origin = pos

func jump_sfx():
	StepAudioPlayer.stream = current_movement_sfx_resource.Jump_Sound[rng.randf_range(0, len(current_movement_sfx_resource.Jump_Sound)-1)]
	StepAudioPlayer.play()

func land_sfx():
	StepAudioPlayer.stream = current_movement_sfx_resource.Landing_Sound[rng.randf_range(0, len(current_movement_sfx_resource.Landing_Sound)-1)]
	StepAudioPlayer.play()
