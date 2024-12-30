extends RayCast3D

var base

func _process(delta):
	if is_colliding():
		var key = InputMap.action_get_events("KEY_E")[0].as_text()
		if ("(Physical)") in key:
			key =  key.replace("(Physical)", "")
		if ("(Unicode)") in key:
			key =  key.replace("(Unicode)", "")
		SignalManager._hover_item.emit(key+ " to interact with computer")
	

func _input(event):
	if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED and !get_parent().start_counting:
		if Input.is_action_just_pressed("KEY_E"):
			if is_colliding():
				Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
				SignalManager.start_computer.emit()

func _ready():
	var tree = get_tree()
	if tree.has_group("base"):
		base = tree.get_nodes_in_group("base")[0]
