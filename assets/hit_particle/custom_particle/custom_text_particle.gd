extends CPUParticles
class_name CustomTextParticle

onready var timer = $Timer

func is_emitting() -> bool:
	return not timer.is_stopped()
	
func display_hit(s :String):
	if not mesh is TextMesh:
		return
		
	(mesh as TextMesh).text = s
	
	if is_emitting():
		return
		
	timer.start()
	emitting = true
