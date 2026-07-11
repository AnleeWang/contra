extends Actor
class_name Bill
#const BLT_1 = preload("uid://bv22n1ckh0a1e")
const SND_DIE = preload("uid://d1dwb4mjyk3nr")
const SND_LAND = preload("uid://djwnltf22q6l6")
const WALK_SHOOT_HOLD := 0.4
const AI_BULLET_DANGER_DIST := 220.0

@export var is_ai: bool = true
@export var ai_blk_jump_radius: float = 380.0 ## 靠近 Blk 才尝试向前跳
@export var ai_jump_cooldown: float = 0.8
@export var ai_shoot_range: float = 450.0

var fallDead:=false
var	fallDead_pos:Vector2
var is_in_water:bool
var _walk_shoot_hold := 0.0
var _ai_jump_cd := 0.0

func _ready():
	super._ready()
	Global.player=self
	act = ai if is_ai else get_input
	faceR()
	states.merge({
		"shoot":_process_shoot,
		"walk_shoot":_process_walk_shoot,
		"up":_process_up,
		"up_shoot":_process_up_shoot,
		&"up_45":_process_up_45,
		&"down_45":_process_down_45,
		"jump_down":_process_jump_down,
		"in_air":_process_in_air,
	})
	
	#print("Sta:",Sta.find_key(Sta.Wk))
	jump_pow=-770
	blood=1000
	
	
	gun.change_blt("")

func _shooting() -> bool:
	return key_shoot if is_ai else Input.is_action_pressed("j")

func _shoot_just_pressed() -> bool:
	return key_shoot if is_ai else Input.is_action_just_pressed("j")

func _try_shoot() -> void:
	if _shooting():
		shoot.call()

func ai(delta: float) -> void:
	if dead:
		return
	ai_count += 1
	ai_passed += delta
	_ai_jump_cd = maxf(0.0, _ai_jump_cd - delta)
	key_jump = false
	key_shoot = false
	dir = Vector2.ZERO
	faceR()
	dir.x = 1.0
	dir.y = 0.0
	_ai_update_shoot_aim()
	dir.x = 1.0
	if _ai_can_jump() and _ai_should_jump():
		key_jump = true
		_ai_jump_cd = ai_jump_cooldown

func _ai_can_jump() -> bool:
	if not is_on_floor() or _ai_jump_cd > 0.0:
		return false
	return current_state == WALK or current_state == IDLE

func _ai_should_jump() -> bool:
	if not floor_detector_right.is_colliding():
		return true
	var blk := _ai_find_nearest_blk()
	if blk == null:
		return false
	var to_blk := blk.global_position - global_position
	if to_blk.x < -40.0:
		return false
	return to_blk.x > 40.0 and to_blk.y > 60.0

func _ai_find_nearest_blk() -> StaticBody2D:
	var level := Global.level
	if level == null:
		return null
	var nearest: StaticBody2D = null
	var nearest_dist := ai_blk_jump_radius
	for child in level.get_children():
		if not is_instance_valid(child):
			continue
		if not child is StaticBody2D:
			continue
		if not str(child.name).begins_with("Blk"):
			continue
		var dist := global_position.distance_to(child.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = child
	return nearest

func _ai_is_shootable(node: Node) -> bool:
	if not is_instance_valid(node):
		return false
	if node is Actor:
		var actor := node as Actor
		return actor.is_enemy and not actor.dead
	if str(node.name).begins_with("NailBlk"):
		return true
	return node.has_method("hit_by_blt")

func _ai_find_best_target() -> Node2D:
	var level := Global.level
	if level == null:
		return null
	var best: Node2D = null
	var best_score := INF
	for child in level.get_children():
		if not is_instance_valid(child):
			continue
		if not _ai_is_shootable(child):
			continue
		var offset: Vector2 = child.global_position - global_position
		if offset.x < -80.0:
			continue
		var dist: float = offset.length()
		if dist > ai_shoot_range:
			continue
		var score: float = dist + maxf(0.0, -offset.y) * 0.5
		if score < best_score:
			best_score = score
			best = child
	return best

func _ai_update_shoot_aim() -> void:
	var target := _ai_find_best_target()
	if target:
		var offset := target.global_position - global_position
		key_shoot = true
		if offset.y < -50.0:
			dir.y = -1.0
		elif offset.y > 50.0:
			dir.y = 1.0
		else:
			dir.y = 0.0
	elif $Cast_Front_guy.is_colliding():
		key_shoot = true
		dir.y = 0.0

func _ai_should_dodge_bullet() -> bool:
	var level := Global.level
	if level == null:
		return false
	for child in level.get_children():
		if not is_instance_valid(child):
			continue
		if child is Ablt:
			var blt := child as Ablt
			if blt.shooter == self:
				continue
			if not is_instance_valid(blt.shooter):
				continue
			if not (blt.shooter is Actor and (blt.shooter as Actor).is_enemy):
				continue
			if _ai_bullet_heading_toward(blt):
				return true
		elif child is ABltRig:
			var rig := child as ABltRig
			if is_instance_valid(rig.shooter) and rig.shooter == self:
				continue
			if global_position.distance_to(rig.global_position) > AI_BULLET_DANGER_DIST:
				continue
			if rig.linear_velocity.length_squared() < 1.0:
				continue
			var to_bill := global_position - rig.global_position
			if rig.linear_velocity.normalized().dot(to_bill.normalized()) > 0.3:
				return true
	return false

func _ai_bullet_heading_toward(blt: Ablt) -> bool:
	if global_position.distance_to(blt.global_position) > AI_BULLET_DANGER_DIST:
		return false
	var blt_vel := Vector2(cos(blt.angle_radians), sin(blt.angle_radians)) * blt.speed
	if blt_vel.length_squared() < 1.0:
		return false
	var to_bill := global_position - blt.global_position
	return blt_vel.normalized().dot(to_bill.normalized()) > 0.3

func _horizontal_speed() -> float:
	if dir.x > 0:
		return walk_speed
	if dir.x < 0:
		return -walk_speed
	return 0.0

func _physics_process(delta: float) -> void:
	if _walk_shoot_hold > 0.0:
		_walk_shoot_hold = maxf(0.0, _walk_shoot_hold - delta)
	super._physics_process(delta)

func change_state(new_state:String):
	if new_state==IDLE:
		match  current_state:
			JUMP,"jump_down","in_air":
				#print("land")
				
				snd.stream=SND_LAND
				snd.play()
	super.change_state(new_state)
	
func _process_idle(delta):
	velocity.x=0
	#print(velocity.y)
	if dir.x:
		change_state("walk")
	if dir.y>0:
		change_state("sq")
		#print(current_state)
	if dir.y==-1:
		change_state("up")
	if key_jump:
		change_state(JUMP)
		#jump()
	if _shooting():
		match _face:
			Facing.L:
				shoot_angle=180
			Facing.R:
				shoot_angle=0
		_try_shoot()
		if _shoot_just_pressed():
			change_state("shoot")
	#velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)

func _process_walk(delta):
	if dir.x>0:
		faceR()
	elif dir.x<0:
		faceL()
	if dir.x:
		if dir.y<0:
			change_state("up_45")
		elif dir.y>0:
			change_state("down_45")
		elif _shoot_just_pressed() or _shooting() or _walk_shoot_hold > 0.0:
			if _shoot_just_pressed() or _shooting():
				_walk_shoot_hold = WALK_SHOOT_HOLD
			change_state("walk_shoot")
	else:
		change_state(IDLE)
	velocity.x=_horizontal_speed()
	if not is_on_floor():
		change_state("in_air")
	if key_jump:
		change_state("jump")
	if _shooting():
		match _face:
			Facing.L:
				shoot_angle=180
			Facing.R:
				shoot_angle=0
		_try_shoot()

func _process_sq(delta):
	velocity.x=0
	if dir.x:
		change_state("down_45")
	if not dir.y:
		change_state(IDLE)
	match _face:
		Facing.L:
			shoot_angle=180
		Facing.R:
			shoot_angle=0
	_try_shoot()
	if key_jump:
		change_state("jump_down")
		
func _process_jump(delta):
	if dir.x>0:
		faceR()
	elif dir.x<0:
		faceL()
	velocity.x=_horizontal_speed()
	if _shooting():
		match _face:
			Facing.L:
				shoot_angle=180
			Facing.R:
				shoot_angle=0
		if dir.x>0:
			if dir.y<0:
				shoot_angle=-30
			elif dir.y>0:
				shoot_angle=30
		elif dir.x<0:
			if dir.y<0:
				shoot_angle=30+180
			elif dir.y>0:
				shoot_angle=180-30
		if not dir.x:
			if dir.y<0:
				shoot_angle=-90
			elif dir.y>0:
				shoot_angle=90
		_try_shoot()
	if is_on_floor():
		change_state(IDLE)
		
func _process_jump_down(delta):
	match _face:
		Facing.L:
			shoot_angle=180
		Facing.R:
			shoot_angle=0
	_try_shoot()
	await get_tree().create_timer(0.05).timeout
	if is_on_floor():
		change_state(IDLE)
func _process_in_air(delta:float):
	if dir.x>0:
		faceR()
	elif dir.x<0:
		faceL()
	velocity.x=_horizontal_speed()
	if _shooting():
		match _face:
			Facing.L:
				shoot_angle=180
			Facing.R:
				shoot_angle=0
		_try_shoot()
	if is_on_floor():
		change_state(IDLE)
func _process_shoot(delta:float):
	if key_jump:
		change_state(JUMP)
	_try_shoot()
	
func _process_walk_shoot(delta:float):
	if dir.x>0:
		faceR()
	elif dir.x<0:
		faceL()
	match _face:
		Facing.L:
			shoot_angle=180
		Facing.R:
			shoot_angle=0
	if _shooting():
		_walk_shoot_hold = WALK_SHOOT_HOLD
	elif _walk_shoot_hold <= 0.0:
		change_state(WALK if dir.x else IDLE)
		return
	if dir.x:
		if dir.y<0:
			change_state("up_45")
		elif dir.y>0:
			change_state("down_45")
	else:
		change_state(IDLE)
		return
	velocity.x=_horizontal_speed()
	_try_shoot()
	if key_jump:
		change_state(JUMP)

func _process_up(delta:float):
	#anim_str="Up"
	velocity.x=0
	shoot_angle=-90
	_try_shoot()
	if dir.x:
		change_state("up_45")
		#if dir.x>0:
			#velocity.x=wk_speed
		#if dir.x<0:
			#velocity.x=-wk_speed
	if not dir:
		change_state(IDLE)
func _process_up_shoot(delta:float):
	pass
func _process_up_45(delta:float):
	if dir.y<0:
		if dir.x>0:
			velocity.x=walk_speed
			faceR()
		elif dir.x<0:
			velocity.x=-walk_speed
			faceL()
		else:
			change_state("up")
	elif dir.x:
		change_state(WALK)
	match _face:
		Facing.L:
			shoot_angle=30-180
		Facing.R:
			shoot_angle=-30
	if not dir:
		change_state(IDLE)
	if key_jump:
		change_state(JUMP)
	_try_shoot()
		
func _process_down_45(delta:float):
	match _face:
		Facing.L:
			shoot_angle=-30+180
		Facing.R:
			shoot_angle=30
	if dir.x>0:
		velocity.x=walk_speed
		faceR()
	elif dir.x<0:
		velocity.x=-walk_speed
		faceL()
	if not dir.y>0:
		if dir.x:
			change_state(WALK)
	if not dir.x:
		if dir.y>0:
			change_state(SQ)
	if not dir:
		change_state(IDLE)
	if key_jump:
		change_state(JUMP)
	_try_shoot()
func InWater(delta):
	pass
	#if dir.x>0:
		#velocity.x=wk_speed
		#faceR()
	#elif dir.x<0:
		#velocity.x=-wk_speed
		#faceL()
	#elif dir.y<0:
		#set_state(Sta.InWaterUp)
	#elif dir.y>0:
		#set_state(Sta.InWaterUnder)	
	#else:
		#velocity.x=0
	#if dir.x and dir.y<0:
		#set_state(Sta.InWaterUp45)
	#if key.k:
		#set_state(Sta.Jump)
	#if key.j:
		#set_state(Sta.InWaterShoot)
	#print("inwater")
	
func InWaterUnder(delta:float):
	
	velocity.x=0
	#if not dir.y>0:
		#set_state(Sta.InWater)
		
func InWaterShoot(delta:float):
	pass
	#if dir.x>0:
		#velocity.x=wk_speed
		#faceR()
	#elif dir.x<0:
		#velocity.x=-wk_speed
		#faceL()
	#elif dir.y<0:
		#set_state(Sta.InWaterUp)
	##else:
		##set_state(Sta.InWater)
	#
	#if key.k:
		#set_state(Sta.Jump)
	#await get_tree().process_frame  # 等待一帧，让渲染更新
	#await get_tree().process_frame  # 等待2帧，让渲染更新
	#if anim_finished:
		#if not key.j or not dir.x:
			#set_state(Sta.InWater)

func InWaterUp45(delta):
	pass
	#if not dir.y:
	#if dir.y<0:
		#if dir.x>0:
			#velocity.x=wk_speed
			#faceR()
		#elif dir.x<0:
				#velocity.x=-wk_speed
				#faceL()
		#else:
			#set_state(Sta.InWaterUp)
	#else:
		#set_state(Sta.InWater)
		#
	##if not dir:
		##set_state(Sta.InWater)
	#if key.k:
		#set_state(Sta.Jump)






func die():
	if dead:return
	dead=true
	#beHittable=false
	#area2d.set_deferred("monitoring",false)
	#velocity.x=0
	#velocity.y=-jump_velocity
	#var _dis:int
	#if facingL:
		#_dis=200
	#else:
		#_dis=-200
	#var tween = create_tween()
	#tween.tween_property(self, "position:x", position.x + _dis, 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	snd.stream=SND_DIE
	#snd.play()
	
func fall_die():
	
	if fallDead:
		return
	print("fall_die")
	#set_state(Sta.Die)
	#die()
	fallDead=true
	fallDead_pos=position

func rebirth():
	#print("rebirth,",dead)
	dead=false
	
	Global.life-=1
	Global.menu_in_game.update_life(Global.life)
	if Global.life<=0:
		Global.add_menu_over()
		owner.queue_free()
		Global.menu_in_game.queue_free()
		return
		
	#if fallDead:
		#fallDead=false
		#level.calc_rebirth_position(self)
		#set_state(Sta.Jump)
		#jump_velocity=0
		##position=Vector2(position.x,0)
	#else:
		#set_state(Sta.Sd)
	#gun.change_kind("")
	#var tween:Tween
	#tween = get_tree().create_tween()
	#tween.tween_property(sprite,"modulate:a",0.5,3.1)
	#tween.connect("finished",on_tween_finished)
	
func on_tween_finished():
	#beHittable=true
	#area2d.set_deferred("monitoring",true)
	sprite.modulate.a=1

#func set_area(_enable:bool):
	#area_2d.set_deferred("monitoring",_enable)
	#area_2d.set_deferred("monitorable",_enable)

func _on_animation_player_current_animation_changed(name: String) -> void:
	#print("current:",name)
	pass
func _on_animation_player_animation_changed(old_name: StringName, new_name: StringName) -> void:
	print(old_name,new_name)
	if new_name==IDLE:
		match old_name:
			JUMP,"jump_down":
				print("land")
func _on_animation_player_animation_started(anim_name):
	match anim_name:
		"InWaterUnder":
			area_2d.monitoring=false
			area_2d.monitorable=false
		&"InWater":
			area_2d.monitoring=true
			area_2d.monitorable=true
	#anim_finished=false
	
func _on_animation_player_animation_finished(anim_name):
	super._on_animation_player_animation_finished(anim_name)
	match anim_name:
		"shoot":
			change_state(IDLE)
		DIE:
			#anim_player.stop(true)
			await get_tree().create_timer(1.5).timeout
			print("animfinished:",anim_str)
			rebirth()
		
func _on_area_2d_area_entered(area):
	#if area.owner is E1:
		#if beHittable:
			#set_state(Sta.Die)
	pass
		
func _on_area_2d_area_exited(area: Area2D) -> void:
	pass # Replace with function body.

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Item:
		var item:Item=body
		
		gun.change_blt(item.kind)
		item.queue_free()
		Global.level.snd.stream=preload("uid://bedimrurcbiqi")
		Global.level.snd.play()
	#if body is StoneL3:
		#if beHittable:
			#set_state(Sta.Die)
	#print(self,body.name)
	match body.name:
		"Sea":
			is_in_water=true
			#jump_velocity=400
			#set_state(Sta.InWater)
		"Floor":
			#if is_on_floor_only():
			#if velocity.y>=0:
				#snd.stream=SND_LAND
				#snd.play()
			pass
			
	if body is ABltRig:
		if body.has_method("hit_by_player"):
			body.hit_by_player()
		else:
			body.queue_free()
		
	#elif is_jumped_down or is_on_floor_only() and _state==Sta.Sd:
	#elif is_on_floor_only() and _state==Sta.JumpDown and body.name!="Sea":
		#level.snd.stream=SND_LAND
		#level.snd.play()
		#pass
func _on_area_2d_body_exited(body: Node2D) -> void:
	match body.name:
		"Sea":
			is_in_water=false
			#jump_velocity=708
