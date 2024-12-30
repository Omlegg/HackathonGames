extends Node3D

@export_node_path("Skeleton3D") var skel_p
@onready var skel = get_node(skel_p)
# Called when the node enters the scene tree for the first time.
func _ready():
	if !is_multiplayer_authority():
		position = Vector3(0,0,0)
		for i in get_children():
			i.rotation = Vector3(0,0,0)
			i.position = Vector3(0,0,0)
	else:
		visible  = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_multiplayer_authority():
		
		
		transform = skel.get_bone_global_pose (skel.find_bone("Upper_arm.R"))
		position.x += 0.45
		position.y-= 0.75
		position.z += 0.75
		rotation = Vector3(rotation.x,0,0)
		scale = Vector3(2,2,2)
		
func any_item_picked():
	for i in get_children():
		if i.visible:
			return i
	return false
