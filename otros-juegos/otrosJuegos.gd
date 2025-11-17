extends Node2D

#onready var transition_layer = Globals.transition_layer.instance()
@onready var botonVolver = $contenedorTitulo/volver
#var barra = preload("res://otros-juegos/barraPublicidad.tscn")
var barra = preload("res://otros-juegos/botonPublicidad.tscn")
#var transition_layer = preload("res://escenas-principales/transicion.tscn").instance()


# Inicializa la escena, ajusta tamaños/posiciones y genera la cuadrícula de juegos.
func _ready() -> void:
	#add_child(transition_layer)
	#transition_layer.start_transition2()
	#TAMAñOS
	$contenedorGeneral.size = Vector2(Globals.pantallaTamano.x - Globals.marcoPantalla*2,Globals.pantallaTamano.y - 140)
	#POSICIONES
	$contenedorTitulo.position = Vector2(Globals.marcoPantalla,100)
	#$contenedorTitulo/volver.position = Vector2(Globals.marcoPantalla,20)
	$contenedorGeneral.position = Vector2(Globals.marcoPantalla,240)
	construir_cuadricula()
	#TRADUCCIONES
	botonVolver.set_text(tr("volver_anterior"))
	#OPERATIVA



# Gestiona el botón de volver a la escena principal.
func _on_volver_pressed() -> void:
	#volver al juegos
	Globals.cambiarEscena("res://Scenes/principal.tscn")
	#transition_layer.start_transition("res://principales/juego.tscn")


# Construye la lista de otros juegos con icono, texto traducido y enlace según plataforma.
func construir_cuadricula() -> void:
	#construyo la cuadrícula de 'otros-juegos'
	#var leerOtrosJuegos = Globals.leer_datos()

	var lectorDatos : Dictionary
	var rutaIconos : String
	#if leerOtrosJuegos.has('otros_juegos'):
		#lectorDatos = leerOtrosJuegos['otros_juegos']
		#rutaIconos = "user://iconos/"
	#else:
	lectorDatos = Otrosjuegosdata.datosOtrosJuegos['otros_juegos']
	rutaIconos = "res://otros-juegos/iconos/"
	#print("leerOtrosJuegos:",lectorDatos)
	#for n in leerOtrosJuegos['otros_juegos']:
	#print("lector datos:",lectorDatos)
	for n in lectorDatos:
		if n != "size":
			var barra_instancia = barra.instantiate()
			#var icono = load(rutaIconos + lectorDatos[n]['iconoNombre'])
			barra_instancia.get_node("boton").icon = load(rutaIconos + lectorDatos[n]['iconoNombre'])
			barra_instancia.get_node("boton").add_theme_constant_override("h_separation", 20)
			var idioma = TranslationServer.get_locale()
			#print("idioma:",TranslationServer.get_locale())

			if idioma == "es":
				barra_instancia.get_node("boton").text = str(lectorDatos[n]["spanish"])
			else:
				barra_instancia.get_node("boton").text = str(lectorDatos[n]["ingles"])

			if OS.get_name() == "iOS":
				if lectorDatos[n].has("appstore"):
					barra_instancia.enlaceApp = str(lectorDatos[n]["appstore"])
			elif OS.get_name() == "Android":
				if lectorDatos[n].has("playstore"):
					barra_instancia.enlaceApp = str(lectorDatos[n]["playstore"])
			elif OS.get_name() == "HTML5":
				if lectorDatos[n].has("web"):
					barra_instancia.enlaceApp = str(lectorDatos[n]["web"])
			else:
				if lectorDatos[n].has("web"):
					barra_instancia.enlaceApp = str(lectorDatos[n]["web"])

			$contenedorGeneral/scroll/vertical.add_child(barra_instancia)
