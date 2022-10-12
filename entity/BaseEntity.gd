extends KinematicBody
class_name BaseEntity

signal on_dead(_entity, _killed_by)
signal on_heal(_entity, _hp_added)
signal on_take_damage(_entity, _damage, _hit_by)
signal on_respawn(_entity)

# identity owner
var player :PlayerData

# vitality
export var is_dead :bool = false
var hit_by_player :PlayerData = PlayerData.new()
export var tag : String = "entity"
export var hp : int = 100.0
export var max_hp : int = 100.0

# misc network
var _network_timmer : Timer

############################################################
# multiplayer func
func _network_timmer_timeout() -> void:
	pass
	
remotesync func _set_network_master(_id :int) -> void:
	# call super to avoid stack overflow
	.set_network_master(_id)
	_setup_network_timer()
	
remotesync func _heal(_hp_left, _hp_added : int) -> void:
	if is_dead:
		return
		
	hp = _hp_left
	emit_signal("on_heal", self, _hp_added)
	
remotesync func _take_damage(_hp_left, _damage : int, _hit_by :Dictionary) -> void:
	if is_dead:
		return
		
	hp = _hp_left
	hit_by_player.from_dictionary(_hit_by)
	
	emit_signal("on_take_damage", self, _damage, hit_by_player)
	
remotesync func _dead(_kill_by :Dictionary) -> void:
	is_dead = true
	set_process(false)
	
	hit_by_player.from_dictionary(_kill_by)
	emit_signal("on_dead", self, hit_by_player)
	
remotesync func _reset() -> void:
	hp = max_hp
	is_dead = false
	
	set_physics_process(false)
	
############################################################
func _ready() -> void:
	_set_network_master(Network.PLAYER_HOST_ID)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta :float) -> void:
	# fall below map
	# stop fall
	if translation.y < -25.0:
		return
		
	moving(delta)
	
	if not _is_network_running():
		return
	
	if _is_master():
		master_moving(delta)
	else:
		puppet_moving(delta)
	
func master_moving(delta :float) -> void:
	pass
	
func moving(_delta :float) -> void:
	pass
	
func puppet_moving(_delta :float) -> void:
	pass
	
func set_network_master(_id :int, recursive: bool = true) -> void:
	#.set_network_master(_id, recursive)
	rpc("_set_network_master", _id)
	
func heal(_hp_added : int) -> void:
	if is_dead:
		return
		
	if hp + _hp_added > max_hp:
		hp = max_hp
	else:
		hp += _hp_added
	
	rpc("_heal", hp, _hp_added)
	
func take_damage(_damage : int, hit_by_player : PlayerData) -> void:
	if is_dead:
		return
		
	hp -= _damage

	if hp < 1:
		dead(hit_by_player)
		return
		
	rpc_unreliable("_take_damage", hp, _damage, hit_by_player.to_dictionary())
	
func dead(kill_by_player : PlayerData) -> void:
	rpc("_dead", kill_by_player.to_dictionary())
	
func reset():
	rpc("_reset")
	
############################################################
func team() -> int:
	if not player:
		return 0
		
	return player.player_team
	
func is_dead() -> bool:
	return is_dead
	
############################################################
# multiplayer func
func _is_network_running() -> bool:
	if not get_tree().network_peer:
		return false
		
	if get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
		
	return true
	
func _is_master() -> bool:
	if not get_tree().network_peer:
		return false
		
	if not is_network_master():
		return false
		
	return true
	
func _setup_network_timer() -> void:
	if is_instance_valid(_network_timmer):
		_network_timmer.stop()
		_network_timmer.queue_free()
		
	if not _is_network_running():
		return
		
	if not _is_master():
		return
		
	_network_timmer = Timer.new()
	_network_timmer.wait_time = Network.LATENCY_DELAY
	_network_timmer.connect("timeout", self , "_network_timmer_timeout")
	_network_timmer.autostart = true
	add_child(_network_timmer)
	
























