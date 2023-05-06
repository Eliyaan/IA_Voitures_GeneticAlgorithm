extends Node2D
@export var voitures : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	#Gen voitures
	for _voiture in range(0, 200):
		spawn_voitures()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func spawn_voitures():
	var car
	car = voitures.instantiate()
	car.position.x = -400
	car.position.y = 200
	$Voitures.add_child(car)
