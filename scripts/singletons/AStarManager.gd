# astar_manager.gd
extends Node

var astar_grid: AStarGrid2D = AStarGrid2D.new()
var grid_size: Vector2i = Vector2i.ZERO
var tile_size: Vector2 = Vector2.ZERO

## Initialise la grille A* à partir des données de la carte
func setup_grid(size: Vector2i, t_size: Vector2, walkable_pos: Array[Vector2i]) -> void:
	grid_size = size
	tile_size = t_size
	
	astar_grid.region = Rect2i(Vector2i.ZERO, grid_size)
	astar_grid.cell_size = tile_size
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER # Déplacement 4 directions (Cardinal)
	astar_grid.update()

	# Tout rendre solide par défaut, puis ouvrir uniquement les cases de walkable_pos
	astar_grid.fill_solid_region(Rect2i(Vector2i.ZERO, grid_size), true)
	for pos in walkable_pos:
		if _is_in_bounds(pos):
			astar_grid.set_point_solid(pos, false)

## Convertit une position Monde (pixels) en coordonnée Grille
func world_to_grid(world_pos: Vector2) -> Vector2i:
	if tile_size.x <= 0 or tile_size.y <= 0:
		return Vector2i.ZERO
	return Vector2i(int(world_pos.x / tile_size.x), int(world_pos.y / tile_size.y))

## Convertit une coordonnée Grille en position Monde (centrée)
func grid_to_world(grid_pos: Vector2i) -> Vector2:
	if tile_size == Vector2.ZERO:
		return Vector2.ZERO
	return Vector2(
		grid_pos.x * tile_size.x + tile_size.x / 2.0,
		grid_pos.y * tile_size.y + tile_size.y / 2.0
	)

## Retourne toutes les coordonnées de grille qui ne sont pas des obstacles solides
func get_all_walkable_cells() -> Array[Vector2i]:
	var walkable: Array[Vector2i] = []
	if grid_size == Vector2i.ZERO:
		return walkable
		
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var pos := Vector2i(x, y)
			if not astar_grid.is_point_solid(pos):
				walkable.append(pos)
				
	return walkable

#region RECURSIVE_BACKTRACKING
## Trouve un chemin en utilisant le Backtracking Récursif
func find_path_recursive(start: Vector2i, target: Vector2i, max_depth: int = 60) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	
	# Sécurités initiales
	if not _is_valid_cell(start):
		push_warning("AStarManager: La position de départ %s est invalide ou solide !" % start)
		return path
		
	_apply_character_collisions()

	# Si la cible est solide ou occupée, on cherche la case marchable la plus proche de la cible
	if not _is_valid_cell(target):
		target = _get_closest_valid_neighbor(target)
		if target == Vector2i(-1, -1):
			_clear_character_collisions()
			return path

	var visited: Array[Vector2i] = []
	_backtrack_search(start, target, visited, path, max_depth)
	_clear_character_collisions()
	
	return path

## Algorithme récursif avec exploration et backtracking
func _backtrack_search(current: Vector2i, target: Vector2i, visited: Array[Vector2i], path: Array[Vector2i], max_depth: int) -> bool:
	path.append(current)
	visited.append(current)

	# Condition d'arrêt (Objectif atteint)
	if current == target:
		return true

	# Condition de fin d'exploration (Profondeur max atteinte)
	if path.size() >= max_depth:
		path.pop_back()
		return false

	# 4 directions adjacentes (Haut, Bas, Gauche, Droite)
	var neighbors: Array[Vector2i] = [
		current + Vector2i.UP,
		current + Vector2i.DOWN,
		current + Vector2i.LEFT,
		current + Vector2i.RIGHT
	]

	# Tri heuristique : prioriser les voisins les plus proches de la cible
	neighbors.sort_custom(func(a, b): return a.distance_squared_to(target) < b.distance_squared_to(target))

	for next_pos in neighbors:
		# Vérifier si la case est valide, pas solide et non visitée
		if _is_valid_cell(next_pos) and not visited.has(next_pos):
			# Appel récursif (Exploration)
			if _backtrack_search(next_pos, target, visited, path, max_depth):
				return true

	# BACKTRACKING : Si aucun voisin ne mène à la cible, on annule cette étape
	path.pop_back()
	return false

func _is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_size.x and pos.y >= 0 and pos.y < grid_size.y

func _is_valid_cell(pos: Vector2i) -> bool:
	if not _is_in_bounds(pos):
		return false
	return not astar_grid.is_point_solid(pos)

func _get_closest_valid_neighbor(pos: Vector2i) -> Vector2i:
	var neighbors: Array[Vector2i] = [
		pos + Vector2i.UP, pos + Vector2i.DOWN,
		pos + Vector2i.LEFT, pos + Vector2i.RIGHT
	]
	for n in neighbors:
		if _is_valid_cell(n):
			return n
	return Vector2i(-1, -1)
#endregion

#region CHARACTER_COLLISIONS
func _apply_character_collisions() -> void:
	if not TurnManager or TurnManager.characters.is_empty():
		return
		
	for c in TurnManager.characters:
		if is_instance_valid(c) and c != TurnManager.current_character:
			var char_grid_pos := world_to_grid(c.global_position)
			if _is_valid_cell(char_grid_pos):
				astar_grid.set_point_solid(char_grid_pos, true)

func _clear_character_collisions() -> void:
	if not TurnManager or TurnManager.characters.is_empty():
		return
		
	for c in TurnManager.characters:
		if is_instance_valid(c) and c != TurnManager.current_character:
			var char_grid_pos := world_to_grid(c.global_position)
			if _is_in_bounds(char_grid_pos):
				astar_grid.set_point_solid(char_grid_pos, false)
#endregion
