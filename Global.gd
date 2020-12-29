extends Node

var ownPlayer

var colorMaterials = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func getMaterialForColor(c: Color):
	if !colorMaterials.has(c):
		var m = SpatialMaterial.new()
		m.albedo_color = Color(c.r, c.g, c.b)
		colorMaterials[c] = m
	return colorMaterials[c]

