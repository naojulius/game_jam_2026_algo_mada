# idle_state.gd
class_name IdleState
extends StateBase

func enter() -> void:
	print("%s est en attente (IDLE)." % character.character_name)
	pass
