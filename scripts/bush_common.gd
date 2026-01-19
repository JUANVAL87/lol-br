extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

@onready var bush = $Bush_Common

func _process(delta):
	bush.rotation.z = sin(Time.get_ticks_msec() * 0.001) * 0.05
