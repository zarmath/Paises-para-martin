extends Node2D

var pais_actual: Dictionary = {}
var paises_array: Array = []
var numPaises: int = 0
var capital: String = ""
var exito: bool = false
var intentos: int = 0
var aciertos: int = 0
var estilo_respuesta: StyleBoxFlat = StyleBoxFlat.new()
var capitalCorrecta: bool = false
var capitalError: String = ""
var opcion: int = -1
@onready var _pais_container: PanelContainer = $margin/horizontal/container/marginPais
@onready var _pais_label: Label = $margin/horizontal/container/marginPais/pais
@onready var _full_name_container: PanelContainer = $margin/horizontal/contenedorNombreCompleto
@onready var _full_name_label: Label = $margin/horizontal/contenedorNombreCompleto/nombreCompleto
@onready var _option_buttons_panel: PanelContainer = $margin/horizontal/contenedorBotones
@onready var _option_buttons_grid: VBoxContainer = $margin/horizontal/contenedorBotones/grid
var _pais_font_base_size: int = 53
var _full_name_font_base_size: int = 42
const PAIS_FONT_MIN_SIZE := 26
const FULL_NAME_FONT_MIN_SIZE := 22
const FONT_SIZE_STEP := 2
const OPTION_BUTTONS_WIDTH_RATIO := 0.8

func _format_population(value):
	var digits: String = ""
	var value_type: int = typeof(value)
	var is_negative: bool = false
	if value_type == TYPE_INT:
		var int_value: int = value
		is_negative = int_value < 0
		digits = str(abs(int_value))
	elif value_type == TYPE_FLOAT:
		var float_value: float = value
		is_negative = float_value < 0.0
		digits = str(abs(int(float_value)))
	else:
		var pop_text: String = str(value)
		for char in pop_text:
			if "0123456789".find(char) != -1:
				digits += char
	if digits == "":
		return str(value)
	var formatted: String = ""
	var count: int = 0
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
	var detected_size: int = label.get_theme_font_size("font_size")
	if detected_size <= 0:
		return fallback
	return max(detected_size, fallback)

func _fit_label_to_available_width(label: Label, base_size: int, min_size: int, step: int, max_width: float) -> void:
	if label == null:
		return
	var font: Font = label.get_theme_font("font")
	if font == null or max_width <= 0.0:
		label.add_theme_font_size_override("font_size", base_size)
		label.reset_size()
		return
	var text: String = label.text.strip_edges()
	if text == "":
		label.remove_theme_font_size_override("font_size")
		label.reset_size()
		return
	var font_size: int = base_size
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
		var pais_width: float = _pais_container.size.x
		if pais_width <= 0.0 and Globals.pantallaTamano != null:
			pais_width = Globals.pantallaTamano.x - 250.0
		_fit_label_to_available_width(_pais_label, _pais_font_base_size, PAIS_FONT_MIN_SIZE, FONT_SIZE_STEP, pais_width)
	if _full_name_label != null and _full_name_container != null:
		var nombre_width: float = _full_name_container.size.x
		if nombre_width <= 0.0 and Globals.pantallaTamano != null:
			nombre_width = Globals.pantallaTamano.x
		_fit_label_to_available_width(_full_name_label, _full_name_font_base_size, FULL_NAME_FONT_MIN_SIZE, FONT_SIZE_STEP, nombre_width)

func _get_capital(entry) -> String:
	if not (entry is Dictionary):
		return ""
	var capital_value: Variant = entry.get("capital", [])
	if capital_value is Array and not capital_value.is_empty():
		return str(capital_value[0])
	if capital_value is String:
		return capital_value.strip_edges()
	return ""

func _get_translated_label(key: String, fallback: String) -> String:
	var translated: String = tr(key)
	return fallback if translated == key else translated

func _insert_line_break_if_needed(name: String, limit: int = 20) -> String:
	var trimmed: String = name.strip_edges()
	if trimmed.length() <= limit:
		return trimmed
	var break_index: int = -1
	for i in range(trimmed.length()):
		if trimmed[i] == " ":
			if i >= limit:
				break_index = i
				break
			break_index = i
	if break_index == -1:
		break_index = limit
	return trimmed.substr(0, break_index).strip_edges() + "\n" + trimmed.substr(break_index).strip_edges()

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
	var locale_code: String = OS.get_locale()
	if typeof(locale_code) == TYPE_STRING and locale_code != "":
		var normalized_locale: String = locale_code
		var underscore_index: int = normalized_locale.find("_")
		if underscore_index > -1:
			normalized_locale = normalized_locale.substr(0, underscore_index)
		var dash_index: int = normalized_locale.find("-")
		if dash_index > -1:
			normalized_locale = normalized_locale.substr(0, dash_index)
		if normalized_locale.strip_edges() != "":
			TranslationServer.set_locale(normalized_locale.strip_edges())
	Globals.apply_background_color()
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
	$margin/horizontal/contenedorInformacion/contenidoInformacion/bandera.custom_minimum_size.x = 250
	$marginMarcador/marcador.text = "0/0"
	_update_option_buttons_width()

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
	call_deferred("_update_country_labels_layout")
	call_deferred("_update_option_buttons_width")


func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_update_option_buttons_width()


func pais_al_azar():
	#escondo el resultado
	$margin/horizontal/contenedorResultado.hide()
	$marginSiguiente/siguiente.hide()
	randomize()
	#var cantidadPaises = Globals.json_data_total.size()
	#print(cantidadPaises)
	if numPaises == 0:
		return
	var pos: int = randi() % numPaises
	pais_actual = paises_array[pos]
	capital = _get_capital(pais_actual)
	if capital.length() > 0:
		var opcionCorrecta: int = randi() % 4 + 1
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
		var alpha2_code: String = str(pais_actual.get("alpha2", "")).to_lower()
		var cadPais: String = "res://png250px/" + alpha2_code + ".png"
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
			$margin/horizontal/contenedorInformacion/contenidoInformacion/bandera.texture = load(cadPais)
		else:
			$margin/horizontal/contenedorInformacion/contenidoInformacion/bandera.texture = null
		var short_name: String = str(pais_actual.get("iso_short_name", ""))
		var formatted_short_name: String = _insert_line_break_if_needed(short_name)
		if _pais_label != null:
			_pais_label.text = formatted_short_name
		else:
			$margin/horizontal/container/marginPais/pais.text = formatted_short_name
		$margin/horizontal/contenedorResultado/resultado.text = capital
		if _full_name_label != null:
			_full_name_label.text = str(pais_actual.get("iso_long_name", ""))
		else:
			$margin/horizontal/contenedorNombreCompleto/nombreCompleto.text = str(pais_actual.get("iso_long_name", ""))
		_update_country_labels_layout()
		var region_text: String = str(pais_actual.get("region", ""))
		var subregion_text: String = str(pais_actual.get("subregion", ""))
		var idiomas_info: Variant = pais_actual.get("languages_name", [])
		var idiomas_text: String = ""
		if idiomas_info is Array and not idiomas_info.is_empty():
			idiomas_text = ", ".join(idiomas_info)
		elif idiomas_info is String:
			idiomas_text = idiomas_info
		var region_label: String = _get_translated_label("region", "Region")
		var subregion_label: String = _get_translated_label("subregion", "Subregion")
		var idiomas_label: String = _get_translated_label("idiomas", "Languages")
		var poblacion_label: String = _get_translated_label("poblacion", "Population")
		var moneda_label: String = _get_translated_label("moneda", "Currency")
		var currencies_info: Variant = pais_actual.get("currencies_detail", [])
		var moneda_text: String = ""
		if currencies_info is Array and not currencies_info.is_empty():
			var moneda_parts: Array[String] = []
			for moneda in currencies_info:
				if moneda is Dictionary:
					var nombre_moneda: String = str(moneda.get("name", "")).strip_edges()
					var simbolo_moneda: String = str(moneda.get("symbol", "")).strip_edges()
					var moneda_item: String = nombre_moneda
					if simbolo_moneda != "":
						moneda_item += " (" + simbolo_moneda + ")"
					if moneda_item.strip_edges() != "":
						moneda_parts.append(moneda_item)
			moneda_text = ", ".join(moneda_parts)
		elif currencies_info is Dictionary:
			var nombre_moneda_dict: String = str(currencies_info.get("name", "")).strip_edges()
			var simbolo_moneda_dict: String = str(currencies_info.get("symbol", "")).strip_edges()
			moneda_text = nombre_moneda_dict
			if simbolo_moneda_dict != "":
				moneda_text += " (" + simbolo_moneda_dict + ")"
		moneda_text = moneda_text.strip_edges()
		var informacion: String = region_label + ": " + region_text
		informacion += "\n" + subregion_label + ": " + subregion_text
		informacion += "\n" + idiomas_label + ": " + idiomas_text
		if moneda_text != "":
			informacion += "\n" + moneda_label + ": " + moneda_text
			var population_value: String = _format_population(pais_actual.get("population", ""))
			informacion += "\n" + poblacion_label + ": " + population_value
		#informacion += "\n" + "Gentilicio:" + str(Globals.json_data_total[pos]["demonyms"])
		$margin/horizontal/contenedorInformacion/contenidoInformacion/informacion.text = informacion
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
	var estilo: StyleBox = load("res://Art/error.tres")
	if exito:
		#$margin/horizontal/contenedorCapital.col
		$margin/horizontal/contenedorResultado/resultado.text = "CORRECTO¡¡¡\nLa capital es: " + capital
		#$margin/horizontal/contenedorCapital.get_stylebox("error", "" ).set_bg_color("#31d774")
		#estilo_respuesta.set_bg_color("#31d774")
		#set(get_node("margin/horizontal/contenedorCapital"),estilo_respuesta)
		estilo.bg_color = Color("#1d7b41")
		aciertos += 1
	else:
		$margin/horizontal/contenedorResultado/resultado.text = "ERROR¡¡¡\nLa capital es: " + capital
		#$margin/horizontal/contenedorCapital.get_stylebox("error", "" ).set_bg_color("#d73137")
		#estilo_respuesta.set_bg_color("#d73137")
		estilo.bg_color = Color("#a0455c")
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
	_update_option_buttons_width()

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
		var posible_pais: Dictionary = paises_array[opcion]
		if posible_pais == pais_actual:
			continue
		capitalError = _get_capital(posible_pais)
		if capitalError.length() > 0 and capitalError != capital:
			capitalCorrecta = true
		else:
			capitalCorrecta = false
	#print("estoy fuera de la comprobación:",capitalCorrecta,"|",capitalError)
	return(capitalError)


func _update_option_buttons_width() -> void:
	if _option_buttons_panel == null:
		return
	var screen_width: float = Globals.pantallaTamano.x
	if screen_width <= 0.0:
		screen_width = get_viewport_rect().size.x
	if screen_width <= 0.0:
		return
	var target_width: float = screen_width * OPTION_BUTTONS_WIDTH_RATIO
	_option_buttons_panel.custom_minimum_size.x = target_width
	_option_buttons_panel.size.x = target_width
	_option_buttons_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if _option_buttons_grid != null:
		_option_buttons_grid.custom_minimum_size.x = target_width
		_option_buttons_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for button_name in ["opcion1", "opcion2", "opcion3", "opcion4"]:
			var button: Button = _option_buttons_grid.get_node(button_name)
			if button != null:
				button.custom_minimum_size.x = target_width
				button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
