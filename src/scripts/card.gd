@tool
extends Node2D

@export var card_texture: CardTexture = preload("res://src/resources/card_textures/default.tres")

@onready var card_sprite = $Sprite2D

func _ready() -> void:
	card_sprite.texture = card_texture.back
	card_sprite.scale = Vector2(card_texture.scale, card_texture.scale)
