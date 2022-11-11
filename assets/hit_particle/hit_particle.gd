extends CPUParticles
class_name HitParticle

func display_hit(s :String):
	if not mesh is TextMesh:
		return
		
	(mesh as TextMesh).text = s
	
	if emitting:
		return
		
	emitting = true
