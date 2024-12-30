extends TextureRect

@export var slot_n :int =0
var current_item
var pos

func _ready():
	SignalManager.send_item.connect(_show_item)
	SignalManager.remove_item.connect(_remove_item_from_slot)
	SignalManager.change_slot.connect(_check_slot)
	if slot_n == SignalManager.current_slot:
		scale = Vector2(1.25,1.25)
	
func _show_item(item_id):
	if !current_item and slot_n == SignalManager.current_slot:
		get_node(item_id).show()
		SignalManager.current_item = item_id
		current_item = item_id
		
func _check_slot():
	if slot_n == SignalManager.current_slot:
		scale = Vector2(1.25,1.25)
		position.y =  -20
		SignalManager.check_slot.emit(current_item)
		SignalManager.current_item = current_item
	else:
		position.y = 0
		scale = Vector2.ONE

func _remove_item_from_slot():
	if slot_n == SignalManager.current_slot:
		get_node(current_item).hide()
		current_item = null
		
