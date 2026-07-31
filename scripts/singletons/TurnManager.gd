extends Node

signal turn_changed(current_character: CharacterBase)

var characters: Array[CharacterBase] = []
var current_character_index: int = -1
var current_character: CharacterBase = null
var turn_started: bool = false

func _process(_delta: float) -> void:
	if not characters.is_empty() and not turn_started:
		turn_started = true
		start_action()

func start_action() -> void:
	if characters.is_empty():
		#push_warning("TurnManager: Aucun personnage n'a été enregistré !")
		turn_started = false
		return
	
	# Sélection aléatoire du tout premier personnage
	current_character_index = randi() % characters.size()
	_start_turn()

func next_turn() -> void:
	if characters.is_empty():
		return
		
	# L'opérateur modulo % permet de boucler indéfiniment : 
	# si on arrive à la fin du tableau, il revient à 0 automatiquement
	current_character_index = (current_character_index + 1) % characters.size()
	
	await get_tree().process_frame
	_start_turn()

func _start_turn() -> void:
	current_character = characters[current_character_index]
	#print_rich("[color=yellow]C'est le tour de : %s (Index: %d)[/color]" % [current_character.character_name, current_character_index])
	
	turn_changed.emit(current_character)
	current_character.take_turn()
	current_character.end_turn()
