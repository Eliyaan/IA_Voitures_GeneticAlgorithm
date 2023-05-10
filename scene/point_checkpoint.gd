extends Area2D



func _on_area_entered(area):
	if "Voiture" in area.name:
		if area.get_parent().get_parent().get_parent().points%10 == get_index()%10:
			area.get_parent().get_parent().get_parent().points += 1
