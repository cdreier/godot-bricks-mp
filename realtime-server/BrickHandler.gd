extends Node

const baseBrick = preload("res://Brick.tscn")

var bricks = {}

var request = HTTPRequest.new()

var host = OS.get_environment("BRICK_SERVER")

# Called when the node enters the scene tree for the first time.
func _ready():
	if host == "":
		print("no host found in BRICK_SERVER env, setting to localhost")
		host = "http://localhost:8080"
	add_child(request)
	request.connect("request_completed", self, "_on_request_completed")
	request.request("%s/bricks" % host)
	
func _on_request_completed(result, response_code, headers, body):
	# delete or post return 204 no content
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		if json.result != null:
			for b in json.result:
				drop(Vector3(b.x, b.y, b.z), Color(b.r, b.g, b.b), false)

func persist(brick):
	var data = {
		"x": brick.pos.x,
		"y": brick.pos.y,
		"z": brick.pos.z,
		"r": brick.color.r,
		"g": brick.color.g,
		"b": brick.color.b,
	}
	var body = JSON.print(data)
	print("persist ", brick.id())
	request.request("%s/bricks" % host, [], false, HTTPClient.METHOD_POST, body)
#	spawnBrick(Vector3(data.x, data.y, data.z), Color(data.r, data.g, data.b))

remote func drop(origin: Vector3, color: Color, shouldPersist = true):
	var newBrick = baseBrick.instance()
	newBrick.transform.origin = origin
	newBrick.pos = origin
	newBrick.color = color
	bricks[newBrick.id()] = newBrick
	get_tree().get_root().add_child(newBrick)
	
	if shouldPersist:
		persist(newBrick)
	
	for pid in Connection.players:
		rpc_id(pid, "spawnBrick", origin, color)


remotesync func deleteBrick(id):
	for pid in Connection.players:
		rpc_id(pid, "deleteBrick", id)
	if id in bricks:
		bricks[id].queue_free()
		bricks.erase(id)
		print("delete ", id)
		request.request("%s/bricks/%s" % [host, id], [], false, HTTPClient.METHOD_DELETE)

func populateTo(id):
	for bid in bricks:
		rpc_id(id, "spawnBrick", bricks[bid].pos, bricks[bid].color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
