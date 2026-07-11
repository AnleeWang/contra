extends Ablt

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
func _on_area_entered(area):
	pass
	#if shooter==area.owner:return
	#if area.has_method("hit_by_blt"):
		#area.hit_by_blt(self)
		#sub_count()
		#spark()

func _on_body_entered(body: Node2D) -> void:
	#if shooter==body:return
	if body is Bill:
	#if body.has_method("hit_by_blt"):
		body.hit_by_blt(self)
		#print("Ablt",self)
		queue_free()
