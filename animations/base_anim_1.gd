extends Node2D
# var main=Game.main
@onready var anim:=$AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	# print(name)
	$Control/RichTextLabel.visible_characters=0
	anim.play('1')
	$antenna1.visible=false 
	$antenna2.visible=false
	$antenna3.visible=false
	#var tween: Tween = create_tween()
	#tween.tween_property($Control/RichTextLabel, "visible_ratio", 1.0, 2.0).from(0.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animation_player_animation_finished(anim_name):
	if anim_name=='1':
		#queue_free()
		#Game.main.gotoLevel(2)
		anim.play("2")	
	if anim_name=='2':	
		$Timer.start()


func _on_timer_timeout():
	$Control/RichTextLabel.visible_characters+=1
	$Snd_type.play()
	if $Control/RichTextLabel.visible_characters>=$Control/RichTextLabel.text.length():
		$Timer.stop()
		print("over")
		match name:
			"Anim_7":
				Global.goto_scene("res://levels/1.tscn")
		#main.gotoLevel(1)
		#queue_free()
