extends Node2D

@export var zhua_y_min: float = 99.0 ## Area2D Y最小值
@export var anim_time: float = 1.8 ## 动画时长
@export var hold_at_max: float = 0.27 ## 到达底部停留时间
@export var hold_at_return: float = 0.0 ## 返回后停留时间
@export_range(0.0, 18.0, 0.1) var cross_delay: float = 0.0

signal anim_finished

@onready var zhua: Area2D = $Zhua
@onready var middle: Sprite2D = $Middle

var _resolved_y_max: float
var _middle_top_y: float
var _zhua_gap: float
var _middle_width: float
var _middle_min_h: float
var _tween: Tween

const EXTEND_RATIO := 0.59
const RETRACT_RATIO := 0.41

func _ready() -> void:
	_cache_rest_state()
	_set_zhua_y(zhua_y_min)

func _find_group_bottom_mark() -> Marker2D:
	var group := get_parent()
	if group == null:
		return null
	var mark := group.get_node_or_null("MarkBottom") as Marker2D
	if mark:
		return mark
	return group.get_node_or_null("Marker2D") as Marker2D

func _resolve_bottom_y() -> float:
	var marker := _find_group_bottom_mark()
	if marker == null:
		push_warning("%s: 父组缺少 Marker2D" % name)
		return zhua_y_min
	return to_local(marker.global_position).y

func _cache_rest_state() -> void:
	_middle_width = middle.region_rect.size.x
	_middle_min_h = middle.region_rect.size.y
	_middle_top_y = middle.position.y - _middle_min_h * 0.5
	_zhua_gap = zhua_y_min - (_middle_top_y + _middle_min_h)
	_resolved_y_max = _resolve_bottom_y()

func _set_zhua_y(y: float) -> void:
	zhua.position.y = y
	var connect_y := y - _zhua_gap
	var h := maxf(connect_y - _middle_top_y, _middle_min_h)
	middle.region_rect.size = Vector2(_middle_width, h)
	middle.position.y = _middle_top_y + h * 0.5

func get_move_time() -> float:
	return maxf(anim_time - hold_at_max, 0.0)

func get_extend_time() -> float:
	return get_move_time() * EXTEND_RATIO

func get_retract_time() -> float:
	return get_move_time() * RETRACT_RATIO

func get_cycle_time() -> float:
	return anim_time + hold_at_return

func play_anim() -> void:
	if _tween != null and _tween.is_running():
		return
	_cache_rest_state()
	_run_anim()

func _run_anim() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()

	if cross_delay > 0.0:
		await get_tree().create_timer(cross_delay).timeout

	var extend_time := get_extend_time()
	var retract_time := get_retract_time()

	_set_zhua_y(zhua_y_min)
	_tween = create_tween()
	_tween.tween_method(_set_zhua_y, zhua_y_min, _resolved_y_max, extend_time)
	_tween.tween_interval(hold_at_max)
	_tween.tween_method(_set_zhua_y, _resolved_y_max, zhua_y_min, retract_time)
	if hold_at_return > 0.0:
		_tween.tween_interval(hold_at_return)
	_tween.tween_callback(anim_finished.emit)

func _on_zhua_body_entered(body: Node2D) -> void:
	if not body.is_enemy:
		print("hit player")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	pass
