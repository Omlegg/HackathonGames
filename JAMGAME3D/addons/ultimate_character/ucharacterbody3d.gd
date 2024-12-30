@tool
extends CharacterBody3D
class_name UCharacterBody3D

## A 3D physics body using a revamped template script.

@export_group("Character Speeds")
@export var jump_velocity : float = 4.5
@export var walk_speed : float = 5.0
@export var sprint_speed : float = 8.0
@export var crouch_speed : float = 3.0
@export var slide_speed : float = 7.0

@export_group("Character Settings")
## Where the camera will be positioned, default of 1.8 is based off of a character height of 2.0
@export var standing_height : float = 1.8
## Where the camera will be positioned, default of 1.3 is based off of a character height of 2.0
@export var crouching_height : float = 1
## The slide length in seconds for how far the player can slide
@export var sliding_length : float = 1.0
@export var head_bob_walking_speed : float = 14.0
@export var head_bob_sprinting_speed : float = 22.0
@export var head_bob_crouching_speed : float = 10.0
## The head bob intensity is for crouching, where walking is multiplied by 2, and sprinting is multiplied by 4
@export var head_bob_intensity : float = 0.05

@export_group("Controls")
## The InputMap action string to be used for LEFT movement
@export var LEFT : String = "move_left"
## The InputMap action string to be used for RIGHT movement
@export var RIGHT : String = "move_right"
## The InputMap action string to be used for FORWARD movement
@export var FORWARD : String = "move_forward"
## The InputMap action string to be used for BACKWARD movement
@export var BACKWARD : String = "move_backward"
## The InputMap action string to be used for sprinting
@export var SPRINT : String = "action_sprint"
## The InputMap action string to be used for crouching
@export var CROUCH : String = "action_crouch"
## The InputMap action string to be used for jumping
@export var JUMP : String = "action_jump"
## A default value of 0.4 is a good starting point, stay between 0.01 and 1.0
@export var MOUSE_SENSITIVITY : float = 0.4

var is_walking = false
var is_sprinting = false
var is_crouching = false
var is_sliding = false

var collision_shape_normal : CollisionShape3D
var collision_shape_crouch : CollisionShape3D
var head_node : Node3D
var camera_node : Camera3D
var raycast_node : RayCast3D

var current_speed = walk_speed
var slide_timer = 0.0
var slide_vector = Vector2.ZERO
var head_bob_current_intensity = 0.0
var head_bob_vector = Vector2.ZERO
var head_bob_index = 0.0
var last_velocity = Vector3.ZERO

var start_sprinting= true
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction = Vector3.ZERO
var scene

func _enter_tree():
	if Engine.is_editor_hint():
		# Obtain the current scene root
		scene = get_tree().edited_scene_root
		if scene == null:
			printerr("Failed to obtain scene tree in editor")
			return
	
	if !Engine.is_editor_hint():
		collision_shape_normal = $CollisionShapeNormal
		collision_shape_crouch = $CollisionShapeCrouch
		head_node = $Head
		camera_node = $Head/Camera
		raycast_node = $RayCast3D

func _ready():
	# Only editor: Create child nodes
	if Engine.is_editor_hint():
		# TODO: Find a better way to implement this. A workaround to not adding duplicate nodes
		# Need to figure out how to lo	
		var nodes = get_children()
		if nodes.size() > 0:
			collision_shape_normal = get_node("CollisionShapeNormal")
			collision_shape_crouch = get_node("CollisionShapeCrouch")
			head_node = get_node("Head")
			camera_node = head_node.get_node("Camera")
			raycast_node = get_node("RayCast3D")
		
		# Create the collision shapes
		if collision_shape_normal == null:
			collision_shape_normal = CollisionShape3D.new()
			collision_shape_normal.name = "CollisionShapeNormal"
			collision_shape_normal.shape = CapsuleShape3D.new()
			collision_shape_normal.position.y = 1.0
			self.add_child(collision_shape_normal)
			collision_shape_normal.owner = scene
		
		if collision_shape_crouch == null:
			collision_shape_crouch = CollisionShape3D.new()
			collision_shape_crouch.name = "CollisionShapeCrouch"
			collision_shape_crouch.shape = CapsuleShape3D.new()
			collision_shape_crouch.shape.height = crouching_height
			collision_shape_crouch.position.y = crouching_height/2
			collision_shape_crouch.disabled = true
			self.add_child(collision_shape_crouch)
			collision_shape_crouch.owner = scene
		
		# Create the head node
		if head_node == null:
			head_node = Node3D.new()
			head_node.name = "Head"
			head_node.position.y = standing_height
			self.add_child(head_node)
			head_node.owner = scene
		
		# Create the camera node
		if camera_node == null:
			camera_node = Camera3D.new()
			camera_node.name = "Camera"
			head_node.add_child(camera_node)
			camera_node.owner = scene
		
		# Create the raycast node
		if raycast_node == null:
			raycast_node = RayCast3D.new()
			raycast_node.name = "RayCast3D"
			raycast_node.target_position = Vector3(0, 2, 0)
			self.add_child(raycast_node)
			raycast_node.owner = scene
	
	camera_node.current = is_multiplayer_authority()
	# Only game: Run normal ready logic
	if !Engine.is_editor_hint():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Armature/Skeleton3D/Cylinder_002.visible = !is_multiplayer_authority()
func _input(event):
	if !Engine.is_editor_hint() and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED and is_multiplayer_authority():
		if event is InputEventMouseMotion:
			rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
			head_node.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
			head_node.rotation.x = clampf(head_node.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta):
	if $Armature/Skeleton3D/Cylinder_002.visible:
		$Armature/Skeleton3D.set_bone_pose_rotation($Armature/Skeleton3D.find_bone("Bone"),Quaternion(-head_node.rotation.x,0,0,1))
	if !is_multiplayer_authority():
		return
	if !Engine.is_editor_hint():
		var input_dir = Input.get_vector("KEY_A", "KEY_D", "KEY_W", "KEY_S")
		if !raycast_node.is_colliding():
			# Handle crouch, sprint, walk speed.
			if( Input.is_action_pressed("KEY_CTRL") or is_sliding) and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
				current_speed = lerpf(current_speed, crouch_speed, delta * 10.0)
				head_node.position.y = lerpf(head_node.position.y, crouching_height, delta * 10.0)
				# Handle sliding
				if is_sprinting and input_dir != Vector2.ZERO:
					is_sliding = true
					slide_timer = sliding_length
					slide_vector = input_dir
				is_walking = false
				is_sprinting = false
				is_crouching = true
			
			head_node.position.y = lerpf(head_node.position.y, standing_height, delta * 10.0)
			collision_shape_normal.disabled = false
			collision_shape_crouch.disabled = true
			
			if Input.is_action_pressed("KEY_SHIFT") and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED and( SignalManager.stamina > 0 and start_sprinting == true) :
				current_speed = lerpf(current_speed, sprint_speed, delta * 10.0)
				
				is_walking = false
				is_sprinting = true
				is_crouching = false
				
			else:
				if SignalManager.stamina <= 30:
					start_sprinting = false
				current_speed = lerpf(current_speed, walk_speed, delta * 10.0)
				
				is_walking = true
				is_sprinting = false
				is_crouching = false
			
			if SignalManager.stamina > 30:
				start_sprinting = true
			
			if is_sliding:
				slide_timer -= delta
				if slide_timer <= 0:
					is_sliding = false
		if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			if Vector2.ZERO != input_dir:
				if is_sprinting:
					head_bob_current_intensity = head_bob_intensity * 4
					head_bob_index += head_bob_sprinting_speed * delta
					if SignalManager.stamina >= 0:
						SignalManager.stamina -= 0.15
				elif is_walking and velocity != Vector3.ZERO:
					head_bob_current_intensity = head_bob_intensity * 2
					head_bob_index += head_bob_walking_speed * delta
					if SignalManager.stamina <= 79:
						SignalManager.stamina += 0.1
				elif is_crouching:
					head_bob_current_intensity = head_bob_intensity
					head_bob_index += head_bob_crouching_speed * delta
					
			else:
				if SignalManager.stamina <= 79.85:
					SignalManager.stamina += 0.15
		if is_on_floor() and !is_sliding and input_dir != Vector2.ZERO and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED :
			head_bob_vector.y = sin(head_bob_index)
			head_bob_vector.x = sin(head_bob_index/2)+0.5
			camera_node.position.y = lerp(camera_node.position.y, head_bob_vector.y * (head_bob_current_intensity/2.0), delta * 10.0)
			camera_node.position.x = lerp(camera_node.position.x, head_bob_vector.x * head_bob_current_intensity, delta * 10.0)
		else:
			camera_node.position.y = lerp(camera_node.position.y, 0.0, delta * 10.0)
			camera_node.position.x = lerp(camera_node.position.x, 0.0, delta * 10.0)
		
		# Add the gravity.
		if !is_on_floor():
			velocity.y -= gravity * delta

		# Handle jump.
		if Input.is_action_just_pressed("KEY_SPACE") and is_on_floor() and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			velocity.y = jump_velocity
			is_sliding = false

		# Handle the movement/deceleration.
		if is_on_floor():
			if last_velocity.y < -8.5:
				# TODO: Handle player hard landing
				pass
			elif last_velocity.y < 0.0:
				# TODO: Handle player soft landing
				pass
			
			direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * 10.0)
		else:
			
			if input_dir != Vector2.ZERO:
				direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * 3.0)
				if SignalManager.stamina >= 0:
					SignalManager.stamina -= 0.1
		if is_sliding:
			direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
			current_speed = (slide_timer + 0.1) * slide_speed
		
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)
		
		last_velocity = velocity
		if  Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
			move_and_slide()
