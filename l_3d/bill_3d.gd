extends "res://abs/3d/actor_3d.gd"
#const SPEED = 5.0
const JUMP_VELOCITY = 5.5
func _ready() -> void:
	super._ready()
	sprite_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED # Godot 4=0
	act=by_input
	_state=Sta.Wk
	
enum Sta{
	Sd,Wk,WkShoot,Jump,Shoot,Sq,Up,
	Up45,Down45,Sd_2,Shoot_2,Sq_2,WkShoot2,SqShoot2,
	WkFd,BeHitted,
	Win,
}	
func states(delta:float):
	#match _state:
		#Sta.Sd:
			#Sd(delta)
		#Sta.Wk:
			#Wk(delta)
		#Sta.Jump:
			#Jump(delta)
		#Sta.Shoot:
			#Shoot(delta)
		#Sta.WkShoot:
			#WkShoot(delta)
		#Sta.Sq:
			#Sq(delta)
		#Sta.Up:
			#Up(delta)
		#Sta.Up45:
			#Up45(delta)
		#Sta.Down45:
			#Down45(delta)
		#Sta.BeHitted:
			#BeHitted(delta)	
		#Sta.Win:
			#Win(delta)
	var func_name = Sta.find_key(_state)
	if has_method(func_name):
		call(func_name, delta)
	else:
		print("方法不存在")
	anim_str=func_name
	
func Sd_2(delta:float):
	velocity.x = move_toward(velocity.x, 0, SPEED)
	#velocity.z = move_toward(velocity.z, 0, SPEED)
	if direction.x:
		set_state(Sta.Wk)
	if direction==Vector3.BACK:
		set_state(Sta.Sq_2)
	if direction==Vector3.FORWARD:
		set_state(Sta.WkFd)
	if key.k:
		velocity.y = JUMP_VELOCITY
		set_state(Sta.Jump)
	if key.j:
		set_state(Sta.Shoot_2)

func WkFd(delta):
	if direction.z<0:
		velocity.z=direction.z*SPEED
	else:
		set_state(Sta.Sd_2)
		velocity.z=0
func Wk(delta):
	if direction.x:
		velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	else:
		set_state(Sta.Sd_2)
		
	if direction.x>0:
		faceR()
	elif direction.x<0:
		faceL()
	if key.j:
		set_state(Sta.WkShoot2)
	if key.k:
		velocity.y = JUMP_VELOCITY
		set_state(Sta.Jump)
	#if not direction.x:
		#set_state(Sta.Sd_2)
		
func Jump(delta):
	if key.j:
		canShoot=true
		await get_tree().create_timer(0.3).timeout
		canShoot=false
	if is_on_floor():
		set_state(Sta.Sd_2)
		#print("jump")

func Sq_2(delta):
	if key.j:
		set_state(Sta.SqShoot2)
	if direction!=Vector3.BACK:
		set_state(Sta.Sd_2)

func SqShoot2(delta):
	canShoot=true
	if direction!=Vector3.BACK:
		set_state(Sta.Sd_2)
func Shoot_2(delta):
	if direction.x:
		set_state(Sta.Sd_2)
	if direction==Vector3.BACK:
		set_state(Sta.Sq_2)
	if anim_finished:
		set_state(Sta.Sd_2)

func WkShoot2(delta:float):
	#if key.j:
		#canShoot=true
	canShoot=true
	if direction.x:
		velocity.x = direction.x * SPEED
	else:
		set_state(Sta.Sd_2)
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	anim_finished=true
	canShoot=false
	match anim_name:
		&"WkShoot2":
			set_state(Sta.Wk)
		&"SqShoot2":
			set_state(Sta.Sq_2)
	#anim_started=false
	#print("finished")

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	canShoot=false
	match anim_name:
		#&"Shoot_2",&"Jump":
		&"Shoot_2":
			canShoot=true

func _on_animation_player_current_animation_changed(name: String) -> void:
	#anim_finished=false
	pass
