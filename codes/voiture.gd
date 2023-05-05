extends Node2D
var deplac = Vector2(0, 0)
var nn = {
	#Consts
	"nb_inputs" = 9,
	"nb_hidden_layer" = 1,
	"nb_hidden_neurones" = [4],
	"nb_outputs" = 2,
	"mutation_rate" = 0.3,

	"weights_list" = [[[[]]]],
	"layers_list"  = [[[]]],  # bias, output(activ)

	"inputs" = [[]], 
	"excpd_outputs" = [[]], # first : prob for 0 ; sec : prob for 1
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
		
func sigmoid(value):
	return 1 / (1 +  2.71828**(-value))

func fprop(inputs):
	for i in range(nn["layers_list"].size()):
		for j in range(nn["layers_list"][i][0].size()): #the 0 is to get the size of the layer 
			var nactiv = 0
			if i == 0:
				for k in range(inputs.size()):  # Pour chaque input
					nactiv += nn["weights_list"][i][j][k] * inputs[k] #Le bon weight fois le bon input
			else:
				for k in range(nn["layers_list"][i-1][0].size()):  # Pour chaque input pareil pour le 0 cette fois aussi
					nactiv += nn["weights_list"][i][j][k] * nn["layers_list"][i-1][1][k] #Le bon weight fois le bon output de la layer d'avant	
			nactiv += nn["layers_list"][i][0][j]  # Ajout du bias
			nn["layers_list"][i][1][j] = sigmoid(nactiv)  #activation function
	return nn["layers_list"][nn["nb_hidden_layer"]][1]
	
func reset(): 
	#reset outputs
	for i in range(nn["layers_list"].size()):
		nn["layers_list"][i][1] = []
		nn["layers_list"][i][1].resize(nn["nb_outputs"] if i == nn["nb_hidden_layer"] else nn["nb_hidden_neurones"][i])			
		
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
			for j in nn["weights_list"][i]:
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

# Called when the node enters the scene tree for the first time.
func _ready():
	init()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Controler/RayCast2D.force_raycast_update()
	if $Controler/RayCast2D.is_colliding():
		print($Controler/RayCast2D.get_collision_point())
	var result = think([0.9, 0.1, -1, 0.3, 0.5, 0.4, 0.1, 1.2, -0.8])
	deplac.y -= result[0]*2 - 1
	if deplac.y > 0: 
		deplac.y = 0
	rotation_degrees += (result[1]*2 - 1) * deplac.y * 0.08  # le 0.1 c'est un facteur changeable selon si on veut qu'elle tourne plus vite ou pas
	var changement = Vector2(deplac.rotated(rotation))
	position.x += changement.x/10  # le 10 est à quel point la voiture va être ralentie, facteur changeable
	position.y += changement.y/10 

func think(inputs):
	reset()
	return fprop(inputs)
	
