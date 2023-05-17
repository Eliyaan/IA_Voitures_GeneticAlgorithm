extends Node2D
@export var wall : PackedScene
var longueur = 10
var espacement = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	crea(0, 1)
	crea(0, -1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func crea(x, y):
	var mur = wall.instantiate()
	mur.position.x = longueur/2.0
	mur.position.y = y*espacement/2.0
	mur.scale.x = longueur/20.0
	add_child(mur)
