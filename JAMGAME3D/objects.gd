extends Node3D

@export var object_array : Array

func _process(delta):
	if get_children() != object_array:
		if object_array.size() < get_child_count()-1:
			for i in object_array:
				if i not in get_children():
					add_child(i)
		else:
			for i in get_children():
				if i not in object_array:
					remove_child(i)

func _ready():
	for i in get_children():
		object_array.append(i)
