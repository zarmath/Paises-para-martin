extends Node2D

var _fade_rect: ColorRect
var _is_transitioning := false
var _icon_rect: TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RenderingServer.set_default_clear_color(Color8(0x12, 0x18, 0x33, 0xFF))
	#actualizar_compra_false()
	#conecto las señales
	var error = Globals.connect("timerFinalizado", Callable(self, "cambiarEscena"))
	if error != OK:
		print("no se ha conectado la señal")
	Globals.actualizar_tamano_pantalla(get_viewport())
	Globals.crearTemporizador(4.0)
	$center.custom_minimum_size = Globals.pantallaTamano
	_icon_rect = $center/imagen
	_create_fade_layer()
	_fade_in()
	_animate_icon()
		

func cambiarEscena() -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	var tween := create_tween()
	if _fade_rect:
		tween.tween_property(_fade_rect, "modulate:a", 1.0, 1.0)
	tween.finished.connect(func():
		Globals.cambiarEscena("res://Scenes/principal.tscn")
	)
	"""
	if primeraVez:
		Globals.cambiarEscena("res://escenas-principales/tutorial.tscn")
	else:
		Globals.cambiarEscena("res://escenas-principales/juego.tscn")
	"""


func _create_fade_layer() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color8(0x12, 0x18, 0x33, 0xFF)
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_rect.modulate.a = 1.0
	layer.add_child(_fade_rect)


func _fade_in() -> void:
	if _fade_rect == null:
		return
	var tween := create_tween()
	tween.tween_property(_fade_rect, "modulate:a", 0.0, 1.0)


func _animate_icon() -> void:
	if _icon_rect == null:
		return
	_icon_rect.modulate = Color(0.6, 0.6, 0.6, 1.0)
	var tween := create_tween()
	tween.tween_property(_icon_rect, "modulate", Color(1.3, 1.3, 1.3, 1.0), 1.5)
	tween.tween_property(_icon_rect, "modulate", Color(0.35, 0.35, 0.35, 1.0), 2.5)
