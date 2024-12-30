extends NavigationRegion3D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.y = get_parent().get_node("Player").position.y
	bake_navigation_mesh()
