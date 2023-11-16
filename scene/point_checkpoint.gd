extends Area2D

func _on_area_entered(area: Area2D):
	if "Voiture" in area.name:
		var parent = area.get_parent().get_parent()
		if parent.points%10 == get_index()%10:
			parent.points += 1


func _on_body_entered(body):
	var parent = body.get_parent()
	if "RB" in body.name:
		if parent.nb%40 == get_index()%40:
			parent.points += 1.0
			parent.nb += 1
#			print(parent.points)

