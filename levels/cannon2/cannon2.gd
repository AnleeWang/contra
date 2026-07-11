extends Node2D
class_name Cannon
var shoot_angle:float
var shoot:Callable
var facingR:bool
var active:bool


const BLT_E_1 = preload("uid://c1rhdmgq5umil")
const SND_DAMAGE = preload("uid://cpw7ejgrtle4y")
const EXPOLDE = preload("uid://bmp5coom642ae")

@export var blood:int=3
@onready var snd: AudioStreamPlayer2D = $Snd
@onready var area_2d_cannon_2: Area2D = $Mask/Area2DCannon2

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var gun_shape_casts:Array=$Gun_ShapeCasts.get_children()
@onready var head: AnimatedSprite2D = $Mask/Area2DCannon2/Head
@onready var gun:  = $Mask/Area2DCannon2/Head/Gun

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print(gun_shape_casts)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if active:
		ai(delta)
		
func ai(delta:float):
	# shoot _angle
	var _radian
	for i:ShapeCast2D in gun_shape_casts:
		if i.is_colliding():
			#canShoot=true
			#key.j=true
			_radian=i.position.angle_to_point(i.target_position)
			#if facingR:
				#shoot_angle=rad_to_deg(_radian)
			#else:
				#shoot_angle=rad_to_deg(PI-_radian)		
			head.rotation=_radian+PI
			shoot_angle=rad_to_deg(_radian)
	shoot.call()
	
func hit_by_blt(_blt:Node2D):
	blood-=1
	#print("cannon:",blood)
	snd.stream=SND_DAMAGE
	snd.play()
	if blood<=0:
		area_2d_cannon_2.set_deferred("monitorable",false)
		die()
		
func die():
	var exp:=DieExpFx.spawn_from(self, EXPOLDE, Global.level)
	anim_player.play("Die")
	Global.level.snd.stream=Global.level.SND_EXPLODE
	Global.level.snd.play()
	Global.level.menu_in_game.update_score(1800)	
	
func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	anim_player.play("ShowUp")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"ShowUp":
			active=true
		"Die":
			queue_free()
