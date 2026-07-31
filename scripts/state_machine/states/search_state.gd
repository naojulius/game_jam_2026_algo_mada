# search_state.gd
class_name SearchState
extends StateBase

func enter() -> void:
	print("[%s] Étape 1 : RECHERCHE (Search)..." % character.character_name)
	_perform_search()

func _perform_search() -> void:
	var start_grid := AStarManager.world_to_grid(character.global_position)
	var target_grid := _get_far_random_walkable_target(start_grid, 3)
	
	var calculated_path := AStarManager.find_path_recursive(start_grid, target_grid, 100)
	
	# Si la position actuelle est dans le chemin, on la retire
	if not calculated_path.is_empty() and calculated_path[0] == start_grid:
		calculated_path.remove_at(0)

	# --- CORRECTION DE LA BOUCLE ---
	if calculated_path.is_empty():
		print("[%s] Aucun chemin trouvé ! Fin de la recherche pour ce tour." % character.character_name)
		character.current_path = []
		# Au lieu de relancer ou passer à Move, on passe directement à Dig ou on finit le tour
		character.state_machine.change_state("dig")
		return

	character.current_path = calculated_path
	character.state_machine.change_state("move")

func _get_far_random_walkable_target(current_pos: Vector2i, min_distance: int = 3) -> Vector2i:
	var walkable_cells := AStarManager.get_all_walkable_cells()
	if walkable_cells.is_empty():
		return current_pos

	var far_cells: Array[Vector2i] = []
	for cell in walkable_cells:
		if abs(cell.x - current_pos.x) + abs(cell.y - current_pos.y) >= min_distance:
			far_cells.append(cell)

	if not far_cells.is_empty():
		return far_cells.pick_random()

	return walkable_cells.pick_random()
