class_name Ablt extends Node2D
#var _kind
#enum Kind {
	#N,M,F,S,L
#}
# 定义移动速度和角度
var speed:int=400
var angle_radians:float
var angle_degrees: = 0 # 移动角度（以度为单位）
var velocity:Vector2
var power:=1
var shooter:Node2D

var tween :Tween
# Called when the node enters the scene tree for the first time.
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
func _ready():
	angle_radians=deg_to_rad(angle_degrees)
	
	#print('blt',shooter)
	
	#await get_tree().process_frame  # 等待一帧，让渲染更新
	#await get_tree().process_frame  # 等待2帧，让渲染更新
	#if  not screen_notifier.is_on_screen():
		#print(self,shooter,"not is on screen")
		#queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# 计算水平和垂直速度分量
	velocity = Vector2(cos(angle_radians), sin(angle_radians)) * speed * delta
	# 将节点移动到新位置
	position += velocity

func spark():
	#var spark=Game.SPARk1_SCENE.instantiate()
	#spark.global_position =self.area2d.global_position
	#level.add_child(spark)
	#shooter.blt_count-=1
	#if shooter.blt_count<0:
		#shooter.blt_count=0
	queue_free()
func sub_count():
	pass
	#if shooter:
		#shooter.blt_count-=1
		#if shooter.blt_count<0:
			#shooter.blt_count=0
	#print("count:",shooter.blt_count)
func _on_area_entered(area):
	pass
	#if shooter==area.owner:return
	#if area.has_method("hit_by_blt"):
		#area.hit_by_blt(self)
		#sub_count()
		#spark()

func _on_body_entered(body: Node2D) -> void:
	pass
	if shooter==body:return
	#if body.has_method("hit_by_blt"):
		#body.hit_by_blt(self)
		##print("Ablt",self)
		#sub_count()
		#spark()
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	sub_count()
	queue_free()	
