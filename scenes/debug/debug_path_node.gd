extends Node2D
@onready var sprite: Sprite2D = $Sprite

enum Type {
	PATH,
	START, 
	END,
	UNWALKABE
}

var type = Type.START

func _process(_delta: float) -> void:
	match type:
		Type.PATH:
			sprite.modulate = Color.WEB_GREEN
		Type.START:
			sprite.modulate = Color.YELLOW
		Type.END:
			sprite.modulate = Color.RED
		type.UNWALKABE:
			sprite.modulate = Color.BLACK
