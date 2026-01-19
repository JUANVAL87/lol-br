extends CharacterBody3D
class_name personaje_base

# --- ATRIBUTOS ---
var nombre: String
var tipo: String
var vida: int
var daño: int
var velocidad: float = 0.0
var velocidad_giro: float = 0.0
var modo_ataque: bool = false

# --- REFERENCIAS A NODOS ---
# Las referencias se dejan aquí para que los hijos las hereden automáticamente
@onready var skin = $skin 
@onready var anim_tree = $skin/AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback") if anim_tree else null

func _physics_process(delta):
	# 1. OBTENER ENTRADA
	var input_dir = Input.get_vector("izquierda", "derecha", "arriba", "abajo")

	# 2. PROCESAR MOVIMIENTO NORMAL
	velocity.x = input_dir.x * velocidad
	velocity.z = input_dir.y * velocidad
	move_and_slide()
	
	# 3. LLAMADAS A FUNCIONES (Los hijos decidirán qué hacen)
	actualizar_animaciones()
	controlar_modo_habilidad()
	aplicar_rotacion(delta, input_dir)

# --- FUNCIONES PARA SOBREESCRIBIR EN EL HIJO ---

func actualizar_animaciones():
	# Se deja vacío: cada hijo decidirá si usa "run", "float", etc.
	pass

func controlar_modo_habilidad():
	# Lógica universal de activación/cancelación
	if Input.is_action_just_pressed("habilidad1"):
		modo_ataque = true
	
	if modo_ataque and Input.is_action_just_pressed("cancelar"):
		modo_ataque = false

# --- LÓGICA DE APOYO ---

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

	if has_target and skin:
		skin.rotation.y = lerp_angle(skin.rotation.y, target_angle, delta * velocidad_giro)

func get_mouse_world_position() -> Vector3:
	var cam = get_viewport().get_camera_3d()
	if not cam: return Vector3.ZERO
	var mouse_pos = get_viewport().get_mouse_position()
	var from = cam.project_ray_origin(mouse_pos)
	var to = from + cam.project_ray_normal(mouse_pos) * 1000.0
	var plane = Plane(Vector3.UP, global_position.y)
	var intersection = plane.intersects_ray(from, to)
	return intersection if intersection else Vector3.ZERO
