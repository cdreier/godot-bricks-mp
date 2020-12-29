extends StaticBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("input_event", self, "on_input_event")
	
func id():
	return "%.6f_%.6f_%.6f" % [transform.origin.x, transform.origin.y, transform.origin.z]

func setMaterial(m):
	$MeshInstance.set_surface_material(0, m)

func on_input_event(camera, event, click_position, click_normal, shape_idx):
	var mouse_click = event as InputEventMouseButton
	if mouse_click and mouse_click.button_index == 1 and mouse_click.pressed:
		BrickHandler.requestDelete(id())
