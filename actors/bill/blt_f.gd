extends Ablt

var center = Vector2.ZERO
var radius = 50
var angle = 0.0
var angular_speed = 1.0 # 每秒旋转弧度
var rotate_speed:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	rotate(20*delta)
