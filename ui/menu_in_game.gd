extends Control
class_name MenuInGame

var level:ALevel
#var score:int
@onready var score_label:Label=$score
# Called when the node enters the scene tree for the first time.
func _ready():
	#Global.menu_in_game=self
	#set_deferred("visible",false)
	level=owner
	#print("menu in game:",level)
	update_life(ALevel.life)
	score_label.text=str(ALevel.score)
	#update_time(level.time)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func _input(event):
	var paused:bool
	if Input.is_action_just_pressed("pause_game"):
		#get_tree().paused = not get_tree().paused
		paused = not get_tree().paused
		get_tree().paused = paused
		if paused:
			#snd_pause.play()   # 播放暂停提示音
			print("paused")
		else:
			#snd_pause.play()  # 播放恢复提示音
			print("resume_sound")
	if Input.is_action_pressed("ui_cancel"):
		paused = not get_tree().paused
		get_tree().paused = paused
		if paused:
			Global.add_menu_option()
			print("option")
		else:
			Global.menu_option.queue_free()
			print("back_to_game")
func update_life(_num:int):
	$life_num.text=str(_num)
	
func update_score(_num:int):
	ALevel.score+=_num
	score_label.text=str(ALevel.score)

func update_time(num:int):
	$TimeNum.text=str(num)
	
