extends Node3D

@onready var player = $Personaje
@onready var spawn_points = $spawns.get_children()

func _ready():
	randomize()
	var spawn = spawn_points.pick_random()
	player.global_position = spawn.global_position
