extends Node2D
@export var voitures : PackedScene
var steps = 0
var nb_voitures = 200
var div = 10
var running = false
var muta = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	#Gen voitures
	for _voiture in range(0, nb_voitures):
		spawn_voitures()
	running = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if running:
		steps += 1
	if steps > 600:
		reset_sim()

func reset_sim():  # 
	var sorted_array = $Voitures.get_children()
	sorted_array.sort_custom(custom_sort)  # trier de la meilleure à la pire
	for i in range($Voitures.get_child_count()-1, nb_voitures/div-1, -1):
		sorted_array[i].free()  # enlever toutes les pires
	sorted_array.resize(nb_voitures/div)
	var vec = Vector2(-400, 200)
	var null_vec = Vector2(0, 0)
	for voiture in sorted_array:
		voiture.position = vec # reset les voitures sélectionnées
		voiture.rotation_degrees = 0
		voiture.alive = true
		voiture.deplac = null_vec
		voiture.points = 0
		for _f in range(div-1):
			var car = voitures.instantiate()
			car.position.x = -400
			car.position.y = 200
			car.nn = voiture.nn.duplicate(true)
			car.alive = true
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
	steps = 0
		
func custom_sort(a: Node2D, b: Node2D): #high = first
	return a.points > b.points
	
func spawn_voitures():
	var car = voitures.instantiate()
	car.position = Vector2(-400, 200)
	car.init()
	car.alive = true
	$Voitures.add_child(car)

