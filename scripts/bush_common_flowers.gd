extends Node3D

func _process(delta):
	rotation.z = sin(Time.get_ticks_msec() * 0.001) * 0.05
