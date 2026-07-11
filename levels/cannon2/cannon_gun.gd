extends AGun

const BLT_E_1 = preload("uid://c1rhdmgq5umil")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	blt_scene=BLT_E_1
	blt_speed=288
	#shoot_angle=180
	if "shoot_angle" in owner:
		owner.shoot_angle=180
	else:
		print("no shoot_angle")
