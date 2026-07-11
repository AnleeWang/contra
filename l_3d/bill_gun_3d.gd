extends AGun3d

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	blt_scene=preload("res://contra/l_3d/bill_blt.tscn")
	shoot_dir=Vector3.FORWARD
	blt_speed=16.2
	snd.stream=preload("res://contra/snds/contra/blt1.wav")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
