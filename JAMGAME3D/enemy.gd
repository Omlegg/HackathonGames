extends CharacterBody3D

var movement_speed: float = 250
var movement_target_position: Vector3
var player

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	var tree = get_tree()
	if tree.has_group("player"):
		player = tree.get_nodes_in_group("player")[0] 
	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	movement_target_position = player.global_position
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	navigation_agent.set_target_position(player.global_position)
	if navigation_agent.is_navigation_finished():
		return
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * movement_speed * delta
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)

func _on_velocity_computed(safe_velocity: Vector3):
	if Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
		velocity = safe_velocity
		move_and_slide()
