extends HBoxContainer

onready var fps = $fps
onready var ping = $ping

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	ping.text = "Ping : " + str(Network.ping) + "/ms"
	fps.text = "Fps : " +  str(Engine.get_frames_per_second())
	
