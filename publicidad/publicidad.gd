extends Node2D

var ordenArray
onready var miniatura = $contenedor/horizontal/marginSprite/miniatura
onready var explicacion = $contenedor/horizontal/margin/explicacion
var arrayPublicidad = [
	["res://publicidad/cover.png", "publi_cover","https://apps.apple.com/es/app/cover-of-knight/id1561834977","https://play.google.com/store/apps/details?id=com.garajeimagina.coverknight"],
	["res://publicidad/krepzen.png", "publi_krepzen","https://apps.apple.com/es/app/krepzen/id1551653313","https://play.google.com/store/apps/details?id=com.garajeimagina.krepzen&hl=es&gl=US"],
	["res://publicidad/multiplicatron.png", "publi_multiplicatron","https://apps.apple.com/us/app/multiplication-tables-visual/id1528703608?itsct=apps_box&itscg=30200","https://play.google.com/store/apps/details?id=org.godotengine.tablasdemultiplicar&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1"],
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$contenedor.rect_min_size.x = Globals.pantallaTamano.x - Globals.marcoPantalla*2
	$contenedor/horizontal.rect_min_size.y = 80
	$contenedor/panel.rect_min_size.x = Globals.pantallaTamano.x - Globals.marcoPantalla*2
	$contenedor/horizontal/margin/explicacion.rect_min_size.x = Globals.pantallaTamano.x - 160
	$contenedor/horizontal/margin/explicacion.rect_min_size.y = 80
	$enlaceJuego.rect_min_size.x = Globals.pantallaTamano.x
	$enlaceJuego.rect_min_size.y = 80
	randomize()
	ordenArray = randi()%(arrayPublicidad.size())+0
	#actualizo los datos de la publicidad
	miniatura.texture = load(arrayPublicidad[ordenArray][0])
	explicacion.set_text(tr(arrayPublicidad[ordenArray][1]))
	print(tr(arrayPublicidad[ordenArray][1]))



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_enlaceJuego_pressed() -> void:
	var enlace : String
	if OS.get_name() == "iOS":
		enlace = arrayPublicidad[ordenArray][2]
	elif OS.get_name() == "Android":
		enlace = arrayPublicidad[ordenArray][3]
	else:
		enlace = arrayPublicidad[ordenArray][2]
	print(enlace)
	var err = OS.shell_open(enlace)
	if err != OK:
		print("no funciona el enlace")
