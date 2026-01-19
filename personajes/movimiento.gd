extends CharacterBody3D
class_name personaje_base

# --- ATRIBUTOS ---
var tipo
var health
var damage_amount

const SPEED = 6.5
const TURN_SPEED = 12.0

# --- VARIABLES DE DASH ---
const DASH_SPEED = 25.0
const DASH_DURATION = 0.2
var is_dashing := false
var modo_ataque := false 

# --- REFERENCIAS A NODOS ---
@onready var skin = $skin
@onready var anim_tree = $skin/AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")

func _physics_process(delta):
	# 1. SI ESTÁ EN DASH, EL MOVIMIENTO ES AUTOMÁTICO Y SE SALTA EL RESTO
	if is_dashing:
		move_and_slide()
		return 

	# 2. OBTENER ENTRADA DEL JUGADOR
	var input_dir = Input.get_vector("izquierda", "derecha", "arriba", "abajo")

	# 3. PROCESAR MOVIMIENTO NORMAL
	velocity.x = input_dir.x * SPEED
	velocity.z = input_dir.y * SPEED
	move_and_slide()
	
	# 4. CONTROL DE ANIMACIONES (Solo ocurre si no hay dash por el return de arriba)
	actualizar_animaciones()

	# 5. LÓGICA DE HABILIDAD (DASH)
	controlar_modo_habilidad()

	# 6. LÓGICA DE ROTACIÓN
	aplicar_rotacion(delta, input_dir)

func actualizar_animaciones():
	if velocity.length() > 0.1:
		anim_state.travel("run") 
	else:
		anim_state.travel("idle")

func controlar_modo_habilidad():
	# Activar modo preparación
	if Input.is_action_just_pressed("habilidad1"):
		modo_ataque = true
		print("Modo habilidad: Preparado. Ejecutar o Cancelar.")

	if modo_ataque:
		# EJECUTAR DASH (Click Izquierdo)
		if Input.is_action_just_pressed("ejecutar"):
			ejecutar_dash()
		
		# CANCELAR (Click Derecho)
		if Input.is_action_just_pressed("cancelar"):
			modo_ataque = false
			print("Habilidad cancelada")

func ejecutar_dash():
	var mouse_world = get_mouse_world_position()
	var dir = (mouse_world - global_position).normalized()
	dir.y = 0 
	
	if dir.length() == 0: 
		dir = -skin.global_transform.basis.z 

	# --- INICIO DEL DASH ---
	is_dashing = true
	modo_ataque = false 
	velocity = dir * DASH_SPEED
	
	# Congelamos la animación en el frame actual
	anim_tree.active = false 

	# Esperar el tiempo del impulso
	await get_tree().create_timer(DASH_DURATION).timeout
	
	# --- FIN DEL DASH ---
	is_dashing = false
	anim_tree.active = true # Reactivamos las animaciones
	velocity = Vector3.ZERO 

func aplicar_rotacion(delta, input_dir):
	var target_angle: float
	var has_target := false

	if modo_ataque:
		var mouse_world = get_mouse_world_position()
		if mouse_world:
			var dir = mouse_world - global_position
			dir.y = 0
			if dir.length() > 0.01:
				target_angle = atan2(dir.x, dir.z)
				has_target = true
	
	elif input_dir != Vector2.ZERO:
		target_angle = atan2(input_dir.x, input_dir.y)
		has_target = true

	if has_target:
		skin.rotation.y = lerp_angle(
			skin.rotation.y,
			target_angle,
			delta * TURN_SPEED
		)

func get_mouse_world_position() -> Vector3:
	var cam = get_viewport().get_camera_3d()
	if not cam: return Vector3.ZERO
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = cam.project_ray_origin(mouse_pos)
	var to = from + cam.project_ray_normal(mouse_pos) * 1000.0

	var plane = Plane(Vector3.UP, global_position.y)
	var intersection = plane.intersects_ray(from, to)
	
	return intersection if intersection else Vector3.ZERO
