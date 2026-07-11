extends Node2D

@export var zhua_y_min: float = 99.0 ## Area2D Y最小值
@export var move_length: float = 350.0 ## 移动长度
@export var move_time: float = 1.8 ## 移动时间(伸出+收回)
@export var hold_at_extreme: float = 0.5 ## Y最小/最大处停留时间
@export var start_at_max: bool = false ## 双数爪：场景初始已在Y最大处
@export var loop_anim: bool = false
@export_range(0.0, 18.0, 0.1) var cross_delay: float = 0.0

signal anim_finished

@onready var zhua: Area2D = $Zhua
@onready var middle: Sprite2D = $Middle

var _min_y: float
var _max_y: float
var _middle_top_y: float
var _zhua_gap: float
var _middle_width: float
var _middle_min_h: float
var _tween: Tween

func _ready() -> void:
	_cache_rest_state()
	if start_at_max:
		_set_zhua_y(_max_y)
	else:
		_set_zhua_y(_min_y)

func _cache_rest_state() -> void:
	_middle_width = middle.region_rect.size.x
	_min_y = zhua_y_min
	_max_y = _min_y + move_length

	if middle.region_rect.size.y > move_length:
		_middle_min_h = middle.region_rect.size.y - move_length
	else:
		_middle_min_h = middle.region_rect.size.y

	_middle_top_y = middle.position.y - middle.region_rect.size.y * 0.5
	_zhua_gap = _min_y - (_middle_top_y + _middle_min_h)

func _set_zhua_y(y: float) -> void:
	zhua.position.y = y
	var connect_y := y - _zhua_gap
	var h := maxf(connect_y - _middle_top_y, _middle_min_h)
	middle.region_rect.size = Vector2(_middle_width, h)
	middle.position.y = _middle_top_y + h * 0.5

func get_leg_time() -> float:
	return move_time * 0.5

func get_cycle_time() -> float:
	return hold_at_extreme * 2.0 + move_time

func play_anim() -> void:
	if _tween != null and _tween.is_running():
		return
	_run_anim()

func _run_anim() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()

	if cross_delay > 0.0:
		await get_tree().create_timer(cross_delay).timeout

	var leg_time := get_leg_time()

	_tween = create_tween()
	if loop_anim:
		_tween.set_loops()

	if start_at_max:
		_tween.tween_interval(hold_at_extreme)
		_tween.tween_method(_set_zhua_y, _max_y, _min_y, leg_time)
		_tween.tween_interval(hold_at_extreme)
		_tween.tween_method(_set_zhua_y, _min_y, _max_y, leg_time)
	else:
		_tween.tween_interval(hold_at_extreme)
		_tween.tween_method(_set_zhua_y, _min_y, _max_y, leg_time)
		_tween.tween_interval(hold_at_extreme)
		_tween.tween_method(_set_zhua_y, _max_y, _min_y, leg_time)

	if not loop_anim:
		_tween.tween_callback(anim_finished.emit)

func _on_zhua_body_entered(body: Node2D) -> void:
	if not body.is_enemy:
		print("hit player")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	pass
