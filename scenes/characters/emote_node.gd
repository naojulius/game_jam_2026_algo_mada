extends Node2D
@onready var emote_animation_player: AnimationPlayer = $EmoteAnimationPlayer

func _ready() -> void:
	hide()

func hide_emote():
	hide()

func play_search():
	show()
	print(visible)
	emote_animation_player.play("search")

func play_anxious():
	show()
	emote_animation_player.play("anxious")
	
func play_found_point():
	show()
	emote_animation_player.play("found_point")
	
