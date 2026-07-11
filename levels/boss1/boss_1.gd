extends StaticBody2D
#const DAMAGE = preload("res://snds/contra/damage.wav")
const SND_DAMAGE = preload("uid://cpw7ejgrtle4y")

var blood:=3
var c1_blood:=3
var c2_blood:=3
@onready var c_1: Area2D = $C1
@onready var c_2: Area2D = $C2

@onready var c1_gun:  = $C1/Gun
@onready var c2_gun:  = $C2/Gun
@onready var timer_exp: Timer = $TimerExp
@onready var snd: AudioStreamPlayer = $Snd

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass
	#if c_1:
		#c1_gun.shoot.call(180)
	#if c_2:
		#c2_gun.shoot.call(180)

func hit_by_blt(_blt:Node2D):
	#take_damage(_blt.power)
	pass
	
func take_damage(dmg := 1):
	blood -= dmg
	if blood <= 0:
		#emit_signal("died", self)
		#queue_free()
		die()
		#set_state()

func die():
	#$Dead.visible=true
	$AnimationPlayer.play("die")
	$TimerExp.start()
	$Heart.queue_free()
	if c_1:
		c1_die()
	if c_2:
		c2_die()
	Global.level.player.set_area(false)
func _on_c_1_area_entered(area: Area2D) -> void:
	#print(area.owner,area.name)
	c1_blood-=1
	snd.stream=SND_DAMAGE
	snd.play()
	if c1_blood<=0:
		c1_blood=0
		c1_die()

func c1_die():
	DieExpFx.spawn_local(self, Global.DIE_EXP_ITEM, c_1.position, c_1.z_index, true)
	c_1.queue_free()

func _on_c_2_area_entered(area: Area2D) -> void:
	c2_blood-=1
	snd.stream=SND_DAMAGE
	snd.play()
	if c2_blood<=0:
		c2_die()

func c2_die():
	c2_blood=0
	DieExpFx.spawn_local(self, Global.DIE_EXP_ITEM, c_2.position, c_2.z_index, true)
	c_2.queue_free()

func _on_heart_area_entered(area: Area2D) -> void:
	take_damage(1)
	snd.stream=SND_DAMAGE
	snd.play()

func _on_timer_exp_timeout() -> void:
	var _pos:=position+Vector2(randi_range(-300,200),randi_range(-300,300))
	var die_effect := DieExpFx.spawn_local(Global.level, Global.DIE_EFFECT, _pos, z_index)
	print(die_effect)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		&"die":
			timer_exp.stop()
			$CollisionShape2D3.queue_free()
