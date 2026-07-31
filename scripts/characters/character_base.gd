# character_base.gd
class_name CharacterBase
extends CharacterBody2D

@export var character_name: String = "Character"

var state_machine: StateMachine
var current_path: Array[Vector2i] = []

func _ready() -> void:
	if not Engine.is_editor_hint():
		state_machine = StateMachine.new(self)
		
		if not self in TurnManager.characters:
			TurnManager.characters.append(self)
			
		state_machine.change_state("idle")

func _process(delta: float) -> void:
	# NE S'EXÉCUTE QUE SI C'EST LE TOUR DE CE PERSONNAGE
	if TurnManager.current_character == self and state_machine:
		state_machine.update(delta)

func _physics_process(delta: float) -> void:
	# NE S'EXÉCUTE QUE SI C'EST LE TOUR DE CE PERSONNAGE
	if TurnManager.current_character == self and state_machine:
		state_machine.physics_update(delta)

## Déclenché uniquement par le TurnManager
func take_turn() -> void:
	# Le TurnManager nous a donné la main : on démarre la séquence !
	if state_machine:
		state_machine.change_state("search")

func end_turn() -> void:
	TurnManager.next_turn()
	pass
