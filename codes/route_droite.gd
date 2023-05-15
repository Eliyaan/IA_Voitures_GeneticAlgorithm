extends Node2D
@export var wall : PackedScene
var longueur = 10
var espacement = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	crea(0, 0, longueur)
	crea(0, 1, longueur)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func crea(x, y, long):
	var mur = wall.instantiate()
	mur.position.x = longueur/2
	mur.position.y = y*-espacement
	mur.scale.x = longueur/20
	add_child(mur)
