extends Control

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.start_computer.connect(_start)
	var tree = get_tree()
	if tree.has_group("player"):
		player = tree.get_nodes_in_group("player")[0]
func _start():
	show()


func _on_back_button_pressed():
	hide()
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	SignalManager.stop_computer.emit()
