extends Node

const baseBrick = preload("res://Brick.tscn")

var bricks = {}

func _ready():
	pass

func drop(origin: Vector3, color: Color):
	if Connection.isConnected:
		rpc_id(1, "drop", origin, color)
	else: 
		spawnBrick(origin, color)

remote func spawnBrick(origin: Vector3, color: Color):
	var newBrick = baseBrick.instance()
	newBrick.setMaterial(Global.getMaterialForColor(color))
	newBrick.transform.origin = origin
	bricks[newBrick.id()] = newBrick
	get_tree().get_root().add_child(newBrick)

func requestDelete(id):
	if Connection.isConnected:
		rpc_id(1, "deleteBrick", id)
	elif id in bricks:
		deleteBrick(id)

remotesync func deleteBrick(id):
	if id in bricks:
		bricks[id].queue_free()
		bricks.erase(id)
	
