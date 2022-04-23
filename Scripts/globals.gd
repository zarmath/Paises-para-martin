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
	var file = File.new()
	if file.file_exists(path_local):
		print("YES")
		file.close()
	else:
		print("NO")
		#leo el json data
		file.open(path_local, File.WRITE)
		file.store_string(JSON.print(json_data, "  ", true))
		file.close()


#almacena en la variable json_data los valores del json
#que hace de diccionario
func leer_json():
	#archivo = "user://" + str(archivo)
	#print("el archivo a leeer es: ",archivo)
	var file_read = File.new()
	file_read.open(path, File.READ)
	var content =  JSON.parse(file_read.get_as_text())    
	file_read.close()
	json_data = content.result

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
	var file_read = File.new()
	file_read.open(archivo, File.READ)
	var content =  JSON.parse(file_read.get_as_text())    
	file_read.close()
	json_data_total = content.result
	

func cambiarEscena(nuevaEscena) -> void:
	var error = get_tree().change_scene(nuevaEscena)
	if error != OK:
		print("no se ha cargado la escena")


func crearTemporizador(tiempo:float) -> void:
	var timer = Timer.new()
	timer.autostart = true
	timer.one_shot = false
	timer.wait_time = tiempo
	timer.connect("timeout", self, "finalizarTimer")
	add_child(timer)


func finalizarTimer() -> void:
	emit_signal("timerFinalizado")
