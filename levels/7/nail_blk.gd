extends AnimatableBody2D
const SND_DAMAGE = preload("uid://cpw7ejgrtle4y")
const NailDeathFx = preload("res://levels/7/nail_death_fx.gd")

var is_showuped := false
@export var blood: int = 10 ## 血量
var player: Actor
var dead := false

@export var explode_interval: float = 0.1 ## 爆炸间隔(上→下)
@export var show_up_time: float = 1.0 ## show_up动画时长

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer

var _show_up_base_length: float = 1.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0
	var anim := _animation_player.get_animation("show_up")
	if anim:
		_show_up_base_length = anim.length

func _process(_delta: float) -> void:
	player = Global.level.player
	if player:
		var direction_vector := player.global_position - global_position
		var abs_x := absf(direction_vector.x)
		var abs_y := absf(direction_vector.y)
		if abs_x < 220.0 and abs_y < 350:
			show_up()

func show_up() -> void:
	if is_showuped:
		return
	is_showuped = true
	if show_up_time > 0.0:
		_animation_player.speed_scale = _show_up_base_length / show_up_time
	else:
		_animation_player.speed_scale = 1.0
	_animation_player.play("show_up")

func hit_by_blt(_blt: Node2D) -> void:
	if dead:
		return
	blood -= _blt.power
	Global.level.snd.stream = SND_DAMAGE
	Global.level.snd.play()
	if blood <= 0:
		dead = true
		_die()

func _die() -> void:
	if has_meta("_dying"):
		return
	set_meta("_dying", true)
	dead = true
	collision_layer = 0
	collision_mask = 0
	animated_sprite_2d.visible = false
	$NailDead.visible = true
	$NailDead.reparent.call_deferred(Global.level, true)
	NailDeathFx.play(self, explode_interval)
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_enemy:
		print("nail area2d:", ",hit player")
