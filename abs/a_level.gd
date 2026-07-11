extends Node2D
class_name ALevel

signal playerDied

static var score:=15
static var life:int=5
var time:=99


const SND_EXPLODE = preload("uid://d3toe55gw4i80")

var main
var player:CharacterBody2D
#var boss:Actor
var completed:=false
var camera_fixed:=false
var screenRect:Rect2
@onready var menu_in_game: MenuInGame = $UI/MenuInGame


@onready var tile_map_layer = $TileMapLayer
@onready var camera:Camera2D= $Camera2D
@onready var music: AudioStreamPlayer = $Music
@onready var snd: AudioStreamPlayer = $Snd
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var door_exit: Area2D = $DoorExit

func _enter_tree() -> void:
	Global.level=self

func _ready():
	
	get_tree().paused = false  # 游戏开始时一定恢复未暂停
	#print(self.name,get_visible_world_rect())

func _process(delta):
	#print(self.name,":",get_visible_world_rect().end.y)
	screenRect.position=camera.get_screen_center_position()-get_viewport_rect().size/2
	
	#camera.position.y=player.position.y
	
	if player.position.y<camera.position.y:
		camera.position.y=player.position.y
	#if player.position.x<0+30:
		#player.position.x=0+30
	#
	#if player.position.x<camera.get_screen_center_position().x-get_viewport_rect().size.x/2+40:
		#player.position.x=camera.get_screen_center_position().x-get_viewport_rect().size.x/2+40
	if player.position.x<screenRect.position.x+60:
		player.position.x=screenRect.position.x+60
	if player.position.x>camera.limit_right:
		player.position.x=camera.limit_right
	if not camera_fixed:
		if camera.position.x<player.position.x:# and not boss.beSighted:
			camera.position.x=player.position.x
	
	#if player.position.y>get_visible_world_rect().end.y:
		#player.fall_die()
# 适用于 Godot 4.x
func get_visible_world_rect() -> Rect2:
	# get_canvas_transform() 获取的是当前激活相机的变换矩阵
	# affine_inverse() 将其反转（从屏幕转回世界）
	# get_viewport_rect() 获取屏幕大小
	return get_canvas_transform().affine_inverse() * get_viewport_rect()
	
func calc_rebirth_position(_char:Actor):
	var dis_arr:=[]
	for i in $RebirthPos.get_children():
		if i.position.y<_char.fallDead_pos.y-100:
			#dis_arr.push_back(_char.fallDead_pos.distance_to(i.position))
			dis_arr.push_back(_char.position.distance_to(i.position))
	for i in $RebirthPos.get_children():
		if _char.position.distance_to(i.position)==dis_arr.min():
			_char.position=i.position
	print("position:",_char.position)

func _on_door_exit_body_entered(body: Node2D) -> void:
	#print(body.name)
	if body==player:
		print("level complete...")


func _on_player_died() -> void:
	pass # Replace with function body.
