extends Node2D
@export var wall : PackedScene
var rota = 0
var espacement = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	rota /= 10
	for angle in range(0, rota):
		crea(angle) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func crea(angle):
	
	var mur =wall.instantiate()
	if angle == 0:
		mur.x = 0
		mur.y = 0
		crea(1)
	else:
		angle *= 10
		mur.x = cos(angle*10)*espacement
		mur.x = sin(angle*10)*espacement
		mur.Skew = angle 
	add_child(mur)
