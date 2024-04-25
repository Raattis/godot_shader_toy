extends TextureRect

func _process(_delta):
	var res = get_viewport_rect().size
	rect_position = get_viewport_rect().position
	rect_size = res
	material.set_shader_param("ox", $"../utf8/mouse_hover".ox_i)
	material.set_shader_param("oy", $"../utf8/mouse_hover".oy_i)
	material.set_shader_param("sx", $"../utf8/mouse_hover".sx_i)
	material.set_shader_param("sy", $"../utf8/mouse_hover".sy_i)
	material.set_shader_param("px", $"../utf8/mouse_hover".px)
	material.set_shader_param("py", $"../utf8/mouse_hover".py)
	material.set_shader_param("width_by_height", get_viewport_rect().size.x / get_viewport_rect().size.y)
