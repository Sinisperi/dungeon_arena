class_name CameraRig extends Node3D

@export var camera: Camera3D
@export var arm: SpringArm3D

var current: bool:
	set(value):
		current = value
		camera.current = value
