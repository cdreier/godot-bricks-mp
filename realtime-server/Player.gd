extends KinematicBody


############
const syncInterval = 0.1
var posSyncTween: Tween = Tween.new()
remote var puppetPos = Vector3()
############

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(posSyncTween)


func tweenPos():
	posSyncTween.interpolate_property(self, "transform:origin",
				transform.origin, puppetPos, syncInterval,
				Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	posSyncTween.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# transform.origin = puppetPos
	if transform.origin != puppetPos && !posSyncTween.is_active():
		tweenPos()
