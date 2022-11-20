extends StaticBody
class_name MineableResource

signal on_destroyed(_resources)
signal on_take_damage(_resources, _damage)

export var enable_damage :bool = true
export var team :int = 0
export var is_dead :bool = false
export var hp : int = 100
export var max_hp : int = 100

export var reset_delay : int = 60

############################################################
remotesync func _heal(_hp_left, _hp_added : int) -> void:
	if is_dead:
		return
		
	hp = _hp_left
	
remotesync func _take_damage(_hp_left, _damage : int) -> void:
	if is_dead:
		return
		
	hp = _hp_left
	emit_signal("on_take_damage", self, _damage)
	
remotesync func _dead() -> void:
	if is_instance_valid(_reset_timer):
		_reset_timer.start()
		
	is_dead = true
	set_process(false)
	emit_signal("on_destroyed", self)
	
remotesync func _reset() -> void:
	hp = max_hp
	is_dead = false
	set_process(true)
	
############################################################
var _reset_timer :Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	if _is_master():
		_reset_timer = Timer.new()
		_reset_timer.wait_time = reset_delay
		_reset_timer.one_shot = true
		_reset_timer.autostart = false
		add_child(_reset_timer)
		_reset_timer.connect("timeout", self, "reset")
	
func heal(_hp_added : int) -> void:
	if is_dead:
		return
		
	if hp + _hp_added > max_hp:
		hp = max_hp
	else:
		hp += _hp_added
	
	rpc("_heal", hp, _hp_added)
	
func take_damage(_damage : int, hit_by_player :PlayerData) -> void:
	if is_dead:
		return
		
	if not enable_damage:
		return
		
	hp -= _damage
	
	if hp < 1:
		dead(hit_by_player)
		return
		
	rpc_unreliable("_take_damage", hp, _damage)
	
func dead(hit_by_player : PlayerData) -> void:
	rpc("_dead")
	
func reset():
	rpc("_reset")
	
############################################################
# multiplayer func
func _is_master() -> bool:
	if not get_tree().network_peer:
		return false
		
	if not is_network_master():
		return false
		
	return true
	
