extends Area2D

func _on_area_entered(area: Area2D):
	if "Voiture" in area.name:
		var parent = area.get_parent().get_parent()
		if parent.points%10 == get_index()%10:
			parent.points += 1
