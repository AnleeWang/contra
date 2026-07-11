extends AnimatableBody2D
const SND_DAMAGE = preload("uid://cpw7ejgrtle4y")
const NailDeathFx = preload("res://levels/7/nail_death_fx.gd")

var is_showuped := false
@export var blood: int = 10 ## 血量
var player: Actor
var dead := false

@export var explode_interval: float = 0.1 ## 爆炸间隔(上→下)

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
	$NailBlk.visible = false
	$NailDead.visible = true
	$NailDead.reparent.call_deferred(Global.level, true)
	$NailDead2.visible = true
	$NailDead2.reparent.call_deferred(Global.level, true)
	NailDeathFx.play(self, explode_interval)
	queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_enemy:
		print("nail longA:", ",hit player")
