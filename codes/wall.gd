extends Area2D

func _on_area_entered(area):
	"""
	Quand quelque chose rentre dans la boite de collision, si c'est une voiture :
		l'arrêter et la rendre transparente
	"""
	if "Voiture" in area.name:
		area.get_parent().alive = false
		area.get_parent().modulate.a = 0.2 # modifie l'opacité
