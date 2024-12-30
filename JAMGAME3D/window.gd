class_name Inventory_Container extends NinePatchRect
var pos = false

var screen_size :Vector2

func _ready():
	$desc.text = SignalManager.monster_descpritions[0 ]

func _process(delta):
	if pos == true and visible:
		set_pos(get_global_mouse_position()  - Vector2(size.x/2,size.y/2))
		
func _gui_input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and !pos:
		
		pos = true
		print(pos)
		print("AAAA")
	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT and pos:
		
		pos = false
		print(pos)
		print("AAAA")

func set_pos(pos):
	screen_size = get_viewport().get_visible_rect().size
	print(screen_size)
	var scaled_size = size * scale
	pos.x = clamp(pos.x,-scaled_size.x + size.x, screen_size.x - size.x)
	pos.y = clamp(pos.y,-scaled_size.y + size.x, screen_size.y - size.y)
	print(pos.x , ",",pos.y)
	position = pos


func _on_x_button_pressed():
	screen_size = get_viewport().get_visible_rect().size
	position = screen_size /2  -  Vector2(size.x/2,size.y/2) * scale
	hide() # Replace with function body.
