extends Node2D
@export var voitures : PackedScene
@export var circuit_tourne : PackedScene
var steps: int = 0
var nb_voitures: int = 0
var nb_offsprings: int = 20
var running: bool = false
var sim_steps: int = 300
var muta: float = 0.5
var recovery_frames: int = 1
var sorted_array: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	#Gen voitures
	for _voiture in range(0, nb_voitures):
		spawn_voitures()
	running = true
	spawn(0, 0, 10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if running:
		steps += 1
	if steps == sim_steps - 1:
		var vec = Vector2(-400, 200)
		var null_vec = Vector2(0, 0)
		sorted_array = $Voitures.get_children()
		for voiture in sorted_array:
			voiture.alive = false
			voiture.rotation_degrees = 0
			voiture.deplac = null_vec
			voiture.show()
			voiture.position = vec 
		sorted_array.sort_custom(custom_sort)  # trier de la meilleure à la pire
	elif steps >= sim_steps and steps < sim_steps + recovery_frames:
		reset_sim(steps-sim_steps)
	elif steps == sim_steps + recovery_frames +1:
		assert($Voitures.get_child_count() == nb_voitures)
		for voiture in sorted_array:
			voiture.alive = true
		steps = 0
		
func reset_sim(frame: int):  # 
	for nb in range(nb_offsprings/recovery_frames * frame, (nb_offsprings/recovery_frames) * frame + nb_offsprings/recovery_frames):
		var voiture = sorted_array[nb]
		voiture.points = 0
		for f in range(nb_voitures/nb_offsprings-1):
			var car = sorted_array[nb*(nb_voitures/nb_offsprings)+f-nb+nb_offsprings]
			car.nn = voiture.nn.duplicate(true)
			car.points = 0
			#Weights
			for i in range(car.nn["weights_list"].size()):
				for j in range(car.nn["weights_list"][i].size()):
					for k in range(car.nn["weights_list"][i][j].size()):
						car.nn["weights_list"][i][j][k] += randf_range(-muta, muta)
			#Biases 
			for i in range(car.nn["layers_list"].size()):
				for j in range(car.nn["layers_list"][i][0].size()):
					car.nn["layers_list"][i][0][j] += randf_range(-muta, muta)
		
func custom_sort(a: Node2D, b: Node2D): #high = first
	return a.points > b.points
	
func spawn_voitures():
	var car = voitures.instantiate()
	car.position = Vector2(-400, 200)
	car.init()
	car.alive = true
	$Voitures.add_child(car)
	
func spawn(pos_x, pos_y, angle):
	var route = circuit_tourne.instantiate()
	route.x = pos_x
	route.y = pos_y
	route.rota = angle
	$Terrain.add_child(route)

