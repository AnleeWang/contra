extends Actor3d
func _ready() -> void:
	super._ready()
enum Sta{
	Sd,Wk,WkShoot,Jump,Shoot,Sq,Up,
	Up45,Down45,Sd_2,Shoot_2,Sq_2,WkShoot2,SqShoot2,
	WkFd,BeHitted,
	Win,
}	
func states(delta:float):
	
	var func_name = Sta.find_key(_state)
	if has_method(func_name):
		call(func_name, delta)
	else:
		print("方法不存在")
	anim_str=func_name
