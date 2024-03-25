extends RayCast3D
signal Surface_Changed

@export var player : CharacterBody3D

@export var resources : Array[MovementSFX_Resource]
var resource_dictionary : Dictionary

var previous_surface : RID

func _ready():
	for resource in resources:
		resource_dictionary[resource.Name] = resource
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(previous_surface)
	if is_colliding():
		if previous_surface != get_collider_rid():
			previous_surface = get_collider_rid()
			player.current_movement_sfx_resource = change_sfx()
			print("Footstep SFX change")
	
func change_sfx() -> MovementSFX_Resource:
	if is_colliding():
		var collider = get_collider()
		print(resource_dictionary.keys())
		for key in resource_dictionary.keys():
			print(key)
			if collider.is_in_group(key):
				return resource_dictionary[key]
	
	return resource_dictionary["Stone"]
