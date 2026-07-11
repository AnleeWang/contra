extends Area2D
class_name ItemEye
@export var amplitude: float = 90      # 波动幅度（上下最大距离）
@export var speed: float = 10.0         # 速度（频率）
@export var speedX: int = -400 

var start_y: float                     # 初始位置 y
var time_passed: float = 0.0           # 计时器
var active: bool = false   # 是否开始运动
@onready var notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
const ITEM = preload("uid://bgxx1lsb5atmn")
const EXPOLDE = preload("uid://bmp5coom642ae")

func _ready():
	start_y = position.y   # 记录初始位置
	#print("eye:",name.substr(7,1))
func _physics_process(delta):
	if not active:
		return
	time_passed += delta * speed
	position.y = start_y + sin(time_passed) * amplitude
	position.x+=speedX*delta

func hit_by_blt(_blt:Node2D):
	DieExpFx.spawn_local(get_parent(), EXPOLDE, position, z_index, true)
	
	var item:=ITEM.instantiate()
	item.name="Item"+name.substr(7,1)
	item.position=position
	get_parent().call_deferred("add_child",item)
	
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.name.substr(0,3)=="Blt":
		pass

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	active=true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	pass # Replace with function body.

func _on_visible_right_screen_exited() -> void:
	queue_free()
