extends BaseStructure
class_name MovingStructure

############################################################
# multiplayer func
func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if is_dead:
		return
	
	if _is_master():
		rset_unreliable("_puppet_translation", translation)
		rset_unreliable("_puppet_rotation", rotation)
	
puppet var _puppet_rotation :Vector3
puppet var _puppet_translation :Vector3

func puppet_moving(delta):
	.puppet_moving(delta)
	translation = translation.linear_interpolate(_puppet_translation, 2.5 * delta)
	rotation.x = lerp_angle(rotation.x, _puppet_rotation.x, 5 * delta)
	rotation.y = lerp_angle(rotation.y, _puppet_rotation.y, 5 * delta)
	rotation.z = lerp_angle(rotation.z, _puppet_rotation.z, 5 * delta)
