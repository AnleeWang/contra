extends Control
const L_1 = "uid://d2fu8dimsdebn"
const _7 = "uid://d280w57y44vic"

var levels:Array=[
	_7,
	L_1,
	"res://circus/l_5.tscn",
	]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ALevel.life=30
	ALevel.score=0
	#print(ALevel.life)
	#print(ALevel.score)
	await get_tree().create_timer(.1).timeout
	#start_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_SPACE):
		start_game()

func _on_button_pressed() -> void:
	start_game()

func start_game():
	#get_parent().remove_child(self)
	Global.goto_scene(levels[1-1])
	#Global.goto_level_3d(1)
