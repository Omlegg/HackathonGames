extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager._hover_item.connect(_strart_appearing)
	SignalManager._stop_hover_item.connect(_stop_appearing)

func _strart_appearing(text):
	$TextureRect.show()
	$Label.show()
	$Label.text = text
	
func _stop_appearing():
	$TextureRect.hide()
	$Label.hide()
