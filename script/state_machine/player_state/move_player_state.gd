class_name MovePlayerState
extends PlayerState

var boosting := false
var coyote_buffer := 0.0
var coyote := false
var _rng := RandomNumberGenerator.new()


func update(delta: float) -> void:
	.update(delta)
	if _player.speed_boost_unlocked:
		if _player.charge_gauge.value > _player.boost_depletion_rate:
			if Input.is_action_just_pressed("boost"):
				_player.charge_gauge.show()
				_player.charge_gauge.value -= _player.boost_depletion_rate
				boosting = true
				_player.boost_sound.play()
				_player.move_sound.stop()
			elif Input.is_action_pressed("boost") and boosting:
				if _player.charge_gauge.value - _player.boost_depletion_rate > _player.boost_depletion_rate:
					_player.charge_gauge.value -= _player.boost_depletion_rate
				else:
					_player.charge_gauge.value = 0
					boosting = false
					_player.boost_sound.stop()
			elif Input.is_action_just_released("boost"):
				boosting = false
				_player.boost_sound.stop()
			else:
				_replenish_charge_gauge()
		else:
			_replenish_charge_gauge()

	if Input.is_action_just_pressed("jump"):
		_player.apply_jump_impulse()
		_player.wheels.move_and_slide(_player.wheels.velocity, Vector2.UP)
		_player.jump_sound.play()
		state_machine.transition_to("Airborne")
		return
	elif not _player.wheels.is_on_floor():
		if not coyote:
			coyote = true
		else:
			coyote_buffer += delta
	else:
		if coyote:
			coyote = false
	
	if coyote and coyote_buffer > _player.coyote_time:
		state_machine.transition_to("Airborne")
		return


func physics_update(delta:float) -> void:
	if not _player.is_animating:
		.physics_update(delta)
		var snap : Vector2 = _player.wheels.get_floor_normal()
		var movement_vec := Vector2(0, _player.wheels.velocity.y)
		
		if Input.is_action_pressed("move_right"):
			movement_vec.x = 1
		elif Input.is_action_pressed("move_left"):
			movement_vec.x = -1

	#	if _player.wheels.get_floor_normal().dot(_player.wheels.velocity) > 0:
	#		_player.wheels.velocity.y = lerp(_player.wheels.velocity.y, _player.gravity, _player.acceleration)
		var velocity := movement_vec
		velocity.x *= _player.speed
		velocity.x += _player.boost * _player.facing if boosting else 0
		velocity.y += 1
		
		if abs(_player.wheels.velocity.x) > 1:

			var rate_of_change : float = _player.friction
			if _player.wheels.velocity.length() < velocity.length():
				rate_of_change = _player.acceleration
				
			velocity.x = lerp(_player.wheels.velocity.x, velocity.x, rate_of_change) 
		
		if movement_vec.x != 0 and not _player.boost_sound.playing:
			if not _player.move_sound.playing:
				_player.move_sound.play(_rng.randf_range(0, _player.move_sound.stream.get_length()))
		elif not _player.boost_sound.playing:
			if _player.move_sound.playing:
				_player.move_sound.stop()
				_player.stop_sound.play()
		elif boosting == false:
			if _player.boost_sound.playing:
				_player.boost_sound.stop()
				_player.stop_sound.play()
		
		_player.wheels.velocity = _player.wheels.move_and_slide_with_snap(velocity, snap, Vector2.UP, false, 4, deg2rad(60), false)
		_player.wheels.particles.direction = _player.wheels.velocity.rotated(PI)

		if _player.wheels.velocity.x < 0:
			_player.player_body.get_node("Sprite").flip_h = true
		elif _player.wheels.velocity.x > 0:
			_player.player_body.get_node("Sprite").flip_h = false
		
		if _player.wheels.velocity != Vector2.ZERO:
			_player.facing = -1 if _player.wheels.velocity.dot(Vector2.RIGHT) < 0 else 1


func exit() -> void:
	_player.boost_sound.stop()
	coyote = false
	coyote_buffer = 0
	boosting = false
