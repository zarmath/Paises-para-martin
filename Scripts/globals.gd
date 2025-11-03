extends Node

var path = "res://Data/listado_paises.json"
var path_xml = "res://Data/listado_paises.xml"
var path_local = "user://data.json"
var json_data
var json_data_total
var xml_data
var pantallaTamano
var marcoPantalla
signal timerFinalizado

func _ready():
	#leer_json()
	#leer_json_inicio()
	#comprobar_si_existe_json()
	marcoPantalla = 15
	pass


#con los datos del json data
func comprobar_si_existe_json():
	if FileAccess.file_exists(path_local):
		print("YES")
	else:
		print("NO")
		#leo el json data
		var file := FileAccess.open(path_local, FileAccess.WRITE)
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
	var file_read := FileAccess.open(path, FileAccess.READ)
	if file_read == null:
		push_error("No se ha podido abrir %s" % path)
		return
	var test_json_conv := JSON.new()
	var parse_error := test_json_conv.parse(file_read.get_as_text())
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
	var file_read := FileAccess.open(archivo, FileAccess.READ)
	if file_read == null:
		push_error("No se ha podido abrir %s" % archivo)
		return
	var test_json_conv := JSON.new()
	var parse_error := test_json_conv.parse(file_read.get_as_text())
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
	var timer = Timer.new()
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = tiempo
	timer.timeout.connect(finalizarTimer)
	add_child(timer)


func finalizarTimer() -> void:
	emit_signal("timerFinalizado")
