extends Area2D


func _on_area_entered(area):
	if "Voiture" in area.name:
		area.get_parent().get_parent().alive = false
		#area.get_parent().get_parent().hide()
