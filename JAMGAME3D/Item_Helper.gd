extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager._have_item.connect(set_up_text) # Replace with function body.


func set_up_text(text_given):
	text = text_given
