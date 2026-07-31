# state_machine.gd
class_name StateMachine
extends RefCounted

var current_state: StateBase = null
var states: Dictionary = {}
var character: CharacterBase

func _init(p_character: CharacterBase) -> void:
	character = p_character
	
	# Enregistrement de tous les états en code
	_register_state("idle", IdleState.new())
	_register_state("search", SearchState.new())
	_register_state("move", MoveState.new())
	_register_state("dig", DigState.new())

func _register_state(state_name: String, state_instance: StateBase) -> void:
	state_instance.character = character
	states[state_name] = state_instance

func change_state(new_state_name: String) -> void:
	var state_key := new_state_name.to_lower()
	
	if not states.has(state_key):
		#push_warning("StateMachine: État '%s' inconnu !" % new_state_name)
		return

	if current_state:
		current_state.exit()

	current_state = states[state_key]
	current_state.enter()

func update(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
