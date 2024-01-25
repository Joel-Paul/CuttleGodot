@tool
class_name Card
extends Node2D

enum RANK {JOKER, ACE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, JACK, QUEEN, KING}
enum SUIT {CLUBS, DIAMONDS, HEARTS, SPADES}

signal flipped(card: Card)
signal mouse_entered(card: Card)
signal mouse_exited(card: Card)


@export var rank: RANK:
	set(val):
		rank = val
		_set_texture()

@export var suit: SUIT:
	set(val):
		suit = val
		_set_texture()

@export var card_texture: CardTexture = preload("res://src/resources/card_textures/pixel_white_red.tres"):
	set(val):
		card_texture = val
		_set_texture()
		_set_collision()

@export var show_back: bool = false:
	set(val):
		show_back = val
		_set_texture()

@onready var anim_player: AnimationPlayer = %AnimationPlayer
var card_sprite: Sprite2D = Sprite2D.new()
var area2d: Area2D = Area2D.new()
var collision_shape: CollisionShape2D = CollisionShape2D.new()


func _ready() -> void:
	add_child(card_sprite)
	_set_texture()
	
	add_child(area2d)
	area2d.add_child(collision_shape)
	area2d.mouse_entered.connect(_mouse_entered)
	area2d.mouse_exited.connect(_mouse_exited)
	area2d.input_event.connect(_input_event)
	_set_collision()


func _set_texture() -> void:
	card_sprite.set_texture(_get_texture())
	card_sprite.scale = Vector2.ONE * card_texture.scale


func _get_texture() -> Texture2D:
	if show_back:
		return card_texture.back
	if rank == RANK.JOKER:
		return card_texture.joker
	# Subtract 1 to exclude RANK.JOKER
	return card_texture.get_all()[(RANK.size() - 1) * suit + rank - 1]


func _set_collision() -> void:
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = card_texture.get_size()
	collision_shape.shape = rect_shape

func get_size() -> Vector2:
	return card_texture.get_size()


func play_flip_card() -> void:
	var animation: StringName = "flip_up" if show_back else "flip_down"
	anim_player.play(animation)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"flip_up", "flip_down":
			flipped.emit(self)


func _mouse_entered() -> void:
	mouse_entered.emit(self)


func _mouse_exited() -> void:
	mouse_exited.emit(self)


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		_mouse_input(event)
	elif event is InputEventMouseMotion:
		_mouse_moved(event)


func _mouse_input(event: InputEventMouseButton) -> void:
	if not event.pressed:
		return _mouse_released(event)


func _mouse_released(event: InputEventMouseButton) -> void:
	pass


func _mouse_moved(event: InputEventMouseMotion) -> void:
	pass
