extends Node3D
func _process(delta):
	# 每秒绕Y轴旋转 10 度
	rotation.y += deg_to_rad(5) * delta
