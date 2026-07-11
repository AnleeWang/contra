extends ALevel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	time=99
	#menu_in_game=$UI/MenuInGame
	#menu_in_game.update_time(time)
	
	player=$Chunli
	
	#print(player)
	#if Global.playerPosition:
		#player.position=Global.playerPosition
	#print($rings1.global_position.x,$rings1/Marker2D.global_position.x)

	#$bg.texture.pause=true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	camera.position=player.position
	


func _on_fire_body_entered(body: Node2D) -> void:
	print(body)

func _on_door_exit_body_entered(body: Node2D) -> void:
	#print(body.name)
	if body==player:
		print("level complete...")
		player.current_state="GoHome"
		music.stream=preload("res://island/level_complete.ogg")
		music.play()
		$Timer.stop()


func _on_timer_timeout() -> void:
	menu_in_game.update_time(time)
	if time>0:
		time-=1
		if completed:
			ALevel.score+=50
			menu_in_game.update_score(ALevel.score)
			snd.stream=load("res://circus/snds/score.ogg")
			snd.play()
