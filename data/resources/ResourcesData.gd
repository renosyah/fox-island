extends BaseData
class_name ResourcesData

export var resources_id :int
export var resources_name :String
export var resources_quantity :int

func from_dictionary(data : Dictionary):
	resources_id = data["resources_id"]
	resources_name = data["resources_name"]
	resources_quantity = data["resources_quantity"]
	
func to_dictionary() -> Dictionary :
	var data = {}
	data["resources_id"] = resources_id
	data["resources_name"] = resources_name
	data["resources_quantity"] = resources_quantity
	return data 
	
