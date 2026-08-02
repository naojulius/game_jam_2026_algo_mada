# move_state.gd
class_name MoveState
extends StateBase

## Vitesse de déplacement du personnage (en pixels par seconde)
var move_speed: float = 80.0

## Indice du point courant dans le chemin
var current_path_index: int = 0
var target_world_position: Vector2 = Vector2.ZERO
var is_moving: bool = false

func enter() -> void:
	character.emote.hide_emote()
	print("[%s] Étape 2 : DÉPLACEMENT (Move)..." % character.character_name)
	
	current_path_index = 0
	
	# S'il n'y a pas de chemin valide, on saute le déplacement et passe directement à Dig (ou Idle)
	if character.current_path.is_empty():
		#print("[%s] Aucun chemin à parcourir. Passage à l'état Dig." % character.character_name)
		character.state_machine.change_state("dig")
		return
		
	_get_next_target()

func physics_update(delta: float) -> void:
	if not is_moving:
		return

	# Déplacement fluide (lerp / move_toward) vers la prochaine case
	character.global_position = character.global_position.move_toward(
		target_world_position, 
		move_speed * delta
	)
	
	# Si le personnage est arrivé très près de la case cible
	if character.global_position.distance_to(target_world_position) < 2.0:
		character.global_position = target_world_position # Recalage parfait sur la grille
		current_path_index += 1
		_get_next_target()

func _get_next_target() -> void:
	# Si on a parcouru tout le chemin
	if current_path_index >= character.current_path.size():
		is_moving = false
		#print("[%s] Destination atteinte ! Passage au creusage." % character.character_name)
		
		# On vide le chemin et passe à l'état suivant
		character.current_path.clear()
		character.state_machine.change_state("dig")
		return

	# Récupère la position Monde de la prochaine case sur la grille
	var next_grid_pos := character.current_path[current_path_index]
	target_world_position = AStarManager.grid_to_world(next_grid_pos)
	is_moving = true
