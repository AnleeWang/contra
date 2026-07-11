extends Ablt
class_name BltPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
func _on_area_entered(area):
	#print(area.name)
	if area.name == "Area2DCannon2":
		area.owner.hit_by_blt(self)
		spark()
		return
	if area.name.begins_with("Cannon") and area.has_method("hit_by_blt"):
		area.hit_by_blt(self)
		spark()
		return
	if area.name == "Heart" and area.has_method("hit_by_blt"):
		area.hit_by_blt(self)
		spark()
		return
	#if shooter==area.owner:return
	if area is ItemEye or area.name.substr(0,7)=="ItemBox"or area.name.substr(0,8)=="E3Cannon":
		if area.has_method("hit_by_blt"):
			area.hit_by_blt(self)
			spark()

func _on_body_entered(body: Node2D) -> void:
	#print(body)
	if body is Actor and body.is_enemy:
		body.hit_by_blt(self)
		spark()
	if body.name.substr(0,5)=="Steel":
		spark()
	if body.name.substr(0,7)=="NailBlk":
		body.hit_by_blt(self)
		spark()
