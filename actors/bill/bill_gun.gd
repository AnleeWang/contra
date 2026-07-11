extends AGun

const BLT_1 = preload("uid://bv22n1ckh0a1e")

const BLT_M = preload("uid://cuawyl1ulnohm")

const BLT_L = preload("uid://cf5bxm001qyo7")
const BLT_S = preload("uid://co5v5qdxtqffp")
const BLT_F = preload("uid://ctjq2egx2qpxo")

const LASER_SOUND = preload("uid://c58ffnerwud8b")

const PLFIRE = preload("uid://dqj263eerh8dc")
const BLT_1_SND = preload("uid://8oap13htxoa8")

func _ready() -> void:
	super._ready()
	#blt_scene=BLT_1
	#snd.stream=BLT_1_SND
func change_blt(_kind:String):
	#print(snd.stream)
	
	match _kind:
		"":
			owner.shoot=shoot
			shoot_interval.wait_time=.15
			blt_speed=500
			blt_scene=BLT_1
			snd.stream=BLT_1_SND
		"M":
			owner.shoot=shoot
			blt_scene=BLT_M
			blt_speed=600
			shoot_interval.wait_time=.07
			snd.stream=BLT_1_SND
		"S":
			shoot_interval.wait_time=.19
			owner.shoot=shoot_s
			blt_scene=BLT_S
			blt_speed=600
			snd.stream=preload("uid://c4rbx6q75vws1")
		#"F":
			#owner.shoot=shoot
			#blt_scene=BLT_F
			#snd.stream=PLFIRE
			#blt_speed=400
			#blt_limit=6
			#shoot_interval.wait_time=0.18
			#
		#"L":
			#owner.shoot=shoot
			#blt_scene=BLT_L
			#snd.stream=LASER_SOUND
			#blt_limit=4
			#blt_speed=440
			#shoot_interval.wait_time=0.18
		
		"R":
			blt_speed+=500
func shoot():
	if not shoot_interval.is_stopped():
		return
	var bullet := blt_scene.instantiate() as Ablt
	bullet.shooter=owner
	bullet.speed=blt_speed
	bullet.global_position =global_position
	bullet.angle_degrees=owner.shoot_angle
	#bullet.linear_velocity = Vector2(direction * BULLET_VELOCITY, 0.0)
	bullet.z_index=shooter.z_index
	#bullet.set_as_top_level(true)
	Global.level.add_child(bullet)
	snd.play()
	shoot_interval.start()

func shoot_s():
	if not shoot_interval.is_stopped():
		return
	var _angle:int=owner.shoot_angle-2*15
	for i in range(5):
		var bullet := blt_scene.instantiate() as Ablt
		bullet.shooter=owner
		bullet.speed=blt_speed
		bullet.global_position =global_position
		bullet.angle_degrees=_angle
		_angle+=15
		#bullet.linear_velocity = Vector2(direction * BULLET_VELOCITY, 0.0)
		bullet.z_index=shooter.z_index
		bullet.set_as_top_level(true)
		add_child(bullet)
	snd.play()
	shoot_interval.start()

#func shoot_s(_angle:int)	:
	#print("s.....")
	#if not shoot_interval.is_stopped():
		#return
	#
	#for i in 5:
		#var bullet :=blt_scene.instantiate()
		#bullet.shooter=owner
		#bullet.global_position = global_position
		#bullet.angle_degrees=-30+i*15+_angle
		##bullet.speed=blt_speed
		#bullet.z_index=z_index
		#Global.level.add_child(bullet)
		##blt_angle=-30+i*15+_angle
		##print(blt_angle)
	##if blt_count>=blt_limit:
		##return
	#
	#
	#snd.play()
	#blt_count+=1
	#shoot_interval.start()
			
