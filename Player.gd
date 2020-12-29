extends KinematicBody

export (int) var gravity = -30
export (int) var run_speed = 2
export (int) var max_speed = 10

var velocity = Vector3()
var selectedColor = Color(1, 1, 1)
var gridMode = false

var cameraLastAnim = 0
var cameraAnimList = ["default", "wide", "top"]

############
const syncInterval = 0.1
var posSyncTween
puppet var puppetPos = Vector3()
############

# Called when the node enters the scene tree for the first time.
func _ready():
	print("player ready")
	var posSyncTimer = Timer.new()
	posSyncTimer.connect("timeout", self, "onPositionSyncRequest")
	posSyncTimer.autostart = true
	posSyncTimer.wait_time = syncInterval
	add_child(posSyncTimer)
		
	if isSelf():
		$Camera/AnimationPlayer.play("default")
		$Camera.current = true
	else:
		# puppet
		posSyncTween = Tween.new()
		add_child(posSyncTween)
	
func onPositionSyncRequest():
	if !isSelf():
		posSyncTween.interpolate_property(self, "transform:origin",
				transform.origin, puppetPos, syncInterval,
				Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		posSyncTween.start()
	elif Connection.isConnected:
		rset_unreliable("puppetPos", transform.origin)

func nextCamera():
	cameraLastAnim += 1
	if cameraLastAnim >= cameraAnimList.size():
		cameraLastAnim = 0
	$Camera/AnimationPlayer.play(cameraAnimList[cameraLastAnim])
	
func _physics_process(delta):
	if isSelf():
		getInput()
		velocity.y += gravity * delta
		velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	else:
		# transform.origin = puppetPos
		posSyncTween.interpolate_property(self, "transform.origin",
				transform.origin, puppetPos, syncInterval,
				Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)

func isSelf():
	if !Connection.isConnected:
		return true
	return is_network_master()

func setBrick():
	BrickHandler.drop(transform.origin, selectedColor)
	transform.origin.y += 2.1

func getInput():
	var sprinting = Input.is_key_pressed(KEY_SHIFT)
	
	if Input.is_action_just_pressed("ui_nextcam"):
		nextCamera()
	
	if Input.is_action_just_pressed("ui_drop") && is_on_floor():
		setBrick()
		
	if gridMode:
		processGridMovement()
	else: 
		processFreeMovement(sprinting)
	
	processJump()
	
	# no stuttering
	if velocity.x < 0:
		velocity.x = min(0, velocity.x +1)
	elif velocity.x > 0:
		velocity.x = max(0, velocity.x - 1)
		
	if velocity.z < 0:
		velocity.z = min(0, velocity.z +1)
	elif velocity.z > 0:
		velocity.z = max(0, velocity.z - 1)
	
func processGridMovement():
	if Input.is_action_just_pressed("ui_right"):
		transform.origin.x += 1
	if Input.is_action_just_pressed("ui_left"):
		transform.origin.x -= 1
	if Input.is_action_just_pressed("ui_up"):
		transform.origin.z -= 1
	if Input.is_action_just_pressed("ui_down"):
		transform.origin.z += 1
	
func processJump():
	var jump = Input.is_action_pressed("ui_accept")
	if jump && is_on_floor():
		velocity.y = 20
	
func processFreeMovement(sprinting):
	var multiplier = 1
	if sprinting:
		multiplier = 2
	if Input.is_action_pressed("ui_right"):
		velocity.x = min(max_speed * multiplier, velocity.x + run_speed)
	if Input.is_action_pressed("ui_left"):
		velocity.x = max(-max_speed * multiplier, velocity.x - run_speed)
	if Input.is_action_pressed("ui_up"):
		velocity.z = max(-max_speed * multiplier, velocity.z - run_speed)
	if Input.is_action_pressed("ui_down"):
		velocity.z = min(max_speed * multiplier, velocity.z + run_speed)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Camera.look_at(get_translation(), Vector3(0, 1, 0))

puppetsync func applyColor(color):
	$MeshInstance.set_surface_material(0, Global.getMaterialForColor(color))
	selectedColor = color

func changeColor(color):
	if Connection.isConnected:
		rpc("applyColor", color)
	else:
		applyColor(color)

func toggleGrid(button_pressed):
	gridMode = button_pressed
