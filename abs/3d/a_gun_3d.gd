extends Marker3D
class_name  AGun3d
const BLT_3D_E_1 = preload("uid://58y5c13pqvrn")

var blt_scene:PackedScene
var shoot_dir:Vector3
var blt_speed:float=.5
# Called when the node enters the scene tree for the first time.
@onready var snd: AudioStreamPlayer = $Snd
@onready var shoot_delay: Timer = $ShootDelay
func _ready() -> void:
	blt_scene=BLT_3D_E_1
	#print(Global.level3d)
	
func shoot():
	if not shoot_delay.is_stopped():
		return
	#print(self)
	var blt:Ablt3D=blt_scene.instantiate()
	blt.shooter=owner.name
	#blt.rad=deg_to_rad(owner.shootAngle)
	blt.direction=shoot_dir
	blt.speed=blt_speed
	
	owner.get_parent().add_child(blt)
	blt.set_transform(get_global_transform().orthonormalized())
	if snd.stream:
		snd.play()
	shoot_delay.start()
