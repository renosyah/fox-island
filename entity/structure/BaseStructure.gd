extends BaseEntity
class_name BaseStructure

############################################################
# Called when the node enters the scene tree for the first time.
func _ready():
	set_network_master(Network.PLAYER_HOST_ID)
