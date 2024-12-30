extends Node3D
var timer = 0
var max_timer = 0.25
var key_pressed = false
var key_pressed_q = false


func _process(delta):
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("KEY_E"):
			key_pressed = true
		if Input.is_action_just_pressed("KEY_Q"):
			key_pressed_q = true
		if(timer >= max_timer):
			if key_pressed:
				rotation.x = 0.5
			if key_pressed_q:
				rotation.x = 0.25
			if !(key_pressed and key_pressed_q):
				rotation.x = 0
			key_pressed_q = false
			key_pressed = false
			timer =0
		else:
			timer += 1*delta
