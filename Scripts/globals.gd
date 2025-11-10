extends Node

var path: String = "res://Data/listado_paises.json"
var path_xml: String = "res://Data/listado_paises.xml"
var path_local: String = "user://data.json"
var json_data: Variant = null
var json_data_total: Variant = null
var xml_data: Variant = null
var pantallaTamano: Vector2 = Vector2.ZERO
var marcoPantalla: int = 0
var background_color: Color = Color("#171555")
signal timerFinalizado

func _ready():
	#leer_json()
	#leer_json_inicio()
	#comprobar_si_existe_json()
	marcoPantalla = 15
	apply_background_color()
	actualizar_tamano_pantalla()
	var root_window: Window = get_tree().root
	if root_window:
		root_window.size_changed.connect(_on_root_size_changed)
	pass


func actualizar_tamano_pantalla(viewport: Viewport = null) -> void:
	var target_viewport: Viewport = viewport if viewport != null else get_viewport()
	if target_viewport:
		var visible_size: Vector2 = target_viewport.get_visible_rect().size
		if visible_size != Vector2.ZERO:
			pantallaTamano = visible_size
			return
	var window_id: int = DisplayServer.INVALID_WINDOW_ID
	if DisplayServer.has_method("window_get_main_id"):
		window_id = DisplayServer.call("window_get_main_id")
	elif DisplayServer.has_method("window_get_window_list"):
		var window_list: Variant = DisplayServer.call("window_get_window_list")
		if window_list is PackedInt64Array and window_list.size() > 0:
			window_id = window_list[0]
	if window_id != DisplayServer.INVALID_WINDOW_ID and DisplayServer.has_method("window_get_size"):
		var size: Variant = DisplayServer.call("window_get_size", window_id)
		if size is Vector2i and size != Vector2i.ZERO:
			pantallaTamano = size


func _on_root_size_changed() -> void:
	actualizar_tamano_pantalla()


#con los datos del json data
func comprobar_si_existe_json():
	if FileAccess.file_exists(path_local):
		print("YES")
	else:
		print("NO")
		#leo el json data
		var file: FileAccess = FileAccess.open(path_local, FileAccess.WRITE)
		if file == null:
			push_error("No se ha podido crear el archivo local en %s" % path_local)
			return
		file.store_string(JSON.stringify(json_data, "  ", true))
		file.close()


#almacena en la variable json_data los valores del json
#que hace de diccionario
func leer_json():
	#archivo = "user://" + str(archivo)
	#print("el archivo a leeer es: ",archivo)
	var file_read: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file_read == null:
		push_error("No se ha podido abrir %s" % path)
		return
	var test_json_conv: JSON = JSON.new()
	var parse_error: int = test_json_conv.parse(file_read.get_as_text())
	file_read.close()
	if parse_error != OK:
		push_error("Error al parsear JSON en %s: %s" % [path, test_json_conv.get_error_message()])
		return
	json_data = test_json_conv.data

#creoq eu se puede borrar porque redundante cone l anterior
func leer_xml():
	var file = XMLParser.new()
	file.open(path_xml)
	#file.read()
	var content =  file.read()
	#file.close()
	xml_data = content

func leer_json_total(archivo):
	archivo = "res://Data/" + str(archivo) + ".json"
	var file_read: FileAccess = FileAccess.open(archivo, FileAccess.READ)
	if file_read == null:
		push_error("No se ha podido abrir %s" % archivo)
		return
	var test_json_conv: JSON = JSON.new()
	var parse_error: int = test_json_conv.parse(file_read.get_as_text())
	file_read.close()
	if parse_error != OK:
		push_error("Error al parsear JSON en %s: %s" % [archivo, test_json_conv.get_error_message()])
		return
	json_data_total = test_json_conv.data


func cambiarEscena(nuevaEscena) -> void:
	var error = get_tree().change_scene_to_file(nuevaEscena)
	if error != OK:
		print("no se ha cargado la escena")


func crearTemporizador(tiempo:float) -> void:
	var timer: Timer = Timer.new()
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = tiempo
	timer.timeout.connect(finalizarTimer)
	add_child(timer)


func finalizarTimer() -> void:
	emit_signal("timerFinalizado")


func apply_background_color() -> void:
	RenderingServer.set_default_clear_color(background_color)
