extends Area2D
var kind:String

const ITEM = preload("uid://bgxx1lsb5atmn")
const DIE_EXP = preload("uid://bmp5coom642ae")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	kind=name.substr(7,1)
	#print("box_kind:",kind)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hit_by_blt(_blt:Node2D):
	set_collision_layer_value(6, false)
	set_collision_mask_value(8, false)
	
	DieExpFx.spawn_local(get_parent(), DIE_EXP, position, z_index, true)
	#await get_tree().create_timer(.15).timeout
	var item:Node2D=ITEM.instantiate()
	item.kind=kind
	item.position=position
	Global.level.call_deferred("add_child",item)
	queue_free()

	
