extends Node2D
@export var wall : PackedScene
var rota = 0
var aj = -90
var espacement = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	for angle in range(0, rota):
		crea(angle) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func crea(angle):
	var mur =wall.instantiate()
	if angle == 0:
		mur.position.x = 0
		mur.position.y = 0
		crea(1)
	else:
		var angle_rad = deg_to_rad(angle + aj)
		mur.position.x = cos(angle_rad)*espacement
		mur.position.y = sin(angle_rad)*espacement
		mur.rotation_degrees = angle_rad
		add_child(mur)
