extends ABltRig
class_name BltRigidBoss7

const EXPOLDE = preload("uid://bmp5coom642ae")
const DIE_EXP = preload("uid://rfxgyugqak46")
const BLT_RIGID_BOSS7 = preload("res://levels/7/boss_7/blt_rigid_boss7.tscn")
const GROUND_LAYER := 16

@export var fall_spread_speed: float = 80.0 ## 分裂弹下落时的水平扩散速度

var can_split := true
var spread_dir: int = 0

var _prev_vy: float
var _ready_for_apex: bool = false
var _apex_reached: bool = false
var _landed: bool = false

func _ready() -> void:
	add_to_group(&"boss7_blt")
	contact_monitor = true
	max_contacts_reported = 8
	collision_mask = GROUND_LAYER
	call_deferred("_ignore_enemy_collisions")
	if not can_split:
		_setup_falling_blt()

func _setup_falling_blt() -> void:
	var mat := PhysicsMaterial.new()
	mat.bounce = 0.0
	physics_material_override = mat
	gravity_scale = 1.0
	lock_rotation = true

func _ignore_enemy_collisions() -> void:
	var level := Global.level if Global.level else get_parent()
	if not level:
		return
	for node in level.get_children():
		if node is E1 or (node is Actor and node.is_enemy):
			add_collision_exception_with(node)

static func ignore_enemy(enemy: CharacterBody2D) -> void:
	for blt in enemy.get_tree().get_nodes_in_group(&"boss7_blt"):
		if blt is CharacterBody2D or blt is RigidBody2D:
			enemy.add_collision_exception_with(blt)
			blt.add_collision_exception_with(enemy)

func _physics_process(delta: float) -> void:
	if can_split:
		_process_apex()
	elif spread_dir != 0:
		linear_velocity.x += spread_dir * fall_spread_speed * delta
	if not can_split and not _landed:
		for body in get_colliding_bodies():
			if _is_ground(body):
				_land_and_vanish()
				return

func _process_apex() -> void:
	if _apex_reached:
		return
	if not _ready_for_apex:
		_prev_vy = linear_velocity.y
		_ready_for_apex = true
		return
	if _prev_vy < 0.0 and linear_velocity.y >= 0.0:
		_apex_reached = true
		_spawn_explode_at_apex()
		queue_free()
		return
	_prev_vy = linear_velocity.y

func _on_body_entered(body: Node) -> void:
	if can_split or _landed:
		return
	if _is_ground(body):
		_land_and_vanish()

func _is_ground(body: Node) -> bool:
	if body is E1 or (body is Actor and body.is_enemy):
		return false
	if body is TileMapLayer:
		return true
	if body is StaticBody2D:
		return body.name.begins_with("Blk") or (body.collision_layer & GROUND_LAYER) != 0
	return false

func _land_and_vanish() -> void:
	if _landed:
		return
	_landed = true
	call_deferred("_do_land_and_vanish")

func _do_land_and_vanish() -> void:
	if not is_inside_tree():
		return
	_spawn_die_exp()
	queue_free()

func hit_by_player() -> void:
	if can_split:
		call_deferred("queue_free")
		return
	if _landed:
		return
	_landed = true
	call_deferred("_do_land_and_vanish")

func _spawn_die_exp() -> void:
	DieExpFx.spawn_from(self, DIE_EXP, get_parent())

func _spawn_explode_at_apex() -> void:
	var parent := get_parent()
	var spawn_pos := global_position
	var explode := DieExpFx.spawn(parent, EXPOLDE, spawn_pos, z_index)
	_setup_explode_split(explode, spawn_pos, parent)

func _setup_explode_split(explode: Node2D, spawn_pos: Vector2, parent: Node) -> void:
	var anim: AnimatedSprite2D = explode.get_node("AnimatedSprite2D")
	var split_frame := anim.sprite_frames.get_frame_count(&"default") - 2
	var state := {"spawned": false}

	var on_frame_changed := func() -> void:
		if state.spawned:
			return
		if anim.frame >= split_frame:
			state.spawned = true
			_spawn_falling_blts(spawn_pos, parent)

	anim.frame_changed.connect(on_frame_changed)
	if anim.frame >= split_frame:
		state.spawned = true
		_spawn_falling_blts(spawn_pos, parent)

static func _spawn_falling_blts(pos: Vector2, parent: Node) -> void:
	for i in 3:
		var blt: ABltRig = BLT_RIGID_BOSS7.instantiate()
		blt.can_split = false
		blt.spread_dir = i - 1
		blt.global_position = pos
		parent.add_child(blt)
		blt.linear_velocity = Vector2.ZERO
