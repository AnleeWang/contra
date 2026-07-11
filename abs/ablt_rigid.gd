extends RigidBody2D
class_name ABltRig
var speed:=300
var angle_degrees:int
var shooter
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#super._ready()
	contact_monitor=true
	max_contacts_reported=5
	var direction = Vector2.from_angle(deg_to_rad(angle_degrees))
	
	linear_velocity = direction.normalized() * speed
	linear_velocity=Vector2(randi_range(100,1100),0).rotated(-PI*7/8)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node) -> void:
	print(body)
	


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#print(self)
	queue_free()
