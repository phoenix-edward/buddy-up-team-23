class_name AnimationArea
extends Area2D

export(String) var animation_name
export(NodePath) var animation_player_path

var _animation_player : AnimationPlayer
var _direction := Vector2.ZERO

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect('body_exited', self, "_on_body_exited")
	_animation_player = get_node(animation_player_path)
	$CollisionShape2D.shape.extents.x = 0
	
func _on_body_entered(body : Node) -> void:
	if body is Wheels:
		_try_play_animation(body as Wheels)


func _on_body_exited(body : Node) -> void:
	if body is Wheels:
		_try_play_animation(body as Wheels)


func _try_play_animation(body : Wheels) -> void:
	if not _direction.dot(body.velocity) > 0:
		if body.velocity.dot(Vector2.RIGHT) > 0:
			_animation_player.play(animation_name)
			_direction = Vector2.RIGHT
		else:
			_animation_player.play(animation_name, -1, -1, true)
			_direction = Vector2.LEFT
