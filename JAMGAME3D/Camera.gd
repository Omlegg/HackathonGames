extends Camera3D

var timer = 0
var max_timer = 1
var start_counting = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var a = false
	for i in get_children():
		if "Ray" in i.name:
			if i.is_colliding():
				a = true
				break
	if !a:
		SignalManager._stop_hover_item.emit()
	if start_counting:
		timer += delta
		if timer >= max_timer:
			start_counting = false
