extends Node

var client = WebSocketClient.new()
var isConnected = false

var playerClass = preload("res://Player.tscn")

func getServer():
	var server = "ws://127.0.0.1:5000"
	if OS.has_feature('JavaScript'):
		var tmp = JavaScript.eval("""
			const urlParams = new URLSearchParams(window.location.search);
			urlParams.get('server');
		""")
		if tmp != "":
			server = tmp
	return server

func _ready():
	var url = getServer() 
	print("socket server", url)
	var error = client.connect_to_url(url, PoolStringArray(), true);
	if error != OK:
		print("connection error")
		_connected_fail()
		return 
		
	get_tree().set_network_peer(client);
	
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _connected_ok():
	print("connect OK")
	isConnected = true
	rpc_id(1, "registerClient")
	
func uuid():
	if isConnected:
		return get_tree().get_network_unique_id()
	return 33
	
func _connected_fail():
	print("connect failed, playing locally")
	Global.ownPlayer = playerClass.instance()
	Global.ownPlayer.set_name("local_player")
	var selfPeerID = uuid()
	Global.ownPlayer.set_network_master(selfPeerID)
	get_tree().get_root().call_deferred("add_child", Global.ownPlayer)
	
func _server_disconnected():
	print("disconnected")
	
remote func connected():
	var selfPeerID = uuid()
	print("player connected ", selfPeerID)
	Global.ownPlayer = playerClass.instance()
	Global.ownPlayer.set_name(str(selfPeerID))
	Global.ownPlayer.set_network_master(selfPeerID)
#	my_player.playerName = $JoinPanel/LineEdit.text
	get_tree().get_root().add_child(Global.ownPlayer)

puppet func spawn_player(id):
	print("spawn", id, uuid())
	if id == uuid():
		return
	var player = playerClass.instance()
	player.set_name(str(id))
	player.set_network_master(id)
	get_tree().get_root().add_child(player)
	
puppet func remove_player(id):
	var toRemove = get_tree().get_root().get_node(str(id))
	if toRemove != null:
		toRemove.queue_free()
	
func _process(delta):
	if (client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED ||
		client.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTING):
		client.poll();
