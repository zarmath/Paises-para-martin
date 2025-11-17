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
@onready var _header_container: HBoxContainer = $margin/horizontal/contenedorCabecera
@onready var _pais_container: PanelContainer = $margin/horizontal/contenedorCabecera/contenedorNombres/marginPais
@onready var _pais_label: Label = $margin/horizontal/contenedorCabecera/contenedorNombres/marginPais/pais
@onready var _full_name_container: PanelContainer = $margin/horizontal/contenedorCabecera/contenedorNombres/contenedorNombreCompleto
@onready var _full_name_label: Label = $margin/horizontal/contenedorCabecera/contenedorNombres/contenedorNombreCompleto/nombreCompleto
@onready var _flag_texture_rect: TextureRect = $margin/horizontal/contenedorCabecera/contenedorBandera/bandera
@onready var _option_buttons_panel: PanelContainer = $margin/horizontal/contenedorBotones
@onready var _option_buttons_grid: VBoxContainer = $margin/horizontal/contenedorBotones/grid
@onready var _info_label_region: Label = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaRegion/etiqueta
@onready var _info_value_region: Label = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaRegion/valor
@onready var _info_icon_region: TextureRect = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaRegion/icono
@onready var _info_label_subregion: Label = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaSubregion/etiqueta
@onready var _info_value_subregion: Label = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaSubregion/valor
@onready var _info_icon_subregion: TextureRect = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaSubregion/icono
@onready var _info_label_moneda: Label = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaMoneda/etiqueta
@onready var _info_value_moneda: Label = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaMoneda/valor
@onready var _info_icon_moneda: TextureRect = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaMoneda/icono
@onready var _info_label_idiomas: Label = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaIdiomas/etiqueta
@onready var _info_value_idiomas: Label = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaIdiomas/valor
@onready var _info_icon_idiomas: TextureRect = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaIdiomas/icono
@onready var _info_label_poblacion: Label = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaPoblacion/etiqueta
@onready var _info_value_poblacion: Label = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaPoblacion/valor
@onready var _info_icon_poblacion: TextureRect = $margin/horizontal/contenedorInformacion/contenidoInformacion/filaPoblacion/icono
@onready var _info_panel: PanelContainer = $margin/horizontal/contenedorInformacion
@onready var _progress_bar: ProgressBar = $marginMarcador/marcador
@onready var _result_panel: PanelContainer = $margin/contenedorResultado
@onready var _result_label: Label = get_node_or_null("margin/contenedorResultado/contenidoResultado/resultado")
@onready var _next_button: Button = $margin/contenedorResultado/contenidoResultado/siguiente
@onready var _bottom_bar: MarginContainer = $barraInferior
@onready var _bottom_row: HBoxContainer = $barraInferior/filaInferior
@onready var _bottom_button_other_games: Button = $barraInferior/filaInferior/otrosJuegos
@onready var _bottom_button_stats: Button = $barraInferior/filaInferior/estadisticas
var _pais_font_base_size: int = 53
var _full_name_font_base_size: int = 42
var _fail_counts: Dictionary = {}
const FAIL_LOG_PATH := "user://fails_by_country.json"
const PAIS_FONT_MIN_SIZE := 26
const FULL_NAME_FONT_MIN_SIZE := 22
const FONT_SIZE_STEP := 2
const OPTION_BUTTONS_WIDTH_RATIO := 0.8
const INFO_ICON_SIZE := Vector2(18, 18)
const HEADER_FIXED_HEIGHT := 300.0
const RESULT_PANEL_HEIGHT_RATIO := 0.65
const RESULT_PANEL_Y_OFFSET := -40.0
const ICON_PATH_REGION := "res://Iconos/icono_region.png"
const ICON_PATH_SUBREGION := "res://Iconos/icono_subregion.png"
const ICON_PATH_MONEDA := "res://Iconos/icono_moneda.png"
const ICON_PATH_IDIOMAS := "res://Iconos/icono_idiomas.png"
const ICON_PATH_POBLACION := "res://Iconos/icono_poblacion.png"
var _icon_texture_region: Texture2D = null
var _icon_texture_subregion: Texture2D = null
var _icon_texture_moneda: Texture2D = null
var _icon_texture_idiomas: Texture2D = null
var _icon_texture_poblacion: Texture2D = null
var _fixed_header_height: float = 0.0
var _fixed_buttons_height: float = 0.0
var _fixed_result_height: float = 0.0
var _fixed_info_height: float = 0.0
const DEFAULT_HEADER_HEIGHT := 220.0
const DEFAULT_BUTTONS_HEIGHT := 320.0
const DEFAULT_RESULT_HEIGHT := 180.0
const DEFAULT_INFO_HEIGHT := 220.0
const HEADER_HEIGHT_RATIO := 0.15
const BUTTONS_HEIGHT_RATIO := 0.25
const RESULT_HEIGHT_RATIO := 0.18
const INFO_HEIGHT_RATIO := 0.32
const RESULT_BUTTON_BOTTOM_MARGIN := 100.0

func _update_header_width() -> void:
	if _header_container == null:
		return
	_ensure_fixed_heights()
	var screen_width: float = Globals.pantallaTamano.x
	if screen_width <= 0.0:
		screen_width = get_viewport_rect().size.x
	if screen_width <= 0.0:
		return
	var target_width: float = screen_width * 0.9
	_header_container.custom_minimum_size.x = target_width
	_header_container.size.x = target_width
	_header_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if _fixed_header_height > 0.0:
		_header_container.custom_minimum_size.y = _fixed_header_height
		_header_container.size.y = _fixed_header_height

func _update_info_panel_width() -> void:
	if _info_panel == null:
		return
	_ensure_fixed_heights()
	var screen_width: float = Globals.pantallaTamano.x
	if screen_width <= 0.0:
		screen_width = get_viewport_rect().size.x
	if screen_width <= 0.0:
		return
	var target_width: float = screen_width * 0.9
	_info_panel.custom_minimum_size.x = target_width
	_info_panel.size.x = target_width
	_info_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if _fixed_info_height > 0.0:
		_info_panel.custom_minimum_size.y = _fixed_info_height
		_info_panel.size.y = _fixed_info_height

func _update_result_panel_size() -> void:
	if _result_panel == null:
		return
	_ensure_fixed_heights()
	var screen_width: float = Globals.pantallaTamano.x
	if screen_width <= 0.0:
		screen_width = get_viewport_rect().size.x
	if screen_width <= 0.0:
		return
	var target_width: float = 0.0
	var target_height: float = 0.0
	if _option_buttons_panel != null:
		target_width = _option_buttons_panel.size.x
		if target_width <= 0.0:
			target_width = _option_buttons_panel.custom_minimum_size.x
		target_height = _option_buttons_panel.size.y
		if target_height <= 0.0:
			target_height = _option_buttons_panel.custom_minimum_size.y
	if target_width <= 0.0:
		target_width = screen_width * OPTION_BUTTONS_WIDTH_RATIO
	if target_height <= 0.0:
		target_height = _option_buttons_panel.get_combined_minimum_size().y if _option_buttons_panel != null else _result_panel.custom_minimum_size.y
	target_height *= RESULT_PANEL_HEIGHT_RATIO
	var required_height: float = _get_result_content_required_height()
	if required_height > 0.0:
		target_height = max(target_height, required_height)
	_result_panel.custom_minimum_size = Vector2(target_width, target_height)
	_result_panel.size = Vector2(target_width, target_height)
	_result_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_result_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_fixed_result_height = target_height
	if _option_buttons_panel != null:
		var target_global_pos: Vector2 = _option_buttons_panel.global_position + Vector2(0, RESULT_PANEL_Y_OFFSET )
		_result_panel.global_position = target_global_pos
	_update_result_button_offset()

func _get_result_content_required_height() -> float:
	var label_height: float = _get_result_label_height()
	var button_height: float = _get_result_button_height()
	if label_height <= 0.0 and button_height <= 0.0:
		return 0.0
	return label_height + button_height + RESULT_BUTTON_BOTTOM_MARGIN

func _get_result_label_height() -> float:
	if _result_label == null:
		return 0.0
	return max(_result_label.size.y, _result_label.get_combined_minimum_size().y)

func _get_result_button_height() -> float:
	if _next_button == null:
		return 0.0
	return max(_next_button.size.y, _next_button.get_combined_minimum_size().y)

func _update_result_button_offset() -> void:
	if _result_panel == null or _next_button == null:
		return
	var panel_height: float = _result_panel.size.y
	if panel_height <= 0.0:
		panel_height = _result_panel.custom_minimum_size.y
	if panel_height <= 0.0:
		return
	var label_height: float = _get_result_label_height()
	var button_height: float = _get_result_button_height()
	var min_needed: float = label_height + button_height + RESULT_BUTTON_BOTTOM_MARGIN
	if min_needed > panel_height:
		panel_height = min_needed
		_result_panel.custom_minimum_size.y = panel_height
		_result_panel.size.y = panel_height
	# Distribución manual: no forzamos alturas de otros nodos para que puedas ajustar el botón en el editor.

func _ensure_fixed_heights() -> void:
	if _header_container != null and _fixed_header_height <= 0.0:
		_fixed_header_height = HEADER_FIXED_HEIGHT
	if _option_buttons_panel != null and _fixed_buttons_height <= 0.0:
		var b: float = Globals.pantallaTamano.y * BUTTONS_HEIGHT_RATIO if Globals.pantallaTamano.y > 0.0 else 0.0
		if b <= 0.0:
			b = _option_buttons_panel.get_combined_minimum_size().y
		_fixed_buttons_height = max(b, DEFAULT_BUTTONS_HEIGHT)
	if _result_panel != null and _fixed_result_height <= 0.0:
		var r: float = Globals.pantallaTamano.y * RESULT_HEIGHT_RATIO if Globals.pantallaTamano.y > 0.0 else 0.0
		if r <= 0.0:
			r = _result_panel.get_combined_minimum_size().y
		_fixed_result_height = max(r, DEFAULT_RESULT_HEIGHT)
	if _info_panel != null and _fixed_info_height <= 0.0:
		var i: float = Globals.pantallaTamano.y * INFO_HEIGHT_RATIO if Globals.pantallaTamano.y > 0.0 else 0.0
		if i <= 0.0:
			i = _info_panel.get_combined_minimum_size().y
		_fixed_info_height = max(i, DEFAULT_INFO_HEIGHT)

func _apply_fixed_heights() -> void:
	if _header_container != null and _fixed_header_height > 0.0:
		_header_container.custom_minimum_size.y = _fixed_header_height
		_header_container.size.y = _fixed_header_height
	if _option_buttons_panel != null and _fixed_buttons_height > 0.0:
		_option_buttons_panel.custom_minimum_size.y = _fixed_buttons_height
		_option_buttons_panel.size.y = _fixed_buttons_height
	if _option_buttons_grid != null and _fixed_buttons_height > 0.0:
		_option_buttons_grid.custom_minimum_size.y = _fixed_buttons_height
		_option_buttons_grid.size.y = _fixed_buttons_height
		for button_name in ["opcion1", "opcion2", "opcion3", "opcion4"]:
			var btn: Button = _option_buttons_grid.get_node(button_name)
			if btn != null:
				btn.custom_minimum_size.y = _fixed_buttons_height / 4.0
	if _result_panel != null and _fixed_result_height > 0.0:
		_result_panel.custom_minimum_size.y = _fixed_result_height
		_result_panel.size.y = _fixed_result_height
	if _info_panel != null and _fixed_info_height > 0.0:
		_info_panel.custom_minimum_size.y = _fixed_info_height
		_info_panel.size.y = _fixed_info_height

func _reset_result_panel() -> void:
	if _result_panel == null:
		return
	_result_panel.hide()
	var estilo: StyleBox = load("res://Art/error.tres")
	if estilo != null:
		estilo.bg_color = Color("#14162d")
		_result_panel.add_theme_stylebox_override("panel", estilo)
	if _result_label != null:
		_result_label.text = ""
	_update_result_button_offset()

func _update_progress_bar_size() -> void:
	if _progress_bar == null:
		return
	var screen_width: float = Globals.pantallaTamano.x
	if screen_width <= 0.0:
		screen_width = get_viewport_rect().size.x
	if screen_width <= 0.0:
		return
	var target_width: float = screen_width * 0.9
	_progress_bar.custom_minimum_size.x = target_width
	_progress_bar.size.x = target_width
	_progress_bar.custom_minimum_size.y = 120.0
	_progress_bar.size.y = 120.0
	_progress_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

func _apply_info_icon(icon_node: TextureRect, texture: Texture2D) -> void:
	if icon_node == null:
		return
	if INFO_ICON_SIZE.x > 0.0 and INFO_ICON_SIZE.y > 0.0:
		icon_node.custom_minimum_size = INFO_ICON_SIZE
		icon_node.size = INFO_ICON_SIZE
	if texture != null:
		icon_node.texture = texture

func _set_info_row(label_node: Label, value_node: Label, icon_node: TextureRect, label_text: String, value_text: String, texture: Texture2D) -> void:
	if label_node != null:
		label_node.text = label_text + ":"
	if value_node != null:
		var clean_value: String = value_text.strip_edges()
		if clean_value == "":
			value_node.text = "-"
		else:
			value_node.text = _wrap_info_value(clean_value)
	_apply_info_icon(icon_node, texture)

func _wrap_info_value(text: String, limit: int = 35) -> String:
	# Inserta saltos de línea suaves para evitar que valores largos rompan el layout.
	var words: Array = text.split(" ")
	var lines: Array[String] = []
	var current: String = ""
	for word in words:
		if current == "":
			current = word
		elif current.length() + 1 + word.length() <= limit:
			current += " " + word
		else:
			lines.append(current)
			current = word
	if current != "":
		lines.append(current)
	return "\n".join(lines)

func _update_info_labels() -> void:
	_set_info_row(_info_label_region, _info_value_region, _info_icon_region, _get_translated_label("region", "Region"), "", _icon_texture_region)
	_set_info_row(_info_label_subregion, _info_value_subregion, _info_icon_subregion, _get_translated_label("subregion", "Subregion"), "", _icon_texture_subregion)
	_set_info_row(_info_label_moneda, _info_value_moneda, _info_icon_moneda, _get_translated_label("moneda", "Currency"), "", _icon_texture_moneda)
	_set_info_row(_info_label_idiomas, _info_value_idiomas, _info_icon_idiomas, _get_translated_label("idiomas", "Languages"), "", _icon_texture_idiomas)
	_set_info_row(_info_label_poblacion, _info_value_poblacion, _info_icon_poblacion, _get_translated_label("poblacion", "Population"), "", _icon_texture_poblacion)

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
	var header_width: float = 0.0
	if _header_container != null:
		header_width = _header_container.size.x
	if header_width <= 0.0 and Globals.pantallaTamano != null:
		header_width = Globals.pantallaTamano.x * 0.9
	if _pais_label != null and _pais_container != null:
		var pais_width: float = _pais_container.size.x
		if pais_width <= 0.0:
			pais_width = _pais_container.custom_minimum_size.x
		if pais_width <= 0.0 and header_width > 0.0:
			pais_width = header_width / 3.0
		if pais_width <= 0.0 and Globals.pantallaTamano != null:
			pais_width = Globals.pantallaTamano.x * 0.5
		_fit_label_to_available_width(_pais_label, _pais_font_base_size, PAIS_FONT_MIN_SIZE, FONT_SIZE_STEP, pais_width)
	if _full_name_label != null and _full_name_container != null:
		var nombre_width: float = _full_name_container.size.x
		if nombre_width <= 0.0:
			nombre_width = _full_name_container.custom_minimum_size.x
		if nombre_width <= 0.0 and header_width > 0.0:
			nombre_width = header_width * (2.0 / 3.0)
		if nombre_width <= 0.0 and Globals.pantallaTamano != null:
			nombre_width = Globals.pantallaTamano.x * 0.5
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
	# Carga datos, idioma y recursos de iconos antes de inicializar UI.
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
	var normalized_locale: String = ""
	if typeof(locale_code) == TYPE_STRING and locale_code != "":
		normalized_locale = locale_code
		var underscore_index: int = normalized_locale.find("_")
		if underscore_index > -1:
			normalized_locale = normalized_locale.substr(0, underscore_index)
		var dash_index: int = normalized_locale.find("-")
		if dash_index > -1:
			normalized_locale = normalized_locale.substr(0, dash_index)
	if normalized_locale.strip_edges() != "":
		TranslationServer.set_locale(normalized_locale.strip_edges())
	if ResourceLoader.exists(ICON_PATH_REGION):
		_icon_texture_region = load(ICON_PATH_REGION)
	if ResourceLoader.exists(ICON_PATH_SUBREGION):
		_icon_texture_subregion = load(ICON_PATH_SUBREGION)
	if ResourceLoader.exists(ICON_PATH_MONEDA):
		_icon_texture_moneda = load(ICON_PATH_MONEDA)
	if ResourceLoader.exists(ICON_PATH_IDIOMAS):
		_icon_texture_idiomas = load(ICON_PATH_IDIOMAS)
	if ResourceLoader.exists(ICON_PATH_POBLACION):
		_icon_texture_poblacion = load(ICON_PATH_POBLACION)
	Globals.apply_background_color()
	_update_bottom_buttons_text()
	_position_bottom_bar()
	_load_fail_counts()
	intentos = 0
	aciertos = 0
	#numPaises = 249
	# Tamaños base y colocación inicial de contenedores superiores.
	$margin.size.x = Globals.pantallaTamano.x
	$margin/horizontal.size.x = Globals.pantallaTamano.x
	_update_header_width()
	$marginMarcador.size.x = Globals.pantallaTamano.x
	$marginMarcador.size.y = 70
	$marginMarcador/panelMarcador.size.y = 70
	$margin/horizontal/panelArriba.custom_minimum_size = Vector2(0, 100)
	$margin/horizontal/panelArriba.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#posiciones
	$margin/horizontal/contenedorCabecera.alignment = BoxContainer.ALIGNMENT_BEGIN
	$margin/horizontal/panelArriba.position = Vector2.ZERO
	$publicidad.position.x = Globals.marcoPantalla
	$publicidad.position.y = Globals.pantallaTamano.y - 110
	$marginMarcador.position.y = Globals.pantallaTamano.y - 420
	_ensure_fixed_heights()
	_apply_fixed_heights()
	_update_header_width()
	_update_option_buttons_width()
	_update_info_panel_width()
	_update_progress_bar_size()
	_update_result_panel_size()
	_reset_result_panel()
	_update_result_button_offset()

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
	for info_label in [_info_value_region, _info_value_subregion, _info_value_moneda, _info_value_idiomas, _info_value_poblacion]:
		if info_label != null:
			info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			info_label.custom_minimum_size.x = 0
	_update_info_labels()


	pais_al_azar()
	call_deferred("_update_country_labels_layout")
	call_deferred("_update_option_buttons_width")
	call_deferred("_update_score_ui")
	if _bottom_button_other_games != null:
		_bottom_button_other_games.pressed.connect(_on_bottom_other_games_pressed)
	if _bottom_button_stats != null:
		_bottom_button_stats.pressed.connect(_on_bottom_stats_pressed)

func _update_bottom_buttons_text() -> void:
	if _bottom_button_other_games != null:
		_bottom_button_other_games.text = tr("otros_juegos")
	if _bottom_button_stats != null:
		_bottom_button_stats.text = tr("estadisticas")

func _position_bottom_bar() -> void:
	if _bottom_bar == null:
		return
	# Ancla la barra inferior a 120 px del borde inferior y la expande horizontalmente.
	var bar_height: float = _bottom_bar.size.y
	if bar_height <= 0.0:
		bar_height = _bottom_bar.custom_minimum_size.y
	if bar_height <= 0.0:
		bar_height = 100.0

	_bottom_bar.anchor_left = 0.0
	_bottom_bar.anchor_right = 1.0
	_bottom_bar.anchor_top = 1.0
	_bottom_bar.anchor_bottom = 1.0
	_bottom_bar.offset_left = 0.0
	_bottom_bar.offset_right = 0.0
	_bottom_bar.offset_bottom = 0.0
	_bottom_bar.offset_top = -bar_height
	_bottom_bar.custom_minimum_size.y = bar_height
	_bottom_bar.size = Vector2(Globals.pantallaTamano.x, bar_height)
	_bottom_bar.position = Vector2(0,Globals.pantallaTamano.y -140)
	if _bottom_row != null:
		var screen_width: float = Globals.pantallaTamano.x
		if screen_width <= 0.0:
			screen_width = get_viewport_rect().size.x
		if screen_width > 0.0:
			var available_width: float = screen_width - 40.0 # 20 px de margen a cada lado en la barra
			var target_width: float = available_width * 0.8
			_bottom_row.custom_minimum_size.x = target_width
			_bottom_row.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			_bottom_row.alignment = BoxContainer.ALIGNMENT_CENTER

func _load_fail_counts() -> void:
	if not FileAccess.file_exists(FAIL_LOG_PATH):
		_fail_counts = {}
		return
	var file := FileAccess.open(FAIL_LOG_PATH, FileAccess.READ)
	if file == null:
		_fail_counts = {}
		return
	var test_json_conv := JSON.new()
	var err := test_json_conv.parse(file.get_as_text())
	file.close()
	if err != OK or not (test_json_conv.data is Dictionary):
		_fail_counts = {}
		return
	_fail_counts = test_json_conv.data

func _save_fail_counts() -> void:
	var file := FileAccess.open(FAIL_LOG_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(_fail_counts))
	file.close()

func _record_fail() -> void:
	if not (pais_actual is Dictionary):
		return
	var clave: String = str(pais_actual.get("iso_short_name", "")).strip_edges()
	if clave == "":
		clave = str(pais_actual.get("iso_long_name", "")).strip_edges()
	if clave == "":
		clave = str(pais_actual.get("name", "")).strip_edges()
	if clave == "":
		return
	if not _fail_counts.has(clave):
		_fail_counts[clave] = 0
	_fail_counts[clave] += 1
	_save_fail_counts()

func _on_bottom_other_games_pressed() -> void:
	var target_scene: String = "res://otros-juegos/otrosJuegos.tscn"
	if ResourceLoader.exists(target_scene):
		get_tree().change_scene_to_file(target_scene)
	else:
		push_warning("No se encuentra la escena: " + target_scene)

func _on_bottom_stats_pressed() -> void:
	if _result_panel != null:
		_result_panel.show()
	if _next_button != null:
		_next_button.disabled = true
	var mensaje: String = ""
	if _fail_counts.is_empty():
		mensaje = tr("estadisticas") + ":\n" + tr("sin_datos")
	else:
		var pares: Array = []
		for k in _fail_counts.keys():
			pares.append({"pais": k, "fallos": int(_fail_counts[k])})
		pares.sort_custom(func(a, b): return a["fallos"] > b["fallos"])
		var max_to_show: int = min(5, pares.size())
		var lineas: Array[String] = []
		for i in range(max_to_show):
			var dato = pares[i]
			lineas.append(str(i + 1) + ". " + dato["pais"] + " - " + str(dato["fallos"]))
		mensaje = tr("estadisticas") + ":\n" + "\n".join(lineas)
	if _result_label != null:
		_result_label.text = mensaje
	_update_result_panel_size()
	_update_result_button_offset()


func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_update_header_width()
		_update_option_buttons_width()
		_update_country_labels_layout()
		_update_info_panel_width()
		_update_progress_bar_size()
		_update_result_panel_size()
		_position_bottom_bar()
		_apply_fixed_heights()


func pais_al_azar():
	_reset_result_panel()
	if _next_button != null:
		_next_button.disabled = true
	_apply_fixed_heights()
	_update_result_panel_size()
	_update_result_button_offset()
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
		var font = $margin/horizontal/contenedorCabecera/contenedorNombres/marginPais/pais.get_font("string_name", "")
		if longitudNombrePais < 20:
			font.size = 60
		if longitudNombrePais > 19 && longitudNombrePais < 40:
			font.size = 40
		if longitudNombrePais > 39:
			font.size = 30
		"""
		#print("el tamaño de la fuente es:",font.size,"|",longitudNombrePais)
		if alpha2_code != "" and ResourceLoader.exists(cadPais):
			_flag_texture_rect.texture = load(cadPais)
		else:
			_flag_texture_rect.texture = null
		var short_name: String = str(pais_actual.get("iso_short_name", ""))
		var formatted_short_name: String = _insert_line_break_if_needed(short_name)
		if _pais_label != null:
			_pais_label.text = formatted_short_name
		else:
			$margin/horizontal/contenedorCabecera/contenedorNombres/marginPais/pais.text = formatted_short_name
		if _result_label != null:
			_result_label.text = capital
		if _full_name_label != null:
			_full_name_label.text = str(pais_actual.get("iso_long_name", ""))
		else:
			$margin/horizontal/contenedorCabecera/contenedorNombres/contenedorNombreCompleto/nombreCompleto.text = str(pais_actual.get("iso_long_name", ""))
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
		var population_value: String = _format_population(pais_actual.get("population", ""))
		_set_info_row(_info_label_region, _info_value_region, _info_icon_region, region_label, region_text, _icon_texture_region)
		_set_info_row(_info_label_subregion, _info_value_subregion, _info_icon_subregion, subregion_label, subregion_text, _icon_texture_subregion)
		_set_info_row(_info_label_moneda, _info_value_moneda, _info_icon_moneda, moneda_label, moneda_text, _icon_texture_moneda)
		_set_info_row(_info_label_idiomas, _info_value_idiomas, _info_icon_idiomas, idiomas_label, idiomas_text, _icon_texture_idiomas)
		_set_info_row(_info_label_poblacion, _info_value_poblacion, _info_icon_poblacion, poblacion_label, population_value, _icon_texture_poblacion)
		_update_header_width()
		_update_info_panel_width()
		_update_country_labels_layout()
		_update_option_buttons_width()
	else:
		pais_al_azar()
		#pass




func _on_Button_pressed():
	pais_al_azar()
	activar_botones()
	_update_score_ui()

func _update_score_ui() -> void:
	if _progress_bar == null:
		return
	_progress_bar.min_value = 0.0
	_progress_bar.max_value = 100.0
	var total: float = float(max(intentos, 1))
	var percent: float = (float(aciertos) / total) * 100.0
	_progress_bar.value = clamp(percent, 0.0, 100.0)
	_progress_bar.tooltip_text = str(aciertos) + "/" + str(intentos)


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
	if _result_panel != null:
		_result_panel.show()
	if _next_button != null:
		_next_button.disabled = false
	_update_result_panel_size()
	_update_result_button_offset()
	var estilo: StyleBox = load("res://Art/error.tres")
	if exito:
		#$margin/horizontal/contenedorCapital.col
		if _result_label != null:
			_result_label.text = "CORRECTO¡¡¡\nLa capital es:\n" + capital
		#$margin/horizontal/contenedorCapital.get_stylebox("error", "" ).set_bg_color("#31d774")
		#estilo_respuesta.set_bg_color("#31d774")
		#set(get_node("margin/horizontal/contenedorCapital"),estilo_respuesta)
		estilo.bg_color = Color("#2ec27e")
		aciertos += 1
	else:
		if _result_label != null:
			_result_label.text = "ERROR¡¡¡\nLa capital es:\n" + capital
		#$margin/horizontal/contenedorCapital.get_stylebox("error", "" ).set_bg_color("#d73137")
		#estilo_respuesta.set_bg_color("#d73137")
		estilo.bg_color = Color("#d35f5f")
		_record_fail()
	intentos += 1
	_update_score_ui()

func desactivar_botones():
	$margin/horizontal/contenedorBotones/grid/opcion1.disabled = true
	$margin/horizontal/contenedorBotones/grid/opcion2.disabled = true
	$margin/horizontal/contenedorBotones/grid/opcion3.disabled = true
	$margin/horizontal/contenedorBotones/grid/opcion4.disabled = true
	_apply_fixed_heights()

func activar_botones():
	$margin/horizontal/contenedorBotones/grid/opcion1.disabled = false
	$margin/horizontal/contenedorBotones/grid/opcion2.disabled = false
	$margin/horizontal/contenedorBotones/grid/opcion3.disabled = false
	$margin/horizontal/contenedorBotones/grid/opcion4.disabled = false
	if _option_buttons_grid != null:
		_option_buttons_grid.visible = true
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
	_ensure_fixed_heights()
	var screen_width: float = Globals.pantallaTamano.x
	if screen_width <= 0.0:
		screen_width = get_viewport_rect().size.x
	if screen_width <= 0.0:
		return
	var target_width: float = screen_width * OPTION_BUTTONS_WIDTH_RATIO
	_option_buttons_panel.custom_minimum_size.x = target_width
	_option_buttons_panel.size.x = target_width
	_option_buttons_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if _fixed_buttons_height > 0.0:
		_option_buttons_panel.custom_minimum_size.y = _fixed_buttons_height
		_option_buttons_panel.size.y = _fixed_buttons_height
	if _option_buttons_grid != null:
		_option_buttons_grid.custom_minimum_size.x = target_width
		_option_buttons_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if _fixed_buttons_height > 0.0:
			_option_buttons_grid.custom_minimum_size.y = _fixed_buttons_height
			_option_buttons_grid.size.y = _fixed_buttons_height
		for button_name in ["opcion1", "opcion2", "opcion3", "opcion4"]:
			var button: Button = _option_buttons_grid.get_node(button_name)
			if button != null:
				button.custom_minimum_size.x = target_width
				button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				if _fixed_buttons_height > 0.0:
					button.custom_minimum_size.y = _fixed_buttons_height / 4.0
	_update_result_panel_size()
