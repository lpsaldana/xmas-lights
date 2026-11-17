extends Node3D


var light_color: Color = Color(0, 0.468, 0.8)
@export var light_energy: float = 25
@export var emission_energy: float = 5
@export var number: int = 1

@onready var glass: MeshInstance3D = $LampBase/Glass
@onready var omni_light_3d: OmniLight3D = $OmniLight3D
@onready var base_1: MeshInstance3D = $LampBase/Base1
@onready var base_2: MeshInstance3D = $LampBase/Base2
@onready var base_3: MeshInstance3D = $LampBase/Base3
@onready var base_4: MeshInstance3D = $LampBase/Base4
@onready var base_5: MeshInstance3D = $LampBase/Base5
@onready var base_6: MeshInstance3D = $LampBase/Base6
@onready var base_7: MeshInstance3D = $LampBase/Base7
@onready var base_8: MeshInstance3D = $LampBase/Base8

var is_on: bool = false
var glass_material: StandardMaterial3D

func _ready() -> void:
	if number == 1:
		base_1.visible = true
		light_color = Color("#1F51FF")
	elif number == 2:
		base_2.visible = true
		light_color = Color("6b603cff")
	elif number == 3:
		base_3.visible = true
		light_color = Color("0c5e00ff")
	elif number == 4:
		base_4.visible = true
		light_color = Color("650097ff")
	elif number == 5:
		base_5.visible = true
		light_color = Color("b0004bff")
	elif number == 6:
		base_6.visible = true
		light_color = Color("#FF3131")
	elif number == 7:
		base_7.visible = true
		light_color = Color("005f58ff")
	else:
		base_8.visible = true
		light_color = Color("#FF5F1F")
	glass_material = glass.get_active_material(0).duplicate()
	glass.set_surface_override_material(0,glass_material)
	glass_material.emission_enabled = true
	glass_material.emission = light_color
	glass_material.emission_energy_multiplier = emission_energy
	set_lamp_state(false)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		set_lamp_state(!is_on)

func set_lamp_state(power:bool) -> void:
	is_on = power
	omni_light_3d.visible = power
	if power:
		omni_light_3d.light_color = light_color
		omni_light_3d.light_energy = 25
		glass_material.emission_energy_multiplier = emission_energy
	else:
		glass_material.emission_energy_multiplier = 0
