extends Spatial 


func get_all_neighbors(var height):
	var objects = []
	for ray in $Neighbors.get_children():
		var obj = ray.get_collider()
		if obj and abs(obj.get_translation().y-get_parent().get_translation().y) <= height:
			objects.append(obj)
	return objects

	
func get_object_above():
	return $Above.get_collider()
