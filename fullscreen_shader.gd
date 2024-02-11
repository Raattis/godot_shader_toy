extends TextureRect

func _process(_delta):
	var res = get_viewport_rect().size
	rect_position = get_viewport_rect().position
	rect_size = res
	material.set_shader_param("width_by_height", res.x / res.y)
