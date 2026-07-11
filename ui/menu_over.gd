extends Control

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.menu_option:
		Global.menu_option.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	restart()	

func restart():
	Global.add_menu_start()
	#get_parent().remove_child(self)
	queue_free()
