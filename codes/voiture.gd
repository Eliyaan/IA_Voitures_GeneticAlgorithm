extends Node2D
var deplac: Vector2 = Vector2(0, 0)
var alive: bool = false
var points: int = 0
var rota_array: Array = []
var rot_change = 0
var rays_querries: Array = []
var space_state
var input: Array = []
var nn = {
	#Consts
	"nb_inputs" = 6,
	"nb_hidden_layer" = 1,
	"nb_hidden_neurones" = [5],
	"nb_outputs" = 2,

	"weights_list" = [[[[]]]],
	"layers_list"  = [[[]]],  # [][bias, output(activ)][]
}

func set_rd_wb_values():
	#Weights
	for i in range(nn["weights_list"].size()):
		for j in range(nn["weights_list"][i].size()):
			for k in range(nn["weights_list"][i][j].size()):
				nn["weights_list"][i][j][k] = randf_range(-1, 1)
	#Biases 
	for i in range(nn["layers_list"].size()):
		for j in range(nn["layers_list"][i][0].size()):
			nn["layers_list"][i][0][j] = randf_range(-1, 1)
		
func sigmoid(value: float):
	return 1 / (1 +  2.718**(-value))

func fprop(inputs: Array):
	var nactiv = 0
	for i in range(nn["layers_list"].size()):
		for j in range(nn["layers_list"][i][0].size()): #the 0 is to get the size of the layer 
			nactiv = 0
			if i == 0:
				for k in range(inputs.size()):  # Pour chaque input
					nactiv += nn["weights_list"][i][j][k] * inputs[k] #Le bon weight fois le bon input
			else:
				for k in range(nn["layers_list"][i-1][0].size()):  # Pour chaque input pareil pour le 0 cette fois aussi
					nactiv += nn["weights_list"][i][j][k] * nn["layers_list"][i-1][1][k] #Le bon weight fois le bon output de la layer d'avant	
			nactiv += nn["layers_list"][i][0][j]  # Ajout du bias
			nn["layers_list"][i][1][j] = sigmoid(nactiv)  #activation function
	return nn["layers_list"][nn["nb_hidden_layer"]][1]
		
func init():
	#Init empty weights
	nn["weights_list"] = []
	nn["weights_list"].resize(nn["nb_hidden_layer"]+1)
	for i in range(nn["weights_list"].size()):
		nn["weights_list"][i] = [[]]
	#Init empty layers
	nn["layers_list"] = []
	nn["layers_list"].resize(nn["nb_hidden_layer"]+1)
	for i in range(nn["layers_list"].size()):
		nn["layers_list"][i] = [[], []]
	#Init wall the arrays with the specific sizes and all that
	for i in range(0, nn["nb_hidden_layer"]+1):
		if i == 0:
			nn["weights_list"][i].resize(nn["nb_hidden_neurones"][0])
			for j in range(nn["weights_list"][i].size()):
				nn["weights_list"][i][j] = []
				nn["weights_list"][i][j].resize(nn["nb_inputs"])
		elif i == nn["nb_hidden_layer"]:
			nn["weights_list"][i].resize(nn["nb_outputs"])
			for j in range(nn["weights_list"][i].size()):
				nn["weights_list"][i][j] = []
				nn["weights_list"][i][j].resize(nn["nb_hidden_neurones"][i-1])
		else:
			nn["weights_list"][i].resize(nn["nb_hidden_neurones"][i])
			for j in range(0, nn["weights_list"][i].size()):
				nn["weights_list"][i][j] = []
				nn["weights_list"][i][j].resize(nn["nb_hidden_neurones"][i-1])
	for i in range(0, nn["nb_hidden_layer"]+1):
		if i == nn["nb_hidden_layer"]:
			for j in range(nn["layers_list"][i].size()):
				nn["layers_list"][i][j].resize(nn["nb_outputs"])
		else:
			for j in range(nn["layers_list"][i].size()):
				nn["layers_list"][i][j].resize(nn["nb_hidden_neurones"][i])
	set_rd_wb_values()

func _ready():
	space_state = get_world_2d().direct_space_state
	for n in range(5):
		rota_array.append(deg_to_rad(n*45 - 90))
		rays_querries.append(PhysicsRayQueryParameters2D.create(global_position, global_position, 0b10))
		for ray in rays_querries:
			ray.set_collide_with_areas(true)

func raycast():
	var nn_array = []
	for n in range(5):
		rays_querries[n].set_to(global_position + Vector2(0, -300).rotated(rota_array[n] + rotation))
		rays_querries[n].set_from(global_position)
		var result = space_state.intersect_ray(rays_querries[n])  # coords of touch = result.position
		if result:
			nn_array.append(300 - global_transform.origin.distance_to(result.position))
		else:
			nn_array.append(0)
	return nn_array
	
func _process(_delta):
	if alive and get_parent().get_parent().running:
		var nn_array = raycast()
		nn_array.append(deplac.y)
		input = nn_array.duplicate(true)
		var result = fprop(nn_array)
		deplac.y -= (result[0]*2 - 1)*(0.6)
		if deplac.y > 0: 
			deplac.y = 0
		elif deplac.y < -20:
			deplac.y = -20
		rot_change = (rot_change/5)*4 + ((result[1]*2 - 1) * deplac.y * 0.5)/5  # le 0.5 c'est un facteur changeable selon si on veut qu'elle tourne plus vite ou pas
		rotation_degrees += rot_change
		position += deplac.rotated(rotation)
