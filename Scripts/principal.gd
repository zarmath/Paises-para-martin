extends Node2D

var pais
var numPaises
var capital
var exito = false
var intentos
var aciertos 
var estilo_respuesta = StyleBoxFlat.new()
var capitalCorrecta = false
var capitalError
var opcion

func _get_capital(entry) -> String:
	if not (entry is Dictionary):
		return ""
	var capital_list = entry.get("capital", [])
	if capital_list is Array and not capital_list.is_empty():
		return str(capital_list[0])
	return ""

func _ready():
	Globals.leer_json_total("data")
	RenderingServer.set_default_clear_color(Color("#171555"))
	intentos = 1
	aciertos = 0
	numPaises = Globals.json_data_total.size() - 1
	#numPaises = 249
	#tamaños
	$margin.size.x = Globals.pantallaTamano.x
	$margin/horizontal.size.x = Globals.pantallaTamano.x
	$margin/horizontal/container/marginPais.size.x = Globals.pantallaTamano.x - 250
	$margin/horizontal/contenedorNombreCompleto.size.x = Globals.pantallaTamano.x
	$marginMarcador.size.x = Globals.pantallaTamano.x
	$marginSiguiente.size.x = Globals.pantallaTamano.x
	$marginMarcador.size.y = 70
	$marginMarcador/panelMarcador.size.y = 70
	$marginSiguiente.size.y = 70
	$marginSiguiente.custom_minimum_size.y = 70
	$marginSiguiente/siguiente.size.y = 70
	$marginSiguiente/siguiente.custom_minimum_size.y = 70
	#posiciones
	$publicidad.position.x = Globals.marcoPantalla
	$publicidad.position.y = Globals.pantallaTamano.y - 110
	$marginMarcador.position.y = Globals.pantallaTamano.y - 270
	$marginSiguiente.position.y = Globals.pantallaTamano.y - 200
	$margin/horizontal/container/marginBandera.custom_minimum_size.x = 250
	$marginMarcador/marcador.text = "0/0"
	pais_al_azar()


func pais_al_azar():
	#escondo el resultado
	$margin/horizontal/contenedorResultado.hide()
	$marginSiguiente/siguiente.hide()
	randomize()
	#var cantidadPaises = Globals.json_data_total.size()
	#print(cantidadPaises)
	var pos = randi() %numPaises +1 
	capital = _get_capital(Globals.json_data_total[pos])
	if capital.length() > 0:
		var opcionCorrecta = randi() % 4 + 1
		#busco 3 opciones
		for n in range (1,5):
			if n == 1:
				if n == opcionCorrecta:
					$margin/horizontal/contenedorBotones/grid/opcion1.text = capital
				else:
					comprobar_capital()
					$margin/horizontal/contenedorBotones/grid/opcion1.text = capitalError
			if n == 2:
				if n == opcionCorrecta:
					$margin/horizontal/contenedorBotones/grid/opcion2.text = capital
				else:
					comprobar_capital()
					$margin/horizontal/contenedorBotones/grid/opcion2.text = capitalError
			if n == 3:
				if n == opcionCorrecta:
					$margin/horizontal/contenedorBotones/grid/opcion3.text = capital
				else:
					comprobar_capital()
					$margin/horizontal/contenedorBotones/grid/opcion3.text = capitalError
			if n == 4:
				if n == opcionCorrecta:
					$margin/horizontal/contenedorBotones/grid/opcion4.text = capital
				else:
					comprobar_capital()
					$margin/horizontal/contenedorBotones/grid/opcion4.text = capitalError
		#print(capital1,capital2,capital3)
		var cadPais = "res://png250px/" + str(Globals.json_data_total[pos]["cca2"]).to_lower() + ".png"
		#compruebo la longitud del nombre del pais
		"""
		var longitudNombrePais = str(Globals.json_data_total[pos]["translations"]["spa"]["common"]).length()
		var font = $margin/horizontal/container/margin/pais.get_font("string_name", "")
		if longitudNombrePais < 20:
			font.size = 60
		if longitudNombrePais > 19 && longitudNombrePais < 40:
			font.size = 40
		if longitudNombrePais > 39:
			font.size = 30
		"""
		#print("el tamaño de la fuente es:",font.size,"|",longitudNombrePais)
		$margin/horizontal/container/marginPais/pais.text = str(Globals.json_data_total[pos]["translations"]["spa"]["common"])
		$margin/horizontal/container/marginBandera/bandera.texture = load(cadPais)
		$margin/horizontal/contenedorResultado/resultado.text = capital
		$margin/horizontal/contenedorNombreCompleto/nombreCompleto.text = str(Globals.json_data_total[pos]["name"]["official"])
		var informacion = tr("region") + ": " + str(Globals.json_data_total[pos]["region"]) + "/" + str(Globals.json_data_total[pos]["subregion"])
		#compruebo las monedas
		var nombreMoneda = ""
		var simboloMoneda = ""
		var monedas
		for tipoMonedas in Globals.json_data_total[pos]["currencies"]:
			nombreMoneda = Globals.json_data_total[pos]["currencies"][tipoMonedas]["name"]
			simboloMoneda = Globals.json_data_total[pos]["currencies"][tipoMonedas]["symbol"]
		monedas =  nombreMoneda + "/" + simboloMoneda
		informacion += "\n" + tr("moneda") + monedas
		#compruebo los idiomas
		var todosIdiomas = ""
		var i = 0
		for idiomas in Globals.json_data_total[pos]["languages"]:
			if i != 0:
				todosIdiomas += Globals.json_data_total[pos]["languages"][idiomas] + ", "
			else:
				todosIdiomas += Globals.json_data_total[pos]["languages"][idiomas] 
			i += 1
		informacion += "\n" + tr("idiomas") + ": " + todosIdiomas
		informacion += "\n" + tr("fronteras") + ": " + str(Globals.json_data_total[pos]["borders"])
		#informacion += "\n" + "Gentilicio:" + str(Globals.json_data_total[pos]["demonyms"])
		$margin/horizontal/contenedorInformacion/informacion.text = informacion
	else:
		pais_al_azar()
		#pass




func _on_Button_pressed():
	pais_al_azar()
	activar_botones()
	$marginMarcador/marcador.text = str(aciertos) + "/" + str(intentos)
	intentos += 1


func _on_opcion1_pressed():
	if $margin/horizontal/contenedorBotones/grid/opcion1.text == capital:
		exito = true
	else:
		exito = false
	comprobar_resultado()
	desactivar_botones()
		


func _on_opcion2_pressed():
	if $margin/horizontal/contenedorBotones/grid/opcion2.text == capital:
		exito = true
	else:
		exito = false
	comprobar_resultado()
	desactivar_botones()


func _on_opcion3_pressed():
	if $margin/horizontal/contenedorBotones/grid/opcion3.text == capital:
		exito = true
	else:
		exito = false
	comprobar_resultado()
	desactivar_botones()


func _on_opcion4_pressed():
	if $margin/horizontal/contenedorBotones/grid/opcion4.text == capital:
		exito = true
	else:
		exito = false
	comprobar_resultado()
	desactivar_botones()

func comprobar_resultado():
	$margin/horizontal/contenedorResultado.show()
	$marginSiguiente/siguiente.show()
	var estilo = load("res://Art/error.tres")
	if exito:
		#$margin/horizontal/contenedorCapital.col
		$margin/horizontal/contenedorResultado/resultado.text = "CORRECTO¡¡¡ La capital es: " + capital
		#$margin/horizontal/contenedorCapital.get_stylebox("error", "" ).set_bg_color("#31d774")
		#estilo_respuesta.set_bg_color("#31d774")
		#set(get_node("margin/horizontal/contenedorCapital"),estilo_respuesta)
		estilo.bg_color = Color("#1EB100")
		aciertos += 1
	else:
		$margin/horizontal/contenedorResultado/resultado.text = "ERROR, La capital es: " + capital
		#$margin/horizontal/contenedorCapital.get_stylebox("error", "" ).set_bg_color("#d73137")
		#estilo_respuesta.set_bg_color("#d73137")
		estilo.bg_color = Color("#ED230D")
	$marginMarcador/marcador.text = str(aciertos) + "/" + str(intentos)

func desactivar_botones():
	$margin/horizontal/contenedorBotones/grid/opcion1.disabled = true
	$margin/horizontal/contenedorBotones/grid/opcion2.disabled = true
	$margin/horizontal/contenedorBotones/grid/opcion3.disabled = true
	$margin/horizontal/contenedorBotones/grid/opcion4.disabled = true
	$margin/horizontal/contenedorBotones.hide()

func activar_botones():
	$margin/horizontal/contenedorBotones/grid/opcion1.disabled = false
	$margin/horizontal/contenedorBotones/grid/opcion2.disabled = false
	$margin/horizontal/contenedorBotones/grid/opcion3.disabled = false
	$margin/horizontal/contenedorBotones/grid/opcion4.disabled = false
	$margin/horizontal/contenedorBotones.show()

func comprobar_capital():
	capitalCorrecta = false
	#print("entro en la comprobación:",capitalCorrecta)
	while capitalCorrecta == false:
		#print("entro en el bucle:",capitalCorrecta)
		randomize()
		opcion = randi() % numPaises + 1
		#print ("la opción es:",opcion)
		capitalError = _get_capital(Globals.json_data_total[opcion])
		if capitalError.length() > 0:
			capitalCorrecta = true
		else:
			capitalCorrecta = false
	#print("estoy fuera de la comprobación:",capitalCorrecta,"|",capitalError)
	return(capitalError)
