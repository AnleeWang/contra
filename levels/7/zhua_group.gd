extends Node2D

@export var trigger_radius: float = 600.0 ## 玩家与 Marker2D 的触发距离
@export var start_delay: float = 0.0 ## 触发后首次启动延迟
@export var step_gap: float = 0.0 ## 每个爪动画结束后的间隔
@export var zhua_order: PackedInt32Array = [] ## 爪动画顺序(1-based)，空则按X排序
@export var anim_time: float = 1.0 ## 动画时间
@export var hold_at_bottom: float = 0.27 ## 到达底部停留时长
@export var hold_at_return: float = 0.0 ## 返回后停留时长
@export var use_group_anim_settings: bool = false ## 用组参数覆盖各爪动画设置
@export var loop_anim: bool = true ## zhua_c 是否循环动画

var _started: bool = false
var _index: int = 0
var _zhua_arr: Array = []

func _ready() -> void:
	_setup_zhuas()

func _process(_delta: float) -> void:
	if _started:
		return
	var p := _get_player()
	if p and is_player_in_range(p):
		_try_start()

func is_player_in_range(player: Node2D) -> bool:
	var mark := get_node_or_null("Marker2D") as Marker2D
	if mark == null:
		push_warning("%s: 缺少 Marker2D，触发检测回退到 S 节点" % name)
		return player.global_position.distance_to(global_position) <= trigger_radius
	return player.global_position.distance_to(mark.global_position) <= trigger_radius

func _get_player() -> Node2D:
	if Global.level:
		return Global.level.player
	return null

func _setup_zhuas() -> void:
	_zhua_arr.clear()
	if zhua_order.is_empty():
		_collect_zhuas_by_x()
	else:
		for idx in zhua_order:
			var node := get_node_or_null("Zhua%d" % idx)
			if node:
				_zhua_arr.append(node)
			else:
				push_warning("%s: 找不到 Zhua%d" % [name, idx])
		if _zhua_arr.is_empty():
			push_warning("%s: zhua_order 无有效节点，回退到 X 排序" % name)
			_collect_zhuas_by_x()
	for zhua in _zhua_arr:
		if "loop_anim" in zhua:
			zhua.loop_anim = loop_anim
		zhua.anim_finished.connect(_on_zhua_anim_finished)

func _collect_zhuas_by_x() -> void:
	var children := get_children()
	children = children.filter(func(n): return n.has_method("play_anim"))
	children.sort_custom(func(a, b): return a.position.x < b.position.x)
	_zhua_arr.assign(children)

func _try_start() -> void:
	if _zhua_arr.is_empty():
		push_warning("%s: 没有可播放的爪" % name)
		return
	_started = true
	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout
	_play_current()

func _apply_zhua_settings(zhua: Node) -> void:
	if not use_group_anim_settings:
		return
	zhua.anim_time = anim_time
	zhua.hold_at_max = hold_at_bottom
	zhua.hold_at_return = hold_at_return

func _play_current() -> void:
	if _zhua_arr.is_empty():
		return
	var zhua: Node = _zhua_arr[_index]
	_apply_zhua_settings(zhua)
	zhua.play_anim()

func _on_zhua_anim_finished() -> void:
	if step_gap > 0.0:
		await get_tree().create_timer(step_gap).timeout
	_index = (_index + 1) % _zhua_arr.size()
	_play_current()
