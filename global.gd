extends Node

var ui:CanvasLayer
var menu_start:Control
#var menu_in_game:MenuInGame
var menu_over:Control
var menu_option:Control
var level:ALevel
var level3d:ALevel3D
var player:Actor
var score:int
var life:int=5

func _ready() -> void:
	pass
	#process_mode = Node.PROCESS_MODE_ALWAYS
	#ui=SceneUI.instantiate()
	#get_tree().root.add_child.call_deferred(ui)
	#menu_in_game=SceneMenuInGame.instantiate()
		
func add_menu_start():
	#menu_start=SceneStart.instantiate()
	get_tree().root.add_child(menu_start)

func add_menu_over():
	#menu_over=SceneOver.instantiate()
	get_tree().root.add_child(menu_over)

func add_menu_option():
	#menu_option=SceneMenuOption.instantiate()
	get_tree().root.add_child(menu_option)

func goto_scene(path: String) -> void:
	# This function will usually be called from a signal callback,
	# or some other function from the running scene.
	# Deleting the current scene at this point might be
	# a bad idea, because it may be inside of a callback or function of it.
	# The worst case will be a crash or unexpected behavior.

	# The way around this is deferring the load to a later time, when
	# it is ensured that no code from the current scene is running:
	_deferred_goto_scene.call_deferred(path)


func _deferred_goto_scene(path: String) -> void:
	# Immediately free the current scene. There is no risk here because the
	# call to this method is already deferred.
	get_tree().current_scene.free()

	var packed_scene: PackedScene = ResourceLoader.load(path)

	var instanced_scene := packed_scene.instantiate()

	# Add it to the scene tree, as direct child of root
	get_tree().root.add_child(instanced_scene)

	# Set it as the current scene, only after it has been added to the tree
	get_tree().current_scene = instanced_scene

	
