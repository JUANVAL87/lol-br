extends personaje_base
# --- VARIABLES DE DASH ---
const velocidad_dash = 25.0
const duracion_dash = 0.2
var is_dashing := false

#Declarar personaje
func _ready():
	tipo = "luchador"
	vida = 650
	daño = 60
	velocidad = 6
	velocidad_giro = 12


func _physics_process(delta):
	# 1. SI ESTÁ EN DASH, EL MOVIMIENTO ES AUTOMÁTICO Y SE SALTA EL RESTO
	if is_dashing:
		move_and_slide()
		return 
	super(delta)

func ejecutar_dash():
	var mouse_world = get_mouse_world_position()
	var dir = (mouse_world - global_position).normalized()
	dir.y = 0 
	
	if dir.length() == 0: 
		dir = -skin.global_transform.basis.z 

	# --- INICIO DEL DASH ---
	is_dashing = true
	modo_ataque = false 
	velocity = dir * velocidad_dash
	
	# Congelamos la animación en el frame actual
	anim_tree.active = false 

	# Esperar el tiempo del impulso
	await get_tree().create_timer(duracion_dash).timeout
	
	# --- FIN DEL DASH ---
	is_dashing = false
	anim_tree.active = true # Reactivamos las animaciones
	velocity = Vector3.ZERO 
