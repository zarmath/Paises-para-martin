extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	VisualServer.set_default_clear_color(Color(0,0,0,1.0))
	#actualizar_compra_false()
	#conecto las señales
	var error = Globals.connect("timerFinalizado",self,"cambiarEscena")
	if error != OK:
		print("no se ha conectado la señal")
	Globals.pantallaTamano = get_viewport_rect().size
	Globals.crearTemporizador(1.5)
	$center.rect_min_size = Globals.pantallaTamano
	

func cambiarEscena() -> void:
	Globals.cambiarEscena("res://Scenes/principal.tscn")
	"""
	if primeraVez:
		Globals.cambiarEscena("res://escenas-principales/tutorial.tscn")
	else:
		Globals.cambiarEscena("res://escenas-principales/juego.tscn")
	"""

