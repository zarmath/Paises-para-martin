extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.leer_json_total("listado_paises_completa")
	print(Globals.json_data_total[1]["name"])
	#Globals.leer_json_total("lista_abreviaturas")
	print(Globals.json_data_total[2]["alpha2Code"])
	$prueba.text = str(Globals.json_data_total[144]["name"]) + " | " + str(Globals.json_data_total[144]["alpha2Code"]) + " | " + str(Globals.json_data_total[144]["translations"]["es"])
	#pass
