extends UCharacterBody3D

func _unhandled_key_input(event):
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("ui_cancel"):
			if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED: 
				Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
			else:
				Input.mouse_mode=Input.MOUSE_MODE_CAPTURED

func _ready():
	super()
	var ins = preload("res://computer_screen.tscn").instantiate()
	ins.visible = false
	get_window().call_deferred("add_child",ins)
	SignalManager.send_item.connect(_show_item)
	SignalManager.check_slot.connect(_check_slot)
	
	
func _show_item(item_id):
	if is_multiplayer_authority():
		$Head/Camera/Items.get_node(item_id).show()
		$Armature/Skeleton3D/Items.get_node(item_id).show()
		
		

func _check_slot(item):
	if !item :
		_hide_items()
	else:
		_hide_items()
		$Head/Camera/Items.get_node(item).show()
		$Armature/Skeleton3D/Items.get_node(item).show()
func _hide_items():
	for i in $Head/Camera/Items.get_children():
		i.hide()
	for i in $Armature/Skeleton3D/Items.get_children():
		i.hide()

func _input(event):
	super(event)
	if is_multiplayer_authority():
		if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			if Input.is_action_just_pressed("KEY_Q"):
				if SignalManager.current_item:
					SpawnItem(SignalManager.current_item)
					rpc("a",SignalManager.current_item)
					
					SignalManager.add_object.emit(SignalManager.items_to_scenes[SignalManager.current_item].instantiate())
					SignalManager.current_item = null
					SignalManager.remove_item.emit()
			
			
@rpc("any_peer") func SpawnItem( a):
	_hide_items()
	var item = SignalManager.items_to_scenes[a].instantiate()
	item.position = global_position
	item.position.y += 1
	get_parent().add_child(item)
