extends Area2D

func hit_by_blt(blt: Node2D) -> void:
	var boss7 := get_parent().get_parent()
	if boss7.has_method("hit_heart"):
		boss7.hit_heart(blt)
