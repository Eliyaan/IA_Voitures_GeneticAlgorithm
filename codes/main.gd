extends Node2D
@export var voitures : PackedScene
@export var neuron_prefab : PackedScene
@export var new_line : PackedScene
var steps: int = 0
var nb_voitures: int = 200
var nb_offsprings: int = 20
var running: bool = false
var sim_steps: int = 450
var muta: float = 0.5
var recovery_frames: int = 1
var sorted_array: Array = []
var first_gen: bool = true
var neurons_pos_list = []
var h_spacing = 80
var v_spacing = 55

# Called when the node enters the scene tree for the first time.
func _ready():
	#Gen voitures
	for _voiture in range(0, nb_voitures):
		spawn_voitures()
	var car = $Voitures.get_child(0)
	var c = 0
	neurons_pos_list.append([])
	for input in car.nn['nb_inputs']:
		var neuron = neuron_prefab.instantiate()
		neuron.position = Vector2(400, -250+c*v_spacing)
		neurons_pos_list[0].append(Vector2(400, -250+c*v_spacing))
		$Neurons.add_child(neuron)
		var bg_neuron = neuron_prefab.instantiate()
		bg_neuron.position = Vector2(400, -250+c*v_spacing)
		$NeurBkgd.add_child(bg_neuron)
		c += 1
	
	var d = 1
	var last_lay_nb = 0
	for layer in car.nn["nb_hidden_neurones"]:
		c = 0
		neurons_pos_list.append([])
		for n in range(0, layer):
			var neuron = neuron_prefab.instantiate()
			neuron.position = Vector2(400 + d*h_spacing , -250+(c+(car.nn['nb_inputs']-layer)/2.0)*v_spacing)
			neurons_pos_list[d].append(Vector2(400 + d*h_spacing , -250+(c+(car.nn['nb_inputs']-layer)/2.0)*v_spacing))
			$Neurons.add_child(neuron)
			var bg_neuron = neuron_prefab.instantiate()
			bg_neuron.position = Vector2(400 + d*h_spacing , -250+(c+(car.nn['nb_inputs']-layer)/2.0)*v_spacing)
			$NeurBkgd.add_child(bg_neuron)
			c += 1
			last_lay_nb = layer
		d += 1
	c = 0
	neurons_pos_list.append([])
	for input in car.nn['nb_outputs']:
		var neuron = neuron_prefab.instantiate()
		neuron.position = Vector2(400 + d*h_spacing, -250+(c+(car.nn['nb_inputs']-car.nn['nb_outputs'])/2.0)*v_spacing)
		neurons_pos_list[d].append(Vector2(400 + d*h_spacing , -250+(c+(car.nn['nb_inputs']-car.nn['nb_outputs'])/2.0)*v_spacing))
		$Neurons.add_child(neuron)
		var bg_neuron = neuron_prefab.instantiate()
		bg_neuron.position = Vector2(400 + d*h_spacing , -250+(c+(car.nn['nb_inputs']-car.nn['nb_outputs'])/2.0)*v_spacing)
		$NeurBkgd.add_child(bg_neuron)
		c += 1
	#Lines
	for i in range(0, neurons_pos_list.size()-1):
		for coo in neurons_pos_list[i]:
			for sec_coo in neurons_pos_list[i+1]:
				var line = new_line.instantiate()
				line.points[0] = coo
				line.points[1] = sec_coo
				$Lines.add_child(line)
	running = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if running:
		steps += 1
		if !first_gen:
			var car = sorted_array[0]
			var c = 0
			for input in car.nn['nb_inputs']:
				var n = $Neurons.get_child(c)
				if car.input[c] > 0:
					n.modulate.r = 0
					n.modulate.g = 0.88
					n.modulate.b = 0.34
					n.scale.x = (car.sigmoid(car.input[c]/100))*0.104+0.001
					n.scale.y = n.scale.x
				else:
					n.modulate.r = 1
					n.modulate.g = 0.16
					n.modulate.b = 0.14
					n.scale.x = (car.sigmoid(-car.input[c]/5))*0.104+0.001  # the 5 is a special case but for other project use 2 times the same div
					n.scale.y = n.scale.x
				c += 1
			var d = 0
			for layer in car.nn["nb_hidden_neurones"]:
				for nb in range(0, layer):
					var n = $Neurons.get_child(c)
					n.modulate.r = 0
					n.modulate.g = 0.88
					n.modulate.b = 0.34
					n.scale.x = car.nn["layers_list"][d][1][nb]*0.104+0.001
					n.scale.y = n.scale.x
					c += 1
				d += 1
			for input in car.nn['nb_outputs']:
				var n = $Neurons.get_child(c)
				n.modulate.r = 0
				n.modulate.g = 0.88
				n.modulate.b = 0.34
				n.scale.x = car.nn["layers_list"][d][1][input]*0.104+0.001
				n.scale.y = n.scale.x
				c += 1
			var e = 0
			for i in range(car.nn["weights_list"].size()):
				for j in range(car.nn["weights_list"][i].size()):
					for k in range(car.nn["weights_list"][i][j].size()):
						var l = $Lines.get_child(e)
						if car.nn["weights_list"][i][j][k] > 0:
							l.modulate.r = 0
							l.modulate.g = 0.88
							l.modulate.b = 0.34
							l.width = ((car.sigmoid(car.nn["weights_list"][i][j][k]))*6)+0.1
						else:
							l.modulate.r = 1
							l.modulate.g = 0.16
							l.modulate.b = 0.14
							l.width = ((car.sigmoid(-car.nn["weights_list"][i][j][k]))*6)+0.1
						e += 1
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
		first_gen = false
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

