@tool
class_name Card
extends Node2D

enum RANK {JOKER, ACE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING}
enum SUIT {CLUBS, DIAMONDS, HEARTS, SPADES}

signal flipped(card: Card)

signal focus(card: Card)
signal unfocus

signal clicked(card: Card)
signal released


@export var rank: RANK:
	set(val):
		rank = val
		_setup_button()

@export var suit: SUIT:
	set(val):
		suit = val
		_setup_button()

@export var card_texture: CardTexture = preload("res://src/resources/card_textures/pixel_white_red.tres"):
	set(val):
		card_texture = val
		_setup_button()

@export var show_back: bool = false:
	set(val):
		show_back = val
		_setup_button()

@onready var anim_player: AnimationPlayer = %AnimationPlayer
var card_button: TextureButton = TextureButton.new()


func _ready() -> void:
	add_child(card_button)
	_setup_button()
	_connect_signals()


func _connect_signals() -> void:
	card_button.mouse_entered.connect(_on_mouse_entered)
	card_button.mouse_exited.connect(_on_mouse_exited)
	card_button.button_down.connect(_on_button_down)
	card_button.button_up.connect(_on_button_up)


func _setup_button() -> void:
	card_button.texture_normal = _get_texture()
	card_button.size = card_texture.get_size()
	card_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	card_button.anchors_preset = TextureButton.PRESET_CENTER


func _get_texture() -> Texture2D:
	if show_back:
		return card_texture.back
	if rank == RANK.JOKER:
		return card_texture.joker
	# Subtract 1 to exclude RANK.JOKER
	return card_texture.get_all()[(RANK.size() - 1) * suit + rank - 1]


func get_size() -> Vector2:
	return card_texture.get_size()


func play_flip_card() -> void:
	var animation: StringName = "flip_up" if show_back else "flip_down"
	anim_player.play(animation)


func card_string() -> String:
	return str(RANK.find_key(rank)) + ' OF ' + str(SUIT.find_key(suit))


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"flip_up", "flip_down":
			flipped.emit(self)


func _on_mouse_entered():
	focus.emit(self)


func _on_mouse_exited():
	unfocus.emit()


func _on_button_down():
	clicked.emit(self)


func _on_button_up():
	released.emit()
