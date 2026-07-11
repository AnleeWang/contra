extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get_tree().paused =true
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	get_tree().paused =false
	queue_free()
