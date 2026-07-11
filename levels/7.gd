extends ALevel

const ANIM_7 := "res://animations/anim_7.tscn"

var _boss7_started: bool = false
var zhua_arr_3_odd: Array
var zhua_arr_3_even: Array

@onready var boss7_node: Node2D = $Boss7

func _ready() -> void:
	super._ready()
	player = $Bill
	_setup_s3()
	call_deferred("_start_s3_anim")

func _process(_delta: float) -> void:
	super._process(_delta)
	if completed or not player:
		return
	if not _boss7_started and boss7_node.is_player_in_range(player):
		_try_start_boss7()

func _try_start_boss7() -> void:
	if _boss7_started:
		return
	_boss7_started = true
	boss7_node.start_door_anim()

func _setup_s3() -> void:
	var s3_children := $S3.get_children()
	zhua_arr_3_odd = [s3_children[0], s3_children[2], s3_children[4]]
	zhua_arr_3_even = [s3_children[1], s3_children[3], s3_children[5]]
	for zhua in zhua_arr_3_odd:
		zhua.loop_anim = true
	for zhua in zhua_arr_3_even:
		zhua.loop_anim = true

func _start_s3_anim() -> void:
	for zhua in zhua_arr_3_odd:
		zhua.play_anim()
	for zhua in zhua_arr_3_even:
		zhua.play_anim()

func _on_door_exit_body_entered(body: Node2D) -> void:
	if body != player or completed:
		return
	completed = true
	# _stop_level_timers()
	# if boss7_node.has_method("stop_all"):
	# 	boss7_node.stop_all()
	Global.goto_scene(ANIM_7)


func _stop_level_timers() -> void:
	_stop_timers_in(self)
	if music.playing:
		music.stop()

func _stop_timers_in(node: Node) -> void:
	if node is Timer:
		(node as Timer).stop()
	for child in node.get_children():
		_stop_timers_in(child)