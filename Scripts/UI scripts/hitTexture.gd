extends TextureRect

const MAX_ALPHA : float = 100.0
var currentAlpha : float = 0.0


# Create hit damage tween:
func healthTweenDown(incomingDamage):
	if currentAlpha <= MAX_ALPHA:
		var tween = create_tween()
		if currentAlpha + incomingDamage > MAX_ALPHA:
			incomingDamage = MAX_ALPHA - currentAlpha
		
		modulate.a = tween.interpolate_value(currentAlpha, currentAlpha + incomingDamage, 
		0.6, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
func healthTweenUp(healingRate) -> bool:
	var tween = create_tween()
	modulate.a = tween.interpolate_value(currentAlpha, currentAlpha - healingRate, 
	0.6, 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	
	if currentAlpha <= 0:
		return true
	return false

func freeNode():
	queue_free()
