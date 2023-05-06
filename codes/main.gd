extends Node2D
@export var voitures : PackedScene
var steps = 0
var nb_voitures = 210
var running = false

# Called when the node enters the scene tree for the first time.
func _ready():
	#Gen voitures
	for _voiture in range(0, nb_voitures):
		spawn_voitures()
	running = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if running:
		steps += 1
	if steps > 600:
		running = false
		var sorted_array = $Voitures.get_children()
		sorted_array.sort_custom(custom_sort)
		for node in sorted_array.slice(70, 210):
			node.free()
		sorted_array.resize(70)
		for voiture in sorted_array:
			voiture.position = Vector2(-400, 200)
			voiture.rotation_degrees = 0

			
	
func custom_sort(a, b): #high = first
	return a.points > b.points
	
func spawn_voitures():
	var car
	car = voitures.instantiate()
	car.position.x = -400
	car.position.y = 200
	$Voitures.add_child(car)
