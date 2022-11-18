extends Spatial

var enemy_teams :Array = []
var ignores :Array = []
var targets :Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func get_target() ->BaseUnit:
	if targets.empty():
		return null
		
	if not is_instance_valid(targets[0]):
		return null
		
	return targets[0]
	
func _on_Area_body_entered(body):
	if body in ignores:
		return
		
	if not body is BaseUnit:
		return
		
	if not body.player.player_team in enemy_teams:
		return
		
	targets.append(body)
	
	
func _on_Area_body_exited(body):
	if not body in targets:
		return
		
	targets.erase(body)
