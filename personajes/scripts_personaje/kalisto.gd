extends personaje_base

# --- VARIABLES ÚNICAS DE KALISTO ---
const VELOCIDAD_DASH = 25.0
const DURACION_DASH = 0.2
var is_dashing := false

func _ready():
	# Configuración de stats
	nombre = "Kalisto"
	tipo = "luchador"
	vida = 650
	daño = 60
	velocidad = 6.0
	velocidad_giro = 12.0

func _physics_process(delta):
	super(delta)
	# 1. Prioridad: Dash
	if is_dashing:
		move_and_slide()
		return 
	
	# 2. Entrada de ejecución
	if modo_ataque and Input.is_action_just_pressed("ejecutar"):
		ejecutar_dash()
		return

	# 3. Activar lógica del padre

# Implementación específica de animaciones para Kalisto
func actualizar_animaciones():
	if is_dashing or anim_state == null:
		return

	if velocity.length() > 0.1:
		anim_state.travel("run")
	else:
		anim_state.travel("idle")

func ejecutar_dash():
	var mouse_world = get_mouse_world_position()
	var dir = (mouse_world - global_position).normalized()
	dir.y = 0
	
	if dir.length() == 0:
		dir = -skin.global_transform.basis.z

	is_dashing = true
	modo_ataque = false
	velocity = dir * VELOCIDAD_DASH
	
	if anim_tree: anim_tree.active = false 
	
	await get_tree().create_timer(DURACION_DASH).timeout
	
	is_dashing = false
	if anim_tree: anim_tree.active = true 
	velocity = Vector3.ZERO
