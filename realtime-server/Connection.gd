extends Node

var players = {}
var server = WebSocketServer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var port = int(OS.get_environment("PORT"))
	if port == 0:
		port = 5000
		
	print('starting server on port...', port)
	server.listen(port, PoolStringArray(), true)
	get_tree().set_network_peer(server)
	get_tree().connect("network_peer_connected",    self, "_client_connected"   )
	get_tree().connect("network_peer_disconnected", self, "_client_disconnected")


func _client_connected(id):
	print('Client ' + str(id) + ' connected to Server')
	populate_world(id)
	
func _client_disconnected(id):
	print('Client ' + str(id) + ' disconnected ')
	if players.has(id):
		players[id]["node"].queue_free()
		players.erase(id)
		rpc("remove_player", id)

remote func populate_world(id):
	print("populate")
	# Spawn all current players on new client
	for pid in players:
		rpc_id(id, "spawn_player", pid)
	# spawn blocks on new client
	BrickHandler.populateTo(id)
	
remote func registerClient():
	var id = get_tree().get_rpc_sender_id()
	print("register client ", id)
	var newClient = preload("res://Player.tscn").instance()
	newClient.set_name(str(id))     # spawn players with their respective names
	players[id] = {
		"name": "TODO",
		"node": newClient,
	}
	get_tree().get_root().add_child(newClient)
	rpc_id(id, "connected")
	rpc("spawn_player", id)
	
	
func _process(delta):
	if server.is_listening(): # is_listening is true when the server is active and listening
		server.poll()
