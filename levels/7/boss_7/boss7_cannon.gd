extends Area2D
class_name Boss7Cannon

const EXPOLDE = preload("uid://bmp5coom642ae")

@export var blood: int = 3 ## 该 Cannon 血量

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D

var _dead: bool = false

func _ready() -> void:
	set_deferred("monitorable", false)

func is_dead() -> bool:
	return _dead

func hit_by_blt(_blt: Node2D) -> void:
	if _dead or not monitorable:
		return
	blood -= 1
	if blood <= 0:
		_die()

func _die() -> void:
	if _dead:
		return
	_dead = true
	set_deferred("monitorable", false)
	_spawn_explode(true)
	_anim.play(&"dead")

func force_die() -> void:
	if _dead:
		return
	_dead = true
	set_deferred("monitorable", false)
	_spawn_explode(false)
	_anim.play(&"dead")

func _spawn_explode(play_snd: bool) -> void:
	DieExpFx.spawn_from(self, EXPOLDE, Global.level)
	if play_snd:
		Global.level.snd.stream = Global.level.SND_EXPLODE
		Global.level.snd.play()

func set_hittable(hittable: bool) -> void:
	if _dead:
		return
	set_deferred("monitorable", hittable)
