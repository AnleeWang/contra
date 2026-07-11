extends Area2D

const SND_DAMAGE = preload("uid://cpw7ejgrtle4y")
const EXPOLDE = preload("uid://bmp5coom642ae")


var is_hide:bool
var can_shoot:bool
var shoot:Callable
var shoot_angle:int
var dead:bool
var blood:=12
@onready var gun: Marker2D = $E3CanonHead/Gun
@onready var anim_player: AnimationPlayer = $Sprite2D/AnimationPlayer

@onready var head: Sprite2D = $E3CanonHead

func _ready():
	gun=$E3CanonHead/Gun
	anim_player.play("Sd")

func _physics_process(delta: float) -> void:
	ai(delta)

func ai(delta):
	if dead:return
	if Global.level.player.position.distance_to(position)<600:
		ShowUp(delta)
	else:
		Hide()	
	for i:ShapeCast2D in $Gun_ShapeCasts.get_children():
		if i.is_colliding():
			#canShoot=true
			#key.j=true
			var _radian=i.position.angle_to_point(i.target_position)
			#if facingR:
				#shoot_angle=rad_to_deg(_radian)
			#else:
				#shoot_angle=rad_to_deg(PI-_radian)	
			
			head.rotation=_radian
			shoot_angle=head.rotation_degrees
	if can_shoot:
		shoot.call()
		#pass
	#print(Sta.find_key(_state))
	
func Sd(delta=0.0):
	pass	

func ShowUp(delta):
	animate("ShowUp",false)
	is_hide=false
	set_deferred("monitorable",true)
	
func Hide():
	if is_hide:return
	head.visible=false
	animate("Hide")
	is_hide=true
	can_shoot=false

func hit_by_blt(_blt:Node2D):
	take_damage(_blt.power)
	Global.level.snd.stream=SND_DAMAGE
	Global.level.snd.play()

func take_damage(dmg := 1):
	blood -= dmg
	if blood <= 0:
		#emit_signal("died", self)
		
		die()
		#set_state()
func die():
	if dead: return
	dead=true
	animate("Die")
	can_shoot=false
	set_deferred("monitorable",false)
	$Gun_ShapeCasts.queue_free()
	var die_effect=DieExpFx.spawn_from(self, EXPOLDE, Global.level)
	Global.level.snd.stream=Global.level.SND_EXPLODE
	Global.level.snd.play()
	#print(snd.stream)
	Global.level.menu_in_game.update_score(2500)	
	
func animate(anim_str:String,is_loop:bool=false):
	if is_loop:
		if anim_str != anim_player.current_animation:
			anim_player.play(anim_str)
			pass
	else:
		if anim_str != anim_player.assigned_animation:
			anim_player.play(anim_str)
			
func _on_animation_player_animation_finished(anim_name):
	#anim_finished=true
	match anim_name:
		"ShowUp":
			#print("showup")
			can_shoot=true
		"Hide":
			#print("Hided")
			anim_player.play("Sd")
		"Die":
			queue_free()
