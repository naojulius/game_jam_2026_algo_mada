# dig_state.gd
class_name DigState
extends StateBase

func enter() -> void:
	#print("[%s] Étape 3 : CREUSER (Dig)..." % character.character_name)
	_perform_dig()

func _perform_dig() -> void:
	# TODO : Jouer l'animation de creuse / casser la case
	
	# Simulation du temps de creusage
	await character.get_tree().create_timer(2.0).timeout
	
	# Sécurité : vérification que le personnage existe toujours après l'attente
	if not is_instance_valid(character) or not character.is_inside_tree():
		return
	
	#print("[%s] Action creuser terminée ! Fin du tour." % character.character_name)
	character.state_machine.change_state("idle")
	
	# Passe la main au personnage suivant
	character.end_turn()
