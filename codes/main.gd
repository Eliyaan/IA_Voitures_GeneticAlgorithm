extends Node2D
@export var voitures : PackedScene
var steps = 0
var nb_voitures = 210
var running = false
var muta = 0.05

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
		var sorted_array = $Voitures.get_children()
		sorted_array.sort_custom(custom_sort)
		for node in sorted_array.slice(70, 210):
			node.free()
		sorted_array.resize(70)
		for voiture in sorted_array:
			voiture.position = Vector2(-400, 200)
			voiture.rotation_degrees = 0
			for _f in range(2):
				var car = voitures.instantiate()
				car.position.x = -400
				car.position.y = 200
				car.nn = voiture.nn.duplicate(true)
				#Weights
				for i in range(car.nn["weights_list"].size()):
					for j in range(car.nn["weights_list"][i].size()):
						for k in range(car.nn["weights_list"][i][j].size()):
							car.nn["weights_list"][i][j][k] += randf_range(-muta, muta)
				#Biases 
				for i in range(car.nn["layers_list"].size()):
					for j in range(car.nn["layers_list"][i][0].size()):
						car.nn["layers_list"][i][0][j] += randf_range(-muta, muta)
				$Voitures.add_child(car)
		for i in range($Voitures.get_child_count()):
			$Voitures.get_child(i).alive = true
		steps = 0

func custom_sort(a, b): #high = first
	return a.points > b.points
	
func spawn_voitures():
	var car = voitures.instantiate()
	car.position = Vector2(-400, 200)
	car.init()
	car.alive = true
	$Voitures.add_child(car)
