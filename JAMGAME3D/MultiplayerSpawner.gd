extends MultiplayerSpawner

@export var player_scene : PackedScene

func _ready():
	spawn_function = spawnPlayer
	if is_multiplayer_authority():
		spawn.call_deferred(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(removePlayer)
	
var players = {}

func spawnPlayer(data):
	var p = player_scene.instantiate()
	p.position.y = 14.56
	p.set_multiplayer_authority(data)
	players[data] = p
	return p
	
func removePlayer(data):
	players[data].queue_free()
	players.erase(data)
