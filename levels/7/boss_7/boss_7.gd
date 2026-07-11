extends Node2D

const E_1 = preload("res://actors/e1/e_1.tscn")
const BLT_RIGID_BOSS7 = preload("res://levels/7/boss_7/blt_rigid_boss7.tscn")
const BltRigidBoss7Script = preload("res://levels/7/boss_7/blt_rigid_boss7.gd")
const EXPOLDE = preload("uid://bmp5coom642ae")

@export var trigger_radius: float = 600.0 ## 节点与玩家的触发距离
@export var open_interval: float = 3.0 ## 每隔多少秒播放一次 open
@export var open_duration: float = 2.0 ## open 后多少秒播放 close
@export var spawn_per_second: float = 3.0 ## open 期间每秒生成数量
@export var spawn_x_gap: float = 20.0 ## 每个敌人 position.x 间隔
@export var cannon1_trigger_radius: float = 300.0 ## Cannon1 相对 player 的触发距离
@export var cannon_anim_pause: float = 1.0 ## open/close 播放完后的停顿时长
@export var cannon_blt_angle: float = -135.0 ## Cannon 子弹角度
@export var cannon_blt_speed: float = 600.0 ## Cannon 子弹速度
@export var blood: int = 3 ## Heart 血量

@onready var door: StaticBody2D = $Door
@onready var door_anim: AnimatedSprite2D = $Door/DoorAnim
@onready var door_collision: CollisionShape2D = $Door/CollisionShape2D
@onready var heart: Area2D = $Boss7Base/Heart
@onready var e1_spawn: Marker2D = $E1Spawn
@onready var cannon1: Boss7Cannon = %Cannon1
@onready var cannon2: Boss7Cannon = %Cannon2
@onready var cannon1_anim: AnimatedSprite2D = %Cannon1/AnimatedSprite2D
@onready var cannon2_anim: AnimatedSprite2D = %Cannon2/AnimatedSprite2D

var _door_started: bool = false
var _cannon_started: bool = false
var _door_defeated: bool = false
var _stopped: bool = false

func stop_all() -> void:
	_stopped = true
	set_process(false)

func is_player_in_range(player: Node2D) -> bool:
	return player.global_position.distance_to(global_position) <= trigger_radius

func hit_heart(blt: Node2D) -> void:
	if _door_defeated:
		return
	blood -= blt.power
	if blood <= 0:
		_door_defeated = true
		_kill_door()

func _kill_door() -> void:
	_spawn_explode(door.global_position)
	door_anim.play(&"dead")
	door.set_deferred("collision_layer", 0)
	door.set_deferred("collision_mask", 0)
	door_collision.set_deferred("disabled", true)
	heart.set_deferred("monitorable", false)
	cannon1.force_die()
	cannon2.force_die()
	_play_explode_snd()

func _spawn_explode(pos: Vector2) -> void:
	DieExpFx.spawn(Global.level, EXPOLDE, pos, z_index)

func _play_explode_snd() -> void:
	Global.level.snd.stream = Global.level.SND_EXPLODE
	Global.level.snd.play()

func _ready() -> void:
	_reset_cannon_anim(cannon1_anim)
	_reset_cannon_anim(cannon2_anim)

func _reset_cannon_anim(cannon_anim: AnimatedSprite2D) -> void:
	var close_name := &"close"
	cannon_anim.animation = close_name
	cannon_anim.frame = cannon_anim.sprite_frames.get_frame_count(close_name) - 1
	cannon_anim.stop()

func _process(_delta: float) -> void:
	var player := Global.level.player if Global.level else null
	if not player or _cannon_started:
		return
	if player.global_position.distance_to(cannon1.global_position) <= cannon1_trigger_radius:
		_cannon_started = true
		_cannon_loop()

func start_door_anim() -> void:
	if _door_started:
		return
	_door_started = true
	_door_loop()

func _door_loop() -> void:
	while is_inside_tree() and not _door_defeated and not _stopped:
		var tree := _get_tree_safe()
		if tree == null:
			return
		await tree.create_timer(open_interval).timeout
		if _door_defeated:
			break
		door_anim.play(&"open")
		await _spawn_e1_while_open()
		if _door_defeated:
			break
		door_anim.play(&"close")

func _cannon_loop() -> void:
	while is_inside_tree() and not _all_cannons_dead() and not _stopped:
		if not cannon1.is_dead():
			await _play_cannon_cycle(cannon1)
		if _all_cannons_dead():
			break
		if not cannon2.is_dead():
			await _play_cannon_cycle(cannon2)

func _all_cannons_dead() -> bool:
	return cannon1.is_dead() and cannon2.is_dead()

func _play_cannon_cycle(cannon: Boss7Cannon) -> void:
	if cannon.is_dead() or _stopped:
		return
	var cannon_anim := cannon.get_node("AnimatedSprite2D") as AnimatedSprite2D
	cannon.set_hittable(true)
	await _play_open_and_fire(cannon_anim, cannon)
	if _stopped or not is_inside_tree():
		return
	cannon.set_hittable(false)
	if cannon.is_dead():
		return
	var tree := _get_tree_safe()
	if tree == null:
		return
	await tree.create_timer(cannon_anim_pause).timeout
	if _stopped or not is_inside_tree():
		return
	cannon_anim.play(&"close")
	await _wait_anim(cannon_anim, &"close")
	tree = _get_tree_safe()
	if tree == null:
		return
	await tree.create_timer(cannon_anim_pause).timeout

func _play_open_and_fire(cannon_anim: AnimatedSprite2D, cannon: Boss7Cannon) -> void:
	var open_name := &"open"
	const FIRE_FRAME := 1
	var fired := {"value": false}

	var on_frame_changed := func() -> void:
		if fired.value or cannon.is_dead():
			return
		if cannon_anim.animation != open_name:
			return
		if cannon_anim.frame >= FIRE_FRAME:
			fired.value = true
			_fire_cannon_blt(cannon_anim)

	cannon_anim.frame_changed.connect(on_frame_changed)
	cannon_anim.play(open_name)
	if not fired.value and not cannon.is_dead() and cannon_anim.frame >= FIRE_FRAME:
		fired.value = true
		_fire_cannon_blt(cannon_anim)
	await _wait_anim(cannon_anim, open_name, cannon)
	if cannon_anim.frame_changed.is_connected(on_frame_changed):
		cannon_anim.frame_changed.disconnect(on_frame_changed)

func _wait_anim(cannon_anim: AnimatedSprite2D, anim_name: StringName, cannon: Boss7Cannon = null) -> void:
	while is_inside_tree() and not _stopped:
		if cannon and cannon.is_dead():
			return
		if cannon_anim.animation != anim_name:
			return
		if not cannon_anim.is_playing():
			return
		var tree := _get_tree_safe()
		if tree == null:
			return
		await tree.process_frame

func _get_tree_safe() -> SceneTree:
	if not is_inside_tree():
		return null
	return get_tree()

func _fire_cannon_blt(cannon_anim: AnimatedSprite2D) -> void:
	if _stopped or not is_inside_tree():
		return
	var blt: ABltRig = BLT_RIGID_BOSS7.instantiate()
	blt.global_position = cannon_anim.global_position
	blt.angle_degrees = int(cannon_blt_angle)
	blt.speed = int(cannon_blt_speed)
	get_parent().add_child(blt)
	var direction := Vector2.from_angle(deg_to_rad(cannon_blt_angle))
	blt.linear_velocity = direction * cannon_blt_speed

func _spawn_e1_while_open() -> void:
	var spawn_interval := 1.0 / spawn_per_second
	var elapsed := 0.0
	var spawn_index := 0
	while elapsed < open_duration and is_inside_tree() and not _door_defeated and not _stopped:
		_spawn_e1(spawn_index)
		spawn_index += 1
		elapsed += spawn_interval
		if elapsed >= open_duration:
			break
		var tree := _get_tree_safe()
		if tree == null:
			return
		await tree.create_timer(spawn_interval).timeout

func _spawn_e1(spawn_index: int) -> void:
	if _stopped or not is_inside_tree():
		return
	var e1: E1 = E_1.instantiate()
	var spawn_pos := e1_spawn.global_position
	var slot := spawn_index % int(spawn_per_second)
	e1.global_position = Vector2(spawn_pos.x + slot * spawn_x_gap, spawn_pos.y)
	e1.z_index = z_index
	get_parent().add_child(e1)
	e1.add_collision_exception_with(door)
	BltRigidBoss7Script.ignore_enemy(e1)
	e1.dir.x = -1
	e1.current_state = Actor.WALK
