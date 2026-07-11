extends Marker2D
class_name AGun
var blt_scene:PackedScene
var blt_speed:int
var shoot_angle:int
var shooter: Node2D
@onready var shoot_interval: Timer = $Shoot_interval
@onready var snd: AudioStreamPlayer = $Snd
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	blt_speed=300
	shooter=owner
	owner.shoot=shoot
	blt_scene=preload("uid://c1rhdmgq5umil")
func change_blt(_kind:String):
	pass
func shoot():
	if not shoot_interval.is_stopped():
		return
	var bullet := blt_scene.instantiate() as Ablt
	bullet.shooter=owner
	bullet.speed=blt_speed
	bullet.global_position =global_position
	bullet.angle_degrees=owner.shoot_angle
	#bullet.linear_velocity = Vector2(direction * BULLET_VELOCITY, 0.0)

	#bullet.set_as_top_level(true)
	Global.level.add_child(bullet)
	#print(owner,bullet)
	snd.play()
	shoot_interval.start()
