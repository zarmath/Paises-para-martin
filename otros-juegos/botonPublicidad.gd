extends MarginContainer

var enlaceApp : String #enlace a la tienda de apps


func _on_boton_pressed():
	var err = OS.shell_open(enlaceApp)
	if err != OK:
		print("no funciona el enlace")
