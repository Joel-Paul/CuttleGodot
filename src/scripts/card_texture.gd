@tool
extends Resource
class_name CardTexture

@export var scale: float = 1

#region Clubs
@export_group("Clubs", "clubs")
@export var clubs_ace: Texture2D
@export var clubs_two: Texture2D
@export var clubs_three: Texture2D
@export var clubs_four: Texture2D
@export var clubs_five: Texture2D
@export var clubs_six: Texture2D
@export var clubs_seven: Texture2D
@export var clubs_eight: Texture2D
@export var clubs_nine: Texture2D
@export var clubs_ten: Texture2D
@export var clubs_jack: Texture2D
@export var clubs_queen: Texture2D
@export var clubs_king: Texture2D
#endregion

#region Diamonds
@export_group("Diamonds", "diamonds")
@export var diamonds_ace: Texture2D
@export var diamonds_two: Texture2D
@export var diamonds_three: Texture2D
@export var diamonds_four: Texture2D
@export var diamonds_five: Texture2D
@export var diamonds_six: Texture2D
@export var diamonds_seven: Texture2D
@export var diamonds_eight: Texture2D
@export var diamonds_nine: Texture2D
@export var diamonds_ten: Texture2D
@export var diamonds_jack: Texture2D
@export var diamonds_queen: Texture2D
@export var diamonds_king: Texture2D
#endregion

#region Hearts
@export_group("Hearts", "hearts")
@export var hearts_ace: Texture2D
@export var hearts_two: Texture2D
@export var hearts_three: Texture2D
@export var hearts_four: Texture2D
@export var hearts_five: Texture2D
@export var hearts_six: Texture2D
@export var hearts_seven: Texture2D
@export var hearts_eight: Texture2D
@export var hearts_nine: Texture2D
@export var hearts_ten: Texture2D
@export var hearts_jack: Texture2D
@export var hearts_queen: Texture2D
@export var hearts_king: Texture2D
#endregion

#region Spades
@export_group("Spades", "spades")
@export var spades_ace: Texture2D
@export var spades_two: Texture2D
@export var spades_three: Texture2D
@export var spades_four: Texture2D
@export var spades_five: Texture2D
@export var spades_six: Texture2D
@export var spades_seven: Texture2D
@export var spades_eight: Texture2D
@export var spades_nine: Texture2D
@export var spades_ten: Texture2D
@export var spades_jack: Texture2D
@export var spades_queen: Texture2D
@export var spades_king: Texture2D
#endregion

@export var joker: Texture2D
@export var back: Texture2D

func get_size() -> Vector2:
	return back.get_size() * scale

func get_height() -> float:
	return back.get_height() * scale

func get_width() -> float:
	return back.get_width() * scale
