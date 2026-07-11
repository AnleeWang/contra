extends ALevel3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)


func _on_heart_wall_clear() -> void:
	print(self,"wall clear")
	#$Wall.visible=false
	animation_player.play("wall_exp")
	$ele/Electric.visible=false
	$ele/Electric2.visible=false
	snd.stream=load("res://snds/contra/ExpSound1.wav")
	snd.play()
	


func _on_wall_body_entered(body: Node3D) -> void:
	#print(body,body.name)
	match  body.name:
		"Bill3d":
			levelNum+=1
			queue_free()
			Global.goto_level_3d(levelNum)
			#print("next wall")
		
