extends Spatial


var pos: Vector3
var color: Color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func id():
	return "%.6f_%.6f_%.6f" % [transform.origin.x, transform.origin.y, transform.origin.z]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
