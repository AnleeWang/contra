class_name Actor
extends CharacterBody2D

const IDLE = "idle"
const  WALK="walk"
#const RUN = "run"
const SQ="sq"
const JUMP = "jump"
const HURT:="hurt"
const DIE="die"
@export var BLT_1:PackedScene
@export var die_exp:PackedScene
@export var init_jump_pow: int = -300


# 定义状态表
var states:Dictionary = {
	IDLE: _process_idle,
	WALK: _process_walk,
	SQ:_process_sq,
	"jump": _process_jump,
	"hurt": _process_hurt,
	"die": _process_die,
}
var current_state:String=IDLE
var anim_str:String=IDLE
var dir:Vector2
var key_jump:=false
var key_shoot:=false
var is_enemy:=false
var dead:=false
var blood:int
var life:int
var energy:int
var walk_speed:int=300
var jump_pow:int=-300

var shoot_angle:int

var fall_death:=false
var beSighted:=false
var ai_count:int=0
var ai_passed:=0.0

var enemy_sighted:=false

var _face:int
enum Facing{L,R,UP,DOWN}
var shoot:Callable
var act:Callable
var blt_scene:PackedScene
@onready var gravity: int = ProjectSettings.get(&"physics/2d/default_gravity")

@onready var sprite := $Node2D/Sprite2D as Sprite2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var area_2d: Area2D = $Area2D
@onready var snd: AudioStreamPlayer = $Snd

@onready var gun: Marker2D = $Node2D/Gun

@onready var shoot_interval: Timer = $Node2D/Gun/Shoot_interval
@onready var floor_detector_left: RayCast2D = $FloorDetectorLeft
@onready var floor_detector_right: RayCast2D = $FloorDetectorRight
@onready var platform_detector: RayCast2D = $PlatformDetector

func _ready() -> void:
	#current_state="walk"
	jump_pow = init_jump_pow
	act=ai
	shoot=shoot_1
	blt_scene=BLT_1
func _physics_process(delta: float) -> void:
	act.call(delta)
	# Fall.
	velocity.y += gravity * delta
	# 直接根据 key 调用函数
	states[current_state].call(delta)
	move_and_slide()
	if is_on_floor():velocity.y = 0
	handle_collisions()
	
func get_input(delta:=0.0):
	dir=Input.get_vector("left", "right", "up", "down")
	
	key_shoot=Input.is_action_just_pressed("j")
	#key_shoot=Input.is_action_pressed("j")
	key_jump=Input.is_action_just_pressed("k")
	#print(key_jump)
	
func change_state(new_state:String):
	if states.has(new_state):
		current_state = new_state
		anim_str=current_state
		animation_player.play(anim_str)
		#print("当前字典内容: ", states.keys())
		
		#print("切换到状态: ", new_state)
		match current_state:
			JUMP:
				jump(jump_pow)
	else:
		printerr("没有这个状态：", new_state)
		
func _process_idle(delta):
	velocity.x=0
	#print(velocity.y)
	if dir.x:
		change_state("walk")
	if key_jump and is_on_floor():
		change_state(JUMP)
		#jump()
	if key_shoot:
		change_state("shoot")
	#velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)
	
	
func _process_walk(delta):
	if dir.x>0:
		faceR()
	elif dir.x<0:
		faceL()
	velocity.x=dir.x*walk_speed
	if not dir.x:
		change_state("idle")
	if key_jump and is_on_floor():
		change_state("jump")

func _process_sq(delta):
	pass
	
func _process_jump(delta):
	if dir.x>0:
		faceR()
	elif dir.x<0:
		faceL()
	velocity.x=dir.x*walk_speed
	if is_on_floor():
		change_state(IDLE)
func _process_hurt(delta):
	pass

func _process_die(delta):
	pass
	
func jump(_pow) -> void:
	if is_on_floor():
		velocity.y=_pow
	
func handle_collisions():
	if is_on_wall():
		dir.x*=-1	
func animate():
	animation_player.play(anim_str)
func ai(delta):
	ai_count+=1
	ai_passed+=delta
	
func faceL():
	_face=Facing.L
	$Node2D.scale.x=-1
	#collishape.position.x=15
	#scale.x=-1

func faceR():
	_face=Facing.R
	$Node2D.scale.x= 1
	#collishape.position.x=-15

func shoot_1():
	
	if not shoot_interval.is_stopped():
		return
	var bullet := blt_scene.instantiate() as Ablt
	bullet.shooter=self
	bullet.global_position =gun.global_position
	bullet.angle_degrees=shoot_angle
	#bullet.linear_velocity = Vector2(direction * BULLET_VELOCITY, 0.0)

	#bullet.set_as_top_level(true)
	Global.level.add_child(bullet)
	#snd_blt.play()
	shoot_interval.start()

func hit():
	pass
	
func hit_by_blt(_blt:Node2D):
	
	blood -= _blt.power
	if blood <= 0:
		#emit_signal("died", self)
		#queue_free()
		die()

	
func hit_pause(duration: float = 0.1):
	set_process(false)        # 停止 _process()
	set_physics_process(false) # 停止 _physics_process()
	animation_player.pause()
	await get_tree().create_timer(duration).timeout

	set_process(true)         # 恢复 _process()
	set_physics_process(true) # 恢复 _physics_process()
	animation_player.play(anim_str)
	
#func animate():
	#
	#if anim_finished:
		#anim_player.stop(true)
	#else:
		#anim_player.play(anim_str)
func _on_animation_player_animation_started(anim_name):
	#acting[anim_name]=true
	#anim_finished=false
	pass
func _on_animation_player_animation_finished(anim_name):
	pass
	#match anim_name:
		#SQ

	
func die():
	if dead:
		return
	dead=true
	#set_state()
