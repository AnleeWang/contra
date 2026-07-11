extends Node3D
class_name ALevel3D

const E_1 = preload("uid://ctvt77tq6g3ia")

var levelNum:int=1

func _enter_tree() -> void:
	if not Global.level3d:
		Global.level3d=self

# Called when the node enters the scene tree for the first time.
@onready var snd: AudioStreamPlayer = $Snd
@onready var music: AudioStreamPlayer = $Music
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer_enemy_generator: Timer = $Timer_Enemy_Generator

func _ready() -> void:
	timer_enemy_generator.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_enemy_generator_timeout() -> void:
	var e1:Actor3d=E_1.instantiate()
	e1.position=$E_DoorL.position
	add_child(e1)
