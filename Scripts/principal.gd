extends Node2D

var pais_actual = {}
var paises_array = []
var numPaises
var capital
var exito = false
var intentos
var aciertos 
var estilo_respuesta = StyleBoxFlat.new()
var capitalCorrecta = false
var capitalError
var opcion
var device_in_spanish = false
@onready var _pais_container: PanelContainer = $margin/horizontal/container/marginPais
@onready var _pais_label: Label = $margin/horizontal/container/marginPais/pais
@onready var _full_name_container: PanelContainer = $margin/horizontal/contenedorNombreCompleto
@onready var _full_name_label: Label = $margin/horizontal/contenedorNombreCompleto/nombreCompleto
var _pais_font_base_size := 53
var _full_name_font_base_size := 42
const PAIS_FONT_MIN_SIZE := 26
const FULL_NAME_FONT_MIN_SIZE := 22
const FONT_SIZE_STEP := 2

func _format_population(value):
	var digits := ""
	var value_type := typeof(value)
	var is_negative := false
	if value_type == TYPE_INT:
		var int_value: int = value
		is_negative = int_value < 0
		digits = str(abs(int_value))
	elif value_type == TYPE_FLOAT:
		var float_value: float = value
		is_negative = float_value < 0.0
		digits = str(abs(int(float_value)))
	else:
		var pop_text := str(value)
		for char in pop_text:
			if "0123456789".find(char) != -1:
				digits += char
	if digits == "":
		return str(value)
	var formatted := ""
	var count := 0
	for i in range(digits.length() - 1, -1, -1):
		formatted = digits.substr(i, 1) + formatted
		count += 1
		if count == 3 and i != 0:
			formatted = "." + formatted
			count = 0
	if is_negative:
		formatted = "-" + formatted
	return formatted

func _get_label_font_size(label: Label, fallback: int) -> int:
	if label == null:
		return fallback
	var detected_size := label.get_theme_font_size("font_size")
	if detected_size <= 0:
		return fallback
	return detected_size

func _fit_label_to_available_width(label: Label, base_size: int, min_size: int, step: int, max_width: float) -> void:
	if label == null:
		return
	var font := label.get_theme_font("font")
	if font == null or max_width <= 0.0:
		label.add_theme_font_size_override("font_size", base_size)
		label.reset_size()
		return
	var text := label.text.strip_edges()
	if text == "":
		label.remove_theme_font_size_override("font_size")
		label.reset_size()
		return
	var font_size := base_size
	var safe_min_size: int = max(min_size, 8)
	while font_size > safe_min_size:
		var measure: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
		if measure <= max_width:
			break
		font_size -= step
	if font_size < safe_min_size:
		font_size = safe_min_size
	label.add_theme_font_size_override("font_size", font_size)
	label.reset_size()

func _update_country_labels_layout() -> void:
	if _pais_label != null and _pais_container != null:
		var pais_width := _pais_container.size.x
		if pais_width <= 0.0 and Globals.pantallaTamano != null:
			pais_width = Globals.pantallaTamano.x - 250.0
		_fit_label_to_available_width(_pais_label, _pais_font_base_size, PAIS_FONT_MIN_SIZE, FONT_SIZE_STEP, pais_width)
	if _full_name_label != null and _full_name_container != null:
		var nombre_width := _full_name_container.size.x
		if nombre_width <= 0.0 and Globals.pantallaTamano != null:
			nombre_width = Globals.pantallaTamano.x
		_fit_label_to_available_width(_full_name_label, _full_name_font_base_size, FULL_NAME_FONT_MIN_SIZE, FONT_SIZE_STEP, nombre_width)

func _get_capital(entry) -> String:
	if not (entry is Dictionary):
		return ""
	var capital_value = entry.get("capital", [])
	if capital_value is Array and not capital_value.is_empty():
		return str(capital_value[0])
	if capital_value is String:
		return capital_value.strip_edges()
	return ""

func _ready():
	Globals.leer_json_total("paises_unidos")
	if Globals.json_data_total is Dictionary:
		paises_array = Globals.json_data_total.values()
	elif Globals.json_data_total is Array:
		paises_array = Globals.json_data_total.duplicate()
	else:
		paises_array = []
	paises_array = paises_array.filter(func(item): return item is Dictionary)
	numPaises = paises_array.size()
	var locale_code = OS.get_locale()
	if typeof(locale_code) == TYPE_STRING:
		device_in_spanish = locale_code.to_lower().begins_with("es")
	RenderingServer.set_default_clear_color(Color("#171555"))
	intentos = 1
	aciertos = 0
	#numPaises = 249
	#tamaños
	$margin.size.x = Globals.pantallaTamano.x
	$margin/horizontal.size.x = Globals.pantallaTamano.x
	if _pais_container != null:
		_pais_container.size.x = Globals.pantallaTamano.x - 250
	if _full_name_container != null:
		_full_name_container.size.x = Globals.pantallaTamano.x
	$marginMarcador.size.x = Globals.pantallaTamano.x
	$marginSiguiente.size.x = Globals.pantallaTamano.x
	$marginMarcador.size.y = 70
	$marginMarcador/panelMarcador.size.y = 70
	$marginSiguiente.size.y = 70
	$marginSiguiente.custom_minimum_size.y = 70
	$marginSiguiente/siguiente.size.y = 70
	$marginSiguiente/siguiente.custom_minimum_size.y = 70
	$margin/horizontal/panelArriba.custom_minimum_size = Vector2(0, 100)
	$margin/horizontal/panelArriba.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#posiciones
	$margin/horizontal/container.alignment = BoxContainer.ALIGNMENT_BEGIN
	$margin/horizontal/panelArriba.position = Vector2.ZERO
	$publicidad.position.x = Globals.marcoPantalla
	$publicidad.position.y = Globals.pantallaTamano.y - 110
	$marginMarcador.position.y = Globals.pantallaTamano.y - 420
	$marginSiguiente.position.y = Globals.pantallaTamano.y - 300
	$margin/horizontal/container/marginBandera.custom_minimum_size.x = 250
	$marginMarcador/marcador.text = "0/0"

	if _pais_label != null:
		_pais_font_base_size = _get_label_font_size(_pais_label, _pais_font_base_size)
		_pais_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_pais_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_pais_label.custom_minimum_size.x = 0
	if _full_name_label != null:
		_full_name_font_base_size = _get_label_font_size(_full_name_label, _full_name_font_base_size)
		_full_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_full_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_full_name_label.custom_minimum_size.x = 0

	
	pais_al_azar()


func pais_al_azar():
	#escondo el resultado
	$margin/horizontal/contenedorResultado.hide()
	$marginSiguiente/siguiente.hide()
	randomize()
	#var cantidadPaises = Globals.json_data_total.size()
	#print(cantidadPaises)
	if numPaises == 0:
		return
	var pos = randi() % numPaises
	pais_actual = paises_array[pos]
	capital = _get_capital(pais_actual)
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
		var alpha2_code = str(pais_actual.get("alpha2", "")).to_lower()
		var cadPais = "res://png250px/" + alpha2_code + ".png"
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
		if alpha2_code != "" and ResourceLoader.exists(cadPais):
			$margin/horizontal/container/marginBandera/bandera.texture = load(cadPais)
		else:
			$margin/horizontal/container/marginBandera/bandera.texture = null
		if _pais_label != null:
			_pais_label.text = str(pais_actual.get("iso_short_name", ""))
		else:
			$margin/horizontal/container/marginPais/pais.text = str(pais_actual.get("iso_short_name", ""))
		$margin/horizontal/contenedorResultado/resultado.text = capital
		if _full_name_label != null:
			_full_name_label.text = str(pais_actual.get("iso_long_name", ""))
		else:
			$margin/horizontal/contenedorNombreCompleto/nombreCompleto.text = str(pais_actual.get("iso_long_name", ""))
		_update_country_labels_layout()
		var region_text = str(pais_actual.get("region", ""))
		var subregion_text = str(pais_actual.get("subregion", ""))
		var idiomas_info = pais_actual.get("languages_name", [])
		var idiomas_text = ""
		if idiomas_info is Array and not idiomas_info.is_empty():
			idiomas_text = ", ".join(idiomas_info)
		elif idiomas_info is String:
			idiomas_text = idiomas_info
		var region_label = "Región" if device_in_spanish else "Region"
		var subregion_label = "Subregión" if device_in_spanish else "Subregion"
		var idiomas_label = "Idiomas" if device_in_spanish else "Languages"
		var poblacion_label = "Población" if device_in_spanish else "Population"
		var moneda_label = "Moneda" if device_in_spanish else "Currency"
		var currencies_info = pais_actual.get("currencies_detail", [])
		var moneda_text = ""
		if currencies_info is Array and not currencies_info.is_empty():
			var moneda_parts = []
			for moneda in currencies_info:
				if moneda is Dictionary:
					var nombre_moneda = str(moneda.get("name", "")).strip_edges()
					var simbolo_moneda = str(moneda.get("symbol", "")).strip_edges()
					var moneda_item = nombre_moneda
					if simbolo_moneda != "":
						moneda_item += " (" + simbolo_moneda + ")"
					if moneda_item.strip_edges() != "":
						moneda_parts.append(moneda_item)
			moneda_text = ", ".join(moneda_parts)
		elif currencies_info is Dictionary:
			var nombre_moneda_dict = str(currencies_info.get("name", "")).strip_edges()
			var simbolo_moneda_dict = str(currencies_info.get("symbol", "")).strip_edges()
			moneda_text = nombre_moneda_dict
			if simbolo_moneda_dict != "":
				moneda_text += " (" + simbolo_moneda_dict + ")"
		moneda_text = moneda_text.strip_edges()
		var informacion = region_label + ": " + region_text
		informacion += "\n" + subregion_label + ": " + subregion_text
		informacion += "\n" + idiomas_label + ": " + idiomas_text
		if moneda_text != "":
			informacion += "\n" + moneda_label + ": " + moneda_text
			var population_value = _format_population(pais_actual.get("population", ""))
			informacion += "\n" + poblacion_label + ": " + population_value
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
		if numPaises == 0:
			return ""
		randomize()
		opcion = randi() % numPaises
		#print ("la opción es:",opcion)
		var posible_pais = paises_array[opcion]
		if posible_pais == pais_actual:
			continue
		capitalError = _get_capital(posible_pais)
		if capitalError.length() > 0 and capitalError != capital:
			capitalCorrecta = true
		else:
			capitalCorrecta = false
	#print("estoy fuera de la comprobación:",capitalCorrecta,"|",capitalError)
	return(capitalError)
