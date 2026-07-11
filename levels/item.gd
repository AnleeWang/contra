extends CharacterBody2D
class_name Item
@export var kind:String="R"
var gravity:=800
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	
	velocity.y=-650
	#blt_kind=name.substr(4,1)
	#print("blt_kind:",blt_kind)
	#if not blt_kind=="r":
	animated_sprite_2d.play(kind)

func _physics_process(delta: float) -> void:
	velocity.y = minf(1200, velocity.y + gravity * delta)
	#if velocity.x > 0.0:
			#faceR()
		#elif velocity.x < 0.0:
			#faceL()
	if not is_on_floor():
		velocity.x=150
	else:
		velocity.x=0
	#floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()
