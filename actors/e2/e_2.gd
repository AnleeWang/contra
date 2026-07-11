extends Actor

const BLT_E_1 = preload("uid://c1rhdmgq5umil")
#var player:Actor
@onready var gun_shape_casts:Array=$Gun_ShapeCasts.get_children()
@onready var _screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenEnabler2D

var _on_screen := false
var _collision_layer := 0


func _ready():
	super._ready()
	is_enemy=true
	
	states.merge({
		"up_45":_process_up_45,
		"down_45":_process_down_45,
		
	})
	blood=1
	_collision_layer = collision_layer
	call_deferred("_sync_screen_state")

func _sync_screen_state() -> void:
	_set_on_screen(_screen_notifier.is_on_screen())

func _set_on_screen(on_screen: bool) -> void:
	_on_screen = on_screen
	area_2d.monitorable = on_screen
	collision_layer = _collision_layer if on_screen else 0

func shoot_1() -> void:
	if not _on_screen:
		return
	if not shoot_interval.is_stopped():
		return
	var bullet := blt_scene.instantiate() as Ablt
	bullet.shooter = self
	bullet.global_position = gun.global_position
	bullet.angle_degrees = shoot_angle
	bullet.z_index = z_index
	Global.level.add_child(bullet)
	shoot_interval.start()

func ai(delta):
	if dead or not _on_screen:
		return
	var player := Global.player
	if player == null and Global.level:
		player = Global.level.player
	if player == null:
		return
	var _dis_to_player: Vector2 = global_position - player.global_position
	
	if _dis_to_player.x>0:
		faceL()
	else:
		faceR()
	if global_position.distance_to(player.global_position) < 50:
		change_state(IDLE)
	else:
	#set_state(ASta.Up)
		if $Gun_ShapeCasts/Cast_8.is_colliding()or $Gun_ShapeCasts/Cast_10.is_colliding()\
		or $"Gun_ShapeCasts/Cast_9".is_colliding() :
			change_state("up_45")
		if $Gun_ShapeCasts/Cast_4.is_colliding()or $Gun_ShapeCasts/Cast_2.is_colliding()\
		or $"Gun_ShapeCasts/Cast_3".is_colliding() :
			change_state("down_45")
	if $Gun_ShapeCasts/Cast_0.is_colliding() or $Gun_ShapeCasts/Cast_1.is_colliding()\
		 or $Gun_ShapeCasts/Cast_5.is_colliding()or $Gun_ShapeCasts/Cast_11.is_colliding()\
		or $"Gun_ShapeCasts/Cast_6".is_colliding() or $Gun_ShapeCasts/Cast_7.is_colliding():
		change_state(IDLE)
	
	# 默认射击角度；ShapeCast 命中时再覆盖
	if _dis_to_player.x > 0:
		shoot_angle = 180
	else:
		shoot_angle = 0
	for i:ShapeCast2D in gun_shape_casts:
		if i.is_colliding():
			#canShoot=true
			#key.j=true
			var _radian=i.position.angle_to_point(i.target_position)
				
			shoot_angle=rad_to_deg(_radian)
	#if key.j and not dead:
		##gun.shoot.call(shoot_angle)
		#pass
	shoot.call()
func _process_up_45(delta):
	pass

func _process_down_45(delta):
	pass
	
func hit_by_blt(_blt:Node2D):
	if not _on_screen:
		return
	
	if _blt.position.x<position.x:
		faceL()
	else:
		faceR()
	die()
func die():
	if dead:return
	change_state(DIE)
	dead=true
	$ColliShape.call_deferred("set_disabled",true)
	
	velocity.x=0
	velocity.y=-300
	var _dis:int
	if _face==Facing.L:
		_dis=200
	else:
		_dis=-200
	var tween = create_tween()
	tween.tween_property(self, "position:x", position.x + _dis, 1.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	
func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		DIE:
			#print("die?")
			DieExpFx.spawn_from(self, die_exp, Global.level)
			Global.level.menu_in_game.update_score(500)
			queue_free()


func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	_set_on_screen(true)


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	_set_on_screen(false)
