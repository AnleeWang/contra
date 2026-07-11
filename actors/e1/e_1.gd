extends Actor
class_name E1

func _ready():
	super._ready()
	is_enemy=true
	dir.x=1
	blood=1
	call_deferred("_ignore_player_collision")

func _ignore_player_collision() -> void:
	var player := Global.level.player if Global.level else null
	if player:
		add_collision_exception_with(player)

	
func ai(delta):
	if dead:
		#dir=Vector2.ZERO
		return
	ai_count+=1
	#ai_passed+=delta
	#key.k=false
	#if not jumped:
	if current_state==WALK:
		if not floor_detector_left.is_colliding():
			if randi_range(0, 2)==0:
				change_state(JUMP)
				#jump()
				#key_jump=true
			else:
				#velocity.x = abs(walk_speed)
				if is_on_floor():
					dir.x=1
		if not floor_detector_right.is_colliding():
			#dir.x=-1
			#if randi_range(0, 2)==0:
			if randi()%3==0:
				#_state=JUMP
				change_state(JUMP)
				#key_jump=true
				
			else:
				if is_on_floor():
					dir.x=-1
	


func hit_by_blt(_blt:Node2D):
	
	if _blt.position.x<position.x:
		faceL()
	else:
		faceR()
	die()
	#take_damage(_blt.power)
	
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
	
	Global.level.menu_in_game.update_score(100)

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		DIE:
			#print("die?")
			DieExpFx.spawn_from(self, die_exp, Global.level)
			queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
