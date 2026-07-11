extends Node2D

const E_1 := preload("res://actors/e1/e_1.tscn")

@export var off_screen_margin: float = 50.0 ## 距屏幕边缘不足此距离时不生成
@export var spawn_distance_min: float = 600.0 ## 与玩家距离小于等于此值时不生成
@export var spawn_distance_max: float = 1200.0 ## 与玩家距离大于此值时不生成

var level: ALevel

func _ready() -> void:
	level = owner as ALevel
	if level == null:
		level = Global.level

func _on_timer_timeout() -> void:
	if level == null or level.player == null:
		return
	if not _is_outside_screen_by_margin():
		return
	var dist := global_position.distance_to(level.player.global_position)
	if dist <= spawn_distance_min or dist > spawn_distance_max:
		return
	add_e1()

func _is_outside_screen_by_margin() -> bool:
	var rect := level.get_visible_world_rect().grow(off_screen_margin)
	return not rect.has_point(global_position)

func add_e1() -> void:
	var e1: E1 = E_1.instantiate()
	level.add_child(e1)
	e1.global_position = global_position
	if global_position.x > level.player.global_position.x:
		e1.dir.x = -1
	else:
		e1.dir.x = 1
	e1.change_state(Actor.WALK)
