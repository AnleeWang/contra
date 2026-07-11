extends RefCounted

const EXPOLDE := preload("uid://bmp5coom642ae")

static func play(root: Node2D, interval: float) -> void:
	if root.get_meta("_death_fx_played", false):
		return
	root.set_meta("_death_fx_played", true)
	var positions := collect_positions(root)
	var count := mini(positions.size(), 3)
	for i in count:
		_spawn_explode(positions[i], interval * float(i), root.z_index)

static func collect_positions(root: Node2D) -> Array[Vector2]:
	var marks: Array[Marker2D] = []
	for i in range(1, 4):
		var mark := root.get_node_or_null("ExpMark%d" % i) as Marker2D
		if mark:
			marks.append(mark)
	if not marks.is_empty():
		marks.sort_custom(func(a, b): return a.global_position.y < b.global_position.y)
		var positions: Array[Vector2] = []
		for mark in marks:
			positions.append(mark.global_position)
		return positions
	if root.has_node("NailDead2") and root.has_node("NailDead"):
		var top: Vector2 = root.get_node("NailDead2").global_position
		var bottom: Vector2 = root.get_node("NailDead").global_position
		return [top, top.lerp(bottom, 0.5), bottom]
	if root.has_node("NailDead"):
		var bottom: Vector2 = root.get_node("NailDead").global_position
		var top: Vector2 = root.global_position + Vector2(0, -200)
		return [top, top.lerp(bottom, 0.5), bottom]
	return [root.global_position]

static func _spawn_explode(global_pos: Vector2, delay: float, fx_z: int) -> void:
	if delay > 0.0:
		await Engine.get_main_loop().create_timer(delay).timeout
	if not is_instance_valid(Global.level):
		return
	DieExpFx.spawn(Global.level, EXPOLDE, global_pos, fx_z)
