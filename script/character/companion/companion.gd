class_name Companion
extends Character

export var avoidance_resolution : int 

# dictates the size of interest and danger
export var steer_force := 0.1
export var look_ahead := 24


var _player : Player
# context arrays
var _ray_directions := []
# array of weights
var _interest := []
# array of weights
var _danger := []
# array of raycasts. populated by duplicating the "danger_ray"
var _danger_rays := []

onready var danger_ray : RayCast2D = $Body/DangerRay
onready var target_ray : RayCast2D = $Body/TargetRay

func _ready() -> void:
	DialogueManager.npc_dialogue_box = $DialogueLayer/DialogueBox
	$DialogueLayer/DialogueBox.speaker = self
	_player = get_tree().get_nodes_in_group("player")[0] as Player
	body = $Body
	
	# create our steering mechanism
	_interest.resize(avoidance_resolution)
	_danger.resize(avoidance_resolution)
	_danger_rays.resize(avoidance_resolution)
	_ray_directions.resize(avoidance_resolution)
	# distribute_rays evenly arround the object
	for i in range(avoidance_resolution):
		var angle : float = i * (TAU / float(avoidance_resolution))
		_ray_directions[i] = Vector2.RIGHT.rotated(angle)
		_danger_rays[i] = danger_ray.duplicate()
		_danger_rays[i].enabled = true
		body.add_child(_danger_rays[i])


func _physics_process(delta: float) -> void:
	if _player.body.global_position.distance_to(body.global_position) > 512.0:
		body.linear_velocity = lerp(body.linear_velocity.normalized(), handle_pursuit(_player.body.global_position + Vector2(0, 64), _player.body), 0.05) * _speed * 2.0
	elif _player.body.global_position.distance_to(body.global_position) > 256.0:
		body.linear_velocity = lerp(body.linear_velocity.normalized(), handle_pursuit(_player.body.global_position + Vector2(0, 64), _player.body), 0.05) * _speed
	else:
		if body.linear_velocity.length() > 1:
			body.linear_velocity = lerp(body.linear_velocity, Vector2.ZERO , 0.05)
		else:
			body.linear_velocity = Vector2.ZERO

# does not require raycasts
func _set_interest(destination : Vector2) -> void:
	var direction := (destination - body.global_position).normalized()
	for i in range(avoidance_resolution):
		var d = _ray_directions[i].dot(direction)
		# if dot product is less than zero we zero it out
		_interest[i] = max(0, d)	


# requires raycasts
func _set_danger() -> void:
	for i in avoidance_resolution:
		_danger_rays[i].cast_to =  _ray_directions[i] * look_ahead
		if _danger_rays[i].is_colliding():
			_danger[i] = 1.0
			_danger_rays[i].self_modulate = Color.purple
		else:
			_danger[i] = 0.0
			_danger_rays[i].self_modulate = Color.green


func _choose_direction() -> Vector2:
	# eliminate interest in slots with danger
	for i in avoidance_resolution:
		if _danger[i] > 0.0:
			_interest[i] = -_interest[i]
	# choose direction based on the remaining interest
	var chosen_dir := Vector2.ZERO
	for i in avoidance_resolution:
		chosen_dir += _ray_directions[i] * _interest[i]
	return chosen_dir.normalized()


# navigation is handled by the state calling the pursuit
func handle_pursuit(destination : Vector2, target : PhysicsBody2D = null) -> Vector2:
	if target != null:
		for ray in _danger_rays:
			ray.add_exception(target)
	
	_set_interest(destination)
	_set_danger()
	
	for ray in _danger_rays:
		ray.clear_exceptions()
	
	return _choose_direction()