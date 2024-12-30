extends CharacterBody3D

var timer = 0
var max_timer = 1.5
var able_to_pick = false
var id :int
var picked_up = false 
@export var item_id:String= ""
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var ShootTimer =0
var ShootTimerMax = 10
var StartShootTimer = false

func _ready():
	SignalManager.get_item.connect(_picked_up)
	if id == null:
		id =  Idk.item_counter+1
		Idk.item_counter += 1
func _picked_up(i):
	if id == i:
		queue_free()
		
func _process(delta):
	if timer >= max_timer:
		able_to_pick = true
	else:
		timer += 1*delta
	if(StartShootTimer == true):
		if(StartShootTimer >= ShootTimerMax):
			StartShootTimer = false
			ShootTimer = 0
		else:
			ShootTimer += 1
			
	if !is_on_floor():
		velocity.y -= gravity * delta
		move_and_slide()

func Shoot():
	StartShootTimer = true
