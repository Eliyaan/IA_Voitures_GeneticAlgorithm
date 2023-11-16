extends Node2D
#var deplac: Vector2 = Vector2(0, 0)
var points: float = 0
var nb = 0
var ray_rota_arrays: Array = []
#var rot_change = 0
var rays_querries: Array = []
var space_state
var input: Array = []
var alive = false
var vel = Vector2.ZERO
var nn = {
	#Consts
	"nb_inputs" = 6,
	"nb_hidden_layer" = 1,
	"nb_hidden_neurones" = [8],
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
	init()
	space_state = get_world_2d().direct_space_state
	for n in range(5):
		ray_rota_arrays.append(deg_to_rad(n*45 - 90))
		rays_querries.append(PhysicsRayQueryParameters2D.create(global_position, global_position, 0b10))

func raycast():
	var nn_array = []
	for n in range(5):
		rays_querries[n].set_to(global_position + Vector2(0, -400).rotated(ray_rota_arrays[n] + $RB.rotation))
		rays_querries[n].set_from(global_position)
		var result = space_state.intersect_ray(rays_querries[n])  # coords of touch = result.position
		if result:
			nn_array.append(300 - global_transform.origin.distance_to(result.position))
		else:
			nn_array.append(0)
	return nn_array
	
func _physics_process(_delta):
	if alive:
		modulate.a = 1
		var nn_array = raycast()
		nn_array.append($RB.linear_velocity.length())
		input = nn_array.duplicate(true)
		var result = fprop(nn_array)
		vel = (Vector2(0, -result[0]).rotated($RB.rotation)*2000000)/50 + vel*49/50
		$RB.apply_central_force(vel)
		$RB.apply_torque_impulse((result[1]*2-1)*100*$RB.linear_velocity.length())
		#$RB.rotation += (result[1]*0.003*$RB.linear_velocity.length())
		#var truc = $RB.constant_torque
		#$RB.constant_torque = (result[1]*200000)
		#print(str(truc) + " " + str($RB.constant_torque))
		#print($RB.constant_torque)

func stop():
	alive = false
	$RB.constant_torque = 0
	$RB.reset = true
	
func restart():
	alive = true



func _on_rb_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if "Terrain" in body.get_parent().name:
		#alive = false
		#$RB.apply_central_force(-$RB.linear_velocity*1)
		vel = Vector2.ZERO
		points *= 0.9

