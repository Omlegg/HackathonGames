extends RayCast3D

func _input(event):
	if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_just_pressed("KEY_E"):
			if is_colliding():
				get_parent().get_parent().get_parent().global_position = SignalManager.last_pos_on_planet

func _process(delta):
	if is_colliding():
		var key = InputMap.action_get_events("KEY_E")[0].as_text()
		if ("(Physical)") in key:
			key =  key.replace("(Physical)", "")
		if ("(Unicode)") in key:
			key =  key.replace("(Unicode)", "")
		SignalManager._hover_item.emit(key+ " to get out of the ship")
