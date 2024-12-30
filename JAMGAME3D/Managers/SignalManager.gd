extends Node


signal get_item(area)
signal send_item(item_id)

signal change_slot()
signal check_slot(a)

signal remove_item()

signal _hover_item(text)
signal _stop_hover_item(text)

signal _have_item(text)

signal start_computer()
signal stop_computer()

signal remove_object(object : Object)
signal add_object(object : Object)

var current_item
var current_slot = 0 

var items_to_scenes = {
	"lamp":preload("res://lamp_item.tscn")
}

var items_count = 0
var stamina :float = 80
var last_pos_on_planet :Vector3

var monster_descpritions = ["Leg - Moth - is\natracted to light.\nDoesnt fly. Is\nfast"]
