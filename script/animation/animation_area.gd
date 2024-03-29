class_name AnimationArea
extends Area2D

export(String) var animation_name
export(NodePath) var animation_player_path
## causes the collision shape to be reduced to zero on the x-axis. Necessary for camera panning.
export(bool) var make_thin := false
export(bool) var no_replay := false
export(int) var direction := 1
export(bool) var queue := false

var _animation_player : AnimationPlayer
var _direction := Vector2.ZERO
var _played := false

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect('body_exited', self, "_on_body_exited")
	_animation_player = get_node(animation_player_path)
	if make_thin and $CollisionShape2D.shape is RectangleShape2D:
		$CollisionShape2D.shape.extents.x = 0


func _on_body_entered(body : Node) -> void:
	if not _played or not no_replay:
		if body is PlayerBody:
			_try_play_animation(body as PlayerBody)


func _on_body_exited(body : Node) -> void:
	if not _played or not no_replay:
		if body is PlayerBody:
			_try_play_animation(body as PlayerBody)


func _try_play_animation(body : PlayerBody) -> void:
	if animation_name != "":
		if not _direction.dot(body.linear_velocity) > 0:
			if body.linear_velocity.dot(Vector2.RIGHT * direction) > 0:
				if not queue:
					_animation_player.play(animation_name)
				else:
					_animation_player.queue(animation_name)
				_played = true
				_direction = Vector2.RIGHT * direction
			else:
				_animation_player.play(animation_name, -1, -1, true)
				_direction = Vector2.LEFT * direction
