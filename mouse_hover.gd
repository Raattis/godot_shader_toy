extends Node2D

var font : Font = preload("res://fonts/droid-sans/DroidSans.tres")

const base_sx := 65536.0
const base_sy := 65536.0
var ox := base_sx / 2.0
var oy := base_sy / 2.0
var sx := base_sx
var sy := base_sy

#var ox_i : int = 0
#var oy_i : int = 0
#var sx_i : int = 0
#var sy_i : int = 0
var ox_i : float = 0
var oy_i : float = 0
var sx_i : float = 0
var sy_i : float = 0

var px : int = 0
var py : int = 0

var target := Vector2(base_sx, base_sy) * 0.5
var zoom := 1.0

func _ready():
	font.set_size(16)
	Engine.set_target_fps(60)

func _process(delta:float ):
	var t := 1 - pow(0.001, delta)
	sx = lerp(sx, zoom * base_sx, t)
	sy = lerp(sy, zoom * base_sy, t)
	ox = lerp(ox, target.x, t)
	oy = lerp(oy, target.y, t)
	
	sx_i = (sx)
	sy_i = (sy)
	ox_i = (ox)
	oy_i = (oy)
	#sx_i = int(sx)
	#sy_i = int(sy)
	#ox_i = int(ox)
	#oy_i = int(oy)
	if focused && sleep_delay > 0:
		update() #queue_redraw()
	sleep_delay -= delta
	
var focused := true
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_FOCUS_OUT:
			focused = false
		NOTIFICATION_WM_FOCUS_IN:
			focused = true

var sleep_delay := 0.0
func _input(event):
	if event is InputEventMouseMotion:
		sleep_delay = 2.0
		if event.button_mask != 0:
			target -= event.relative / get_viewport_rect().size * Vector2(sx, sy)
			print(target)
			target.x = clamp(target.x, 0, base_sx-1)
			target.y = clamp(target.y, 0, base_sy-1)
	elif event is InputEventMouseButton:
		sleep_delay = 2.0
		if event.button_index == BUTTON_WHEEL_UP:
			zoom *= 0.9
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom = min(1.0, zoom * 1.1)

var w : int = 1 << 16
var error : int = 0x00ff0000

const text_y := 70
func _draw():
	var m := get_global_mouse_position()
	var uv : Vector2 = m / get_viewport_rect().size.y
	#print("%f -> %d" % [ox + uv.x * sx - sx * 0.5, int(ox + uv.x * sx - sx * 0.5)])
	var xx := ox + uv.x * sx - sx * 0.5 - 1
	var yy := oy + uv.y * sy - sy * 0.5 - 1
	var x := int(xx)
	var y := int(yy)
	px = x
	py = y
	var utf8: int = (x + y * w)
	var unicode = utf_8_to_unicode(utf8)
	draw_string(font, Vector2(5, 21), "bytes: 0x%08X" % utf8)
	draw_string(font, Vector2(160, 21), "cursor: %d, %d" % [x, y])
	#draw_string(font, Vector2(240, 21), "(mouse:%.0f, %.0f, view:%.04f, %.04f, pos:%.1f, %.1f)" % [m.x,m.y, uv.x, uv.y, xx, yy])
	#draw_string(font, Vector2(240, 37), "(s:%.1f, %.1f, o:%.1f, %.1f, is:%d,%d, io:%d,%d)" % [sx,sy, ox,oy, sx_i,sy_i, ox_i,oy_i])
	if unicode != error:
		draw_string(font, Vector2(105, text_y), " -> U+%04X (%d)" % [unicode, unicode])
			
		var c4 := utf8 & 0xff
		var c3 := (utf8 >> 8) & 0xff
		var c2 := (utf8 >> 16) & 0xff
		var c1 := (utf8 >> 24) & 0xff
		var s : String
		
		for i in range(1,5):
			var ar := [c1, c2, c3, c4]
			var arr := PoolByteArray()
			for ii in range(i):
				arr.push_back(ar[ii])
			s = arr.get_string_from_utf8()
			if s and s.length():
				print("U+%04X, %07d %s, '%s'" % [unicode, unicode, arr.hex_encode().to_upper(), s])
				draw_char(font, Vector2(105, text_y + 20), s, " ")
				break
	else:
		draw_string(font, Vector2(105, text_y), " -> error", Color(1,0,0,1))


func utf_8_to_unicode(utf8: int) -> int:
	# These don't have to be read immediately if we are worried about buffer overruns
	# Null-terminator stops any further progression
	var c4 :int= utf8 & 0xff
	var c3 :int= (utf8 >> 8) & 0xff
	var c2 :int= (utf8 >> 16) & 0xff
	var c1 :int= (utf8 >> 24) & 0xff
	draw_string(font, Vector2(5, text_y - 20), "utf-8 \"string\":", Color(1,1,1,0.8))
	draw_string(font, Vector2(5, text_y), "%02X" % [c1], Color(1,1,1,0.4))
	draw_string(font, Vector2(30, text_y), "%02X" % [c2], Color(1,1,1,0.4))
	draw_string(font, Vector2(55, text_y), "%02X" % [c3], Color(1,1,1,0.4))
	draw_string(font, Vector2(80, text_y), "%02X" % [c4], Color(1,1,1,0.4))

	if (c1 & 0b11000000) == 0b10000000:
		return error # continuation, error!
	draw_string(font, Vector2(5, text_y), "%02X" % [c1])
		
	if (c1 & 0b10000000) == 0b00000000:
		return c1 # ascii
		
	draw_string(font, Vector2(30, text_y), "%02X" % [c2])
	if c1 & 0b11100000 == 0b11000000:
		if c2 & 0b11000000 != 0b10000000:
			return error
		var result : int = (c1 & 0b00011111)
		result = (result << 6) + (c2 & 0b00111111)
		return result # 2 bytes

	draw_string(font, Vector2(55, text_y), "%02X" % [c3])
	if c1 & 0b11110000 == 0b11100000:
		if c2 & 0b11000000 != 0b10000000 or c3 & 0b11000000 != 0b10000000:
			return error
		var result : int = (c1 & 0b00001111)
		result = (result << 6) + (c2 & 0b00111111)
		result = (result << 6) + (c3 & 0b00111111)
		return result # 3 bytes

	draw_string(font, Vector2(80, text_y), "%02X" % [c4])
	if c1 & 0b11111000 == 0b11110000:
		if c2 & 0b11000000 != 0b10000000 or c3 & 0b11000000 != 0b10000000 or c4 & 0b11000000 != 0b10000000:
			return error
		var result : int = (c1 & 0b00000111)
		result = (result << 6) + (c2 & 0b00111111)
		result = (result << 6) + (c3 & 0b00111111)
		result = (result << 6) + (c4 & 0b00111111)
		return result # 4 bytes

	return error
