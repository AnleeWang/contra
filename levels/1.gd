extends ALevel

@onready var sub_viewport = $ParallaxBackground/SubViewport
@onready var bridge_begin: StaticBody2D = $Bridge/BridgeBegin
@onready var bridge_end: StaticBody2D = $Bridge/BridgeEnd

var bridge_index:int=0
@onready var bridges: Array
@onready var bridge: Node2D = $Bridge
@onready var timer_bridge: Timer = $TimerBridge
var timer_started:bool
func _ready():
	super._ready()
	player=$Bill
	bridges=bridge.get_children()
	#print(Vector2(0, 100)*transform )
	#print(Bill.Sta)
	#print(bridges,player)
	#print("get tree:",get_tree(),self)
func _process(delta):
	super._process(delta)
	if bridge_begin:
		if player.global_position.x>bridge_begin.global_position.x:
			if not timer_started:
				#timer_bridge.start()
				timer_started=true



func _on_timer_bridge_timeout() -> void:
	var b:StaticBody2D= bridges[bridge_index]
	#var exp:Adie_eff=DIE_EXP_ITEM.instantiate()
	#exp.position=b.position
	#bridge.add_child(exp)
	#snd.stream=SND_EXP_1
	#snd.play()
	#b.queue_free()
	#if b==bridge_end:
		#timer_bridge.stop()
		#return
	#bridge_index+=1
	
