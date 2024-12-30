extends CanvasLayer



# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.start_computer.connect(_start)
	SignalManager.stop_computer.connect(_stop)
	
func _start():
	hide()
	
func _stop():
	show()
