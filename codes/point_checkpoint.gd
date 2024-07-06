extends Area2D

# Quand quelque chose entre dans la boite de collision et que c'est une voiture, lui ajouter un point 
func _on_area_entered(area: Area2D):
	if "Voiture" in area.name:
		var parent = area.get_parent() # récupère l'objet de la voiture à partir de sa boite de collision
		parent.points += 1
