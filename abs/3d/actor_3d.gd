extends CharacterBody3D
class_name Actor3d
const ABLT_3D = preload("res://abs/3d/ablt_3d.tscn")

const SPEED = 3.0

var _state:int
var key:={j=false,k=false,l=false,u=false,i=false,o=false}
var direction:Vector3
var anim_str:StringName
var anim_finished:bool
var anim_started:bool
var facingL:bool
var facingR:bool
var initScaleX:float
var canShoot:bool
var blt_scene:PackedScene
var shootAngle:int
var act:Callable
@onready var gun: AGun3d = $Sprite3D/Gun

@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var shoot_delay: Timer = $Sprite3D/Gun/ShootDelay
@onready var anim_player: AnimationPlayer = $Sprite3D/AnimationPlayer
func _ready() -> void:
	blt_scene=ABLT_3D
	initScaleX=sprite_3d.scale.x
	act=by_ai
func by_input(delta:float):
	#print(self)
	var input_dir := Input.get_vector("left", "right", "up", "down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	key.j=Input.is_action_just_pressed("j")
	#key.j=Input.is_action_pressed("j")
	key.k=Input.is_action_just_pressed("k")
	key.l=Input.is_action_just_pressed("l")
	key.u=Input.is_action_just_pressed("u")	
	key.i=Input.is_action_just_pressed("i")
	key.o=Input.is_action_just_pressed("o")	
func by_ai(delta:float):
	#print("ai.....")
	pass
func set_state(_newState:int):
	#_last_state=_state
	_state=_newState
	anim_finished=false
	
func states(delta:float):
	match _state:
		0:
			pass
func animate():
	if anim_finished:
		anim_player.stop(true)
	else:
		anim_player.play(anim_str)
func _physics_process(delta: float) -> void:
	act.call(delta)
	states(delta)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#if direction:
		#velocity.x = direction.x * SPEED
		##velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
	
	
	animate()
	move_and_slide()
	if canShoot:gun.shoot()
	
func faceL():
	facingL=true
	facingR=false
	sprite_3d.scale.x=-initScaleX
	if sprite_3d.billboard:
		sprite_3d.flip_h=true
func faceR():
	facingR=true
	facingL=false
	sprite_3d.scale.x=initScaleX
	if sprite_3d.billboard:
		sprite_3d.flip_h=false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	anim_finished=true
	canShoot=false
	#anim_started=false
	#print("finished")

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	
	#match anim_name:
		##&"Shoot_2",&"Jump":
		#
			#canShoot=true
	#anim_finished=false
	#anim_started=true
	#print(anim_player.current_animation)
	pass


func _on_animation_player_current_animation_changed(name: String) -> void:
	#anim_finished=false
	pass
