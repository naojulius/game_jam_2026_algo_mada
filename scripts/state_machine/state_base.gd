# state_base.gd
class_name StateBase
extends RefCounted

var character: CharacterBase

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
