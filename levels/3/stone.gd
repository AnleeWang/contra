extends RigidBody2D
class_name StoneL3

var blood:=3
var dead:=false
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contact_monitor=true
	max_contacts_reported=3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hit_by_blt(_blt:Node2D):
	if dead: return
	#print("stone be hitted")
	Global.level.snd.stream=Global.level.SND_DAMAGE
	Global.level.snd.play()
	blood-=_blt.power
	if blood<=0:
		dead=true
		#var exp:=DIE_EFFECT_1.instantiate()
		#exp.position=position
		#get_parent().add_child(exp)
		queue_free()
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name=="Floor":
		#print("stone:",body)
		#if linear_velocity.y<300:
			
		animation_player.play(&"bounce")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		&"bounce":
			animation_player.play(&"1")


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
