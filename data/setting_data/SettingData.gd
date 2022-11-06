extends BaseData
class_name SettingData

export var is_sfx_mute :bool = false
export var is_joystick_fixed :bool = false
export var is_invert_y :bool = false

func from_dictionary(data : Dictionary):
	is_sfx_mute = data["is_sfx_mute"]
	is_joystick_fixed = data["is_joystick_fixed"]
	is_invert_y = data["is_invert_y"]
	
func to_dictionary() -> Dictionary :
	var data = {}
	data["is_sfx_mute"] = is_sfx_mute
	data["is_joystick_fixed"] = is_joystick_fixed
	data["is_invert_y"] = is_invert_y
	return data
	
