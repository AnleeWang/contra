extends Area3D
const A_EXP_ANIM_SPRITE_3D = preload("res://abs/3d/a_exp_anim_sprite_3d.tscn")

var shootAngle:int
var canShoot:bool
var blood:=3.0
#var exp:PackedScene
# Called when the node enters the scene tree for the first time.
@onready var gun: AGun3d = $Sprite3D/Gun

func _ready() -> void:
	pass # Replace with function body.
	#print(self,Global.level3d)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	gun.shoot()

func _physics_process(delta: float) -> void:
	for cast:ShapeCast3D in $Sprite3D/Casts.get_children():
		if cast.is_colliding():
			#var _radian=cast.position.(cast.target_position)
			gun.shoot_dir=cast.target_position
			#print(gun.shoot_dir)
	
func hit_by_blt(_power:float=1.0):
	blood-=_power
	Global.level3d.snd.stream=preload("res://contra/snds/contra/damage.wav")
	Global.level3d.snd.play()
	if blood<=0:
		die()

func die():
	#print(self,"die")
	var exp:AExpAnimSprite3d=A_EXP_ANIM_SPRITE_3D.instantiate()
	exp.position=position
	
	get_parent().call_deferred("add_child",exp)
	queue_free()
