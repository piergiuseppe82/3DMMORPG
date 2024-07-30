extends CharacterBody3D


const SPEED = 5.0
const LERP_VAL = .15
const X_DELTA_TO_TARGET = 0.05
const Z_DELTA_TO_TARGET = 0.05


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var ball_scene = preload("res://test_utility/Ball.tscn")

var marker

var fire = false

var fired_marker

var obstacle = false

func _ready():
	$Inventory.hide()

func _enter_tree():
	set_multiplayer_authority(name.to_int())	
	$Character/AnimationPlayer.play("idle")	
	
func idle(_delta):
	velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity.z = move_toward(velocity.z, 0, SPEED)
	$Character/Armature/Skeleton3D/FirstHandAttach/pickaxe.visible = false
	$Character/Armature/Skeleton3D/FirstHandAttach/pickaxe.process_mode = Node.PROCESS_MODE_DISABLED
	$Character/AnimationPlayer.play("idle")		
	rpc("_set_positon_and_animation_state", "idle",velocity)

func mining(_delta):
	velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity.z = move_toward(velocity.z, 0, SPEED)
	$Character/AnimationPlayer.play("mining")	
	$Character/Armature/Skeleton3D/FirstHandAttach/pickaxe.visible = true
	$Character/Armature/Skeleton3D/FirstHandAttach/pickaxe.process_mode = Node.PROCESS_MODE_ALWAYS
	rpc("_set_positon_and_animation_state", "mining",velocity)

func move(_delta,direction):
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
	$Character/Armature.rotation.y = lerp_angle($Character/Armature.rotation.y, atan2(-velocity.x,-velocity.z),LERP_VAL)
	$Character/Armature/Skeleton3D/FirstHandAttach/pickaxe.visible = false
	$Character/Armature/Skeleton3D/FirstHandAttach/pickaxe.process_mode = Node.PROCESS_MODE_DISABLED
	$Character/AnimationPlayer.play("run")	
	rpc("_set_positon_and_animation_state", "run",velocity)

func _physics_process(delta):
	if is_multiplayer_authority():
		$SpringArm3D/Camera3D.make_current()
		if not is_on_floor():
			velocity.y -= gravity * delta
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			move(delta,direction)
		elif obstacle:		
			obstacle = false	
			idle(delta)
		elif marker:
			move_to_marker(delta)
		elif fire and is_instance_valid(fired_marker["collider"]):
			mining(delta)
		else:
			idle(delta)
	move_and_slide()

@rpc("any_peer")
func _set_positon_and_animation_state(state,_velocity):
	if	_velocity:
		velocity.x = _velocity.x * SPEED
		velocity.z = _velocity.z * SPEED
		$Character/Armature.rotation.y = lerp_angle($Character/Armature.rotation.y, atan2(-velocity.x,-velocity.z),LERP_VAL)		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	$Character/AnimationPlayer.play(state)	
	if("mining" == state):
		$Character/Armature/Skeleton3D/FirstHandAttach/pickaxe.visible = true
	else:
		$Character/Armature/Skeleton3D/FirstHandAttach/pickaxe.visible = false
func _input(event):
	if is_multiplayer_authority() && event.is_action("right_click") and event.pressed:
		#shoot_ball()	
		if !$Inventory.visible && get_right_click_position().has("position") && !get_right_click_position()["collider"].get_groups().has("Obstacle"):
			marker = get_right_click_position()["position"]	
			fire = false
	if is_multiplayer_authority() && event.is_action("left_click") and event.pressed:
		#shoot_ball()	
		if !$Inventory.visible && get_right_click_position().has("position") && get_right_click_position()["collider"].get_groups().has("Obstacle"):
			fired_marker = get_right_click_position()
			marker = fired_marker["position"]		
			fire = true			
	
#ONLY FOR TEST POSITION OF MOUSE
func shoot_ball(): 
	var raycast_result = get_right_click_position()
	if !raycast_result.is_empty():
		var ball = ball_scene.instantiate()
		ball.position = raycast_result["position"]
		$'..'.add_child(ball)

func get_right_click_position():
	var mouse_position = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = $SpringArm3D/Camera3D.project_ray_origin(mouse_position)
	var to = from + $SpringArm3D/Camera3D.project_ray_normal(mouse_position)*ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	return space.intersect_ray(ray_query)


func move_to_marker (_delta):
	var distance = global_position-marker
	if abs(distance.x) < X_DELTA_TO_TARGET && abs(distance.z) < Z_DELTA_TO_TARGET:
		marker = null
		idle(_delta)
		return
	var direction = global_position.direction_to(marker)
	move(_delta,direction)


func _on_body_detector_body_entered(body):
	if is_multiplayer_authority():
		if body.get_groups().has("Portals"):
			NetworkConnection.change_region(self,body.region_to_respawn)
		if body.get_groups().has("Obstacle"):
			obstacle = true
			marker = null
