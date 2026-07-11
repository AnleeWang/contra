extends Area3D
class_name Ablt3D
# 速度（单位/秒）

var speed: float = 1.0 # 子弹的速度
@export var life_time: float = 3.0 # 子弹的生命周期，3秒后自动销毁
# 角度（弧度），例如 45 度 = PI / 4
var angle := 0.0
var rad:=deg_to_rad(angle)
var shooter:=""
var direction: Vector3
var power:float=1.0
func _ready() -> void:
	#direction = -global_transform.basis.z.normalized() # 获取本地Z轴方向，并标准化
	#set_transform(transform.basis.orthonormalized())
	# 设置一个计时器，在life_time秒后销毁子弹
	var timer = get_tree().create_timer(life_time)
	timer.timeout.connect(queue_free)

func _process(delta):
	## 计算方向向量（假设我们在水平面上移动）
	#var direction = Vector3(cos(rad),sin(rad), 0 )
	## 更新位置
	#position += direction * speed * delta
	
	# 根据速度和方向移动子弹
	position += direction * speed * delta

func _on_area_entered(area: Area3D) -> void:
	if area.name.left(10)=="WallCannon":
		print(area.name)
		
	if area.has_method("hit_by_blt"):
		area.hit_by_blt(power)
	queue_free()
	

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
	#print("blt_outOfScreen!")
