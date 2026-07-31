@tool
extends Node2D

#region CONST
const ROCK: String = "#"
const TREE: String = "T"
const HOLE: String = "O"
const IMAHAKI: String = "M"
const PATH: String = "."
const INVADER: String = "I"
const IKOTOFOTSY: String = "K"

const TILEMAP_PATH_SOURCE_ID: int = 0
const TILEMAP_PATH_ATLAS_COORDS: Vector2i = Vector2i(0, 0)
#endregion

#region @ONREADY
@onready var tile_map_layer: TileMapLayer = $TileMapsNode/TileMapLayer
@onready var rocks_node: Node2D = $NaturesNode/RocksNode
@onready var trees_node: Node2D = $NaturesNode/TreesNode
@onready var hole_node: Node2D = $NaturesNode/HoleNode
@onready var characters_node: Node2D = $NaturesNode/CharactersNode
#endregion

#region @EXPORT_VARIABLE
@export_group("Map")
@export var map_tiles: Vector2 = Vector2(16, 16)

@export_group("Natures")
@export var packed_tree: PackedScene
@export var packed_rock: PackedScene
@export var packed_hole: PackedScene

@export_group("Characters")
@export var packed_imahaki: PackedScene
@export var packed_invader: PackedScene
@export var packed_ikotofotsy: PackedScene

#endregion

#region EDITOR_ACTION
@export_group("Actions")
@export_tool_button("Generate map") var generate_map_action = generate_map
#endregion

#region VARIABLES
var map_text_path: String = "res://maps/map.txt"

var walkable_pos: Array[Vector2i] = []
var unwalkable_pos: Array[Vector2i] = []
#endregion

func _ready() -> void:
	MapManager.map = self
	if not Engine.is_editor_hint():
		if characters_node and characters_node.get_child_count() == 0:
			generate_map()

#region MAP_GENERATION
func generate_map() -> void:
	var map_lines: Array[String] = MapManager.read_map_text(map_text_path)
	if map_lines.is_empty():
		return
		
	_clear_existing_map()
	
	for y in range(map_lines.size()):
		var line := map_lines[y]
		
		for x in range(line.length()):
			var char_symbol := line[x]
			var grid_pos := Vector2i(x, y)

			# Position monde centrée pour l'instanciation des scènes
			var spawn_position := Vector2(
				x * map_tiles.x + map_tiles.x / 2.0,
				y * map_tiles.y + map_tiles.y / 2.0
			)

			# 1. On pose la tuile de sol PARTOUT sans exception
			if tile_map_layer:
				tile_map_layer.set_cell(grid_pos, TILEMAP_PATH_SOURCE_ID, TILEMAP_PATH_ATLAS_COORDS)

			# 2. Traitement selon le symbole et tri des tableaux
			match char_symbol:
				PATH, IMAHAKI, INVADER, IKOTOFOTSY:
					walkable_pos.append(grid_pos)
					if char_symbol == IMAHAKI:
						_spawn_element(packed_imahaki, characters_node, spawn_position)
					if char_symbol == INVADER:
						_spawn_element(packed_invader, characters_node, spawn_position)
					if char_symbol == IKOTOFOTSY:
						_spawn_element(packed_ikotofotsy, characters_node, spawn_position)
						
				ROCK:
					unwalkable_pos.append(grid_pos)
					_spawn_element(packed_rock, rocks_node, spawn_position)
					
				TREE:
					unwalkable_pos.append(grid_pos)
					_spawn_element(packed_tree, trees_node, spawn_position)
					
				HOLE:
					unwalkable_pos.append(grid_pos)
					_spawn_element(packed_hole, hole_node, spawn_position)
					
				_:
					unwalkable_pos.append(grid_pos)
					
			#Setup ASTAR MANAGER
			var map_size := Vector2i(map_lines[0].length(), map_lines.size())
			AStarManager.setup_grid(map_size, map_tiles, walkable_pos)

func _clear_existing_map() -> void:
	walkable_pos.clear()
	unwalkable_pos.clear()
	
	if tile_map_layer:
		tile_map_layer.clear()
		
	for parent in [rocks_node, trees_node, hole_node, characters_node]:
		if parent:
			for child in parent.get_children():
				child.free()

func _spawn_element(packed_scene: PackedScene, parent_node: Node2D, pos: Vector2) -> void:
	if not packed_scene or not parent_node:
		return
	
	var instance := packed_scene.instantiate()
	parent_node.add_child(instance)
	instance.global_position = pos

	# Ne définir l'owner QUE si on est dans l'éditeur
	if Engine.is_editor_hint() and get_tree() and get_tree().edited_scene_root:
		instance.owner = get_tree().edited_scene_root
#endregion
