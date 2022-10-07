extends Node
class_name NetworkPlayer

export var player_network_unique_id :int = 0
export var player_name :String = ""

func from_dictionary(data : Dictionary):
	player_network_unique_id = data["player_network_unique_id"]
	player_name = data["player_name"]
	
func to_dictionary() -> Dictionary :
	var data = {}
	data["player_network_unique_id"] = player_network_unique_id
	data["player_name"] = player_name
	return data
	
