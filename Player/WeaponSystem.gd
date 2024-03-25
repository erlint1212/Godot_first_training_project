extends Node3D

@onready var player : CharacterBody3D = $"../../.."
@onready var Weapon_Animation_Player : AnimationPlayer = $FPS_rig/WeaponAnimationPlayer

var weapon_up : bool = true

var Current_Weapon : Weapon_Resource

var Weapon_Stack : Array[String] = []

var Weapon_Indicator : int = 0

var Next_Weapon : String

var Weapon_List = {}

@export var _weapon_resources : Array[Weapon_Resource]
@export var Start_Weapons : Array[String]

# Called when the node enters the scene tree for the first time.
func _ready():
	Current_Weapon = _weapon_resources[0]

func _input(event):
	if Input.is_action_just_pressed("ToggleWeaponReady"):
		if weapon_up:
			Weapon_Animation_Player.play(Current_Weapon.Deactivate_Anim)
			weapon_up = false
		elif !weapon_up:
			Weapon_Animation_Player.play_backwards(Current_Weapon.Deactivate_Anim)
			weapon_up = true
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.current_state != player.state.DEAD:
		pass
