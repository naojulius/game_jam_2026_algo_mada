extends CharacterBase

func _ready() -> void:
	character_name = "Ikotofotsy"
	super._ready()

func take_turn() -> void:
	#print("Ikotofotsy prépare ses actions...")
	# Exécute la logique de CharacterBase (qui lance state_machine.change_state("search"))
	super.take_turn()
