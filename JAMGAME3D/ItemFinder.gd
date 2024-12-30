extends RayCast3D

var stop_hovering = false 

func _input(event):
	if is_multiplayer_authority():
		if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_WHEEL_UP:
				if SignalManager.current_slot == 3:
					SignalManager.current_slot = 0
				else:
					SignalManager.current_slot += 1
				SignalManager.change_slot.emit()
			elif event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if SignalManager.current_slot == 0:
					SignalManager.current_slot = 3
				else:
					SignalManager.current_slot -= 1
				SignalManager.change_slot.emit()
			if(Input.is_key_pressed(KEY_1) or Input.is_key_pressed(KEY_2) or Input.is_key_pressed(KEY_3) or Input.is_key_pressed(KEY_4) ):
				if(Input.is_key_pressed(KEY_1)):
					SignalManager.current_slot = 0
				if(Input.is_key_pressed(KEY_2)):
					SignalManager.current_slot = 1
				if(Input.is_key_pressed(KEY_3)):
					SignalManager.current_slot = 2
				if(Input.is_key_pressed(KEY_4)):
					SignalManager.current_slot = 3
				SignalManager.change_slot.emit()
func _process(delta):
	if is_multiplayer_authority():
		if is_colliding():
			var b = get_collider().get_parent()
			var key = InputMap.action_get_events("KEY_E")[0].as_text()
			if ("(Physical)") in key:
				key =  key.replace("(Physical)", "")
			if b.has_method("_picked_up"):
				var a = b.item_id
				SignalManager._hover_item.emit(key+ " to pick up "+a)
				if Input.is_action_just_pressed("KEY_E") and !SignalManager.current_item and b.able_to_pick:
					get_i(b.id)
					rpc("get_i",b.id)
					SignalManager.send_item.emit(b.item_id)
	if SignalManager.current_item:
		if SignalManager.current_item == "lamp":
			var key = InputMap.action_get_events("KEY_Q")[0].as_text()
			if ("(Physical)") in key:
				key =  key.replace("(Physical)", "")
			SignalManager._have_item.emit(key+ " to drop lamp")
	else:
		SignalManager._have_item.emit("")

@rpc func get_i(a):
	SignalManager.get_item.emit(a)
