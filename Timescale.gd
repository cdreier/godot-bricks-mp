extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var req: HTTPRequest

const host = "http://localhost:8080"

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "X11":
		req = HTTPRequest.new()
		add_child(req)
		req.connect("request_completed", self, "_on_request_completed")
		req.request("%s/timescale" % host)


func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	if json.result != null:
		for tmp in json.result:
			yield(get_tree().create_timer(0.001), "timeout")
			var b = tmp.Brick
			if tmp.Action == "DROP":
				BrickHandler.spawnBrick(Vector3(b.x, b.y, b.z), Color(b.r, b.g, b.b))
			elif tmp.Action == "DELETE": 
				var rmid = id(Vector3(b.x, b.y, b.z))
				BrickHandler.deleteBrick(rmid)


func id(origin):
	return "%.6f_%.6f_%.6f" % [origin.x, origin.y, origin.z]
