extends StaticBody
class_name MineableResource

signal on_destroyed(_resources)
signal on_take_damage(_resources, _damage)

export var is_dead :bool = false
export var hp : int = 100.0
export var max_hp : int = 100.0

############################################################
remotesync func _take_damage(_hp_left, _damage : int) -> void:
	if is_dead:
		return
		
	hp = _hp_left
	emit_signal("on_take_damage", self, _damage)
	
############################################################
remotesync func _dead() -> void:
	is_dead = true
	set_process(false)
	emit_signal("on_destroyed",self)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func take_damage(_damage : int, hit_by_player :PlayerData) -> void:
	if is_dead:
		return
		
	hp -= _damage
	
	if hp < 1:
		dead(hit_by_player)
		return
		
	rpc_unreliable("_take_damage", hp, _damage)
	
func dead(hit_by_player : PlayerData) -> void:
	rpc("_dead")
	
############################################################
# multiplayer func
func _is_master() -> bool:
	if not get_tree().network_peer:
		return false
		
	if not is_network_master():
		return false
		
	return true
	
