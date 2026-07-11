extends Sprite2D
const STONE = preload("uid://b4py44tnaj8p7")


@onready var timer: Timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#timer.start()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	var stone:=STONE.instantiate()
	stone.position=position
	stone.z_index=z_index
	owner.add_child(stone)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	timer.start()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	timer.stop()
