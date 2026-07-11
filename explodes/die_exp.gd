extends Node2D
class_name DieExpFx

func _ready() -> void:
	var sprite: AnimatedSprite2D = $AnimatedSprite2D
	sprite.sprite_frames.set_animation_loop("default", false)
	sprite.frame = 0
	sprite.play("default")

static func spawn(parent: Node, scene: PackedScene, global_pos: Vector2, fx_z: int, deferred: bool = false) -> Node2D:
	var fx: Node2D = scene.instantiate()
	fx.global_position = global_pos
	fx.z_index = fx_z
	if deferred:
		parent.call_deferred("add_child", fx)
	else:
		parent.add_child(fx)
	return fx

static func spawn_local(parent: Node, scene: PackedScene, pos: Vector2, fx_z: int, deferred: bool = false) -> Node2D:
	var fx: Node2D = scene.instantiate()
	fx.position = pos
	fx.z_index = fx_z
	if deferred:
		parent.call_deferred("add_child", fx)
	else:
		parent.add_child(fx)
	return fx

static func spawn_from(source: CanvasItem, scene: PackedScene, parent: Node = null, deferred: bool = false) -> Node2D:
	var target := parent if parent else Global.level
	return spawn(target, scene, source.global_position, source.z_index, deferred)

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()

func _on_audio_stream_player_finished() -> void:
	queue_free()
